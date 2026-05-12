package com.peach.sqlformat.engine;

import java.util.List;

public class SqlFormatter {

    private static final String INDENT = "    ";

    private final SqlTokenizer tokenizer;

    /** Keywords that start a new clause line (aligned at current indent) */
    private static boolean isClauseStartKeyword(String upper) {
        return upper.equals("SELECT") || upper.equals("FROM") || upper.equals("WHERE")
                || upper.equals("WITH")
                || upper.equals("ORDER BY") || upper.equals("GROUP BY")
                || upper.equals("HAVING") || upper.equals("LIMIT")
                || upper.equals("CLUSTER BY") || upper.equals("DISTRIBUTE BY")
                || upper.equals("SORT BY")
                || upper.equals("INSERT") || upper.startsWith("INSERT");
    }

    /** Keywords that are JOIN-like and get their own line */
    private static boolean isJoinKeyword(String upper) {
        return upper.contains("JOIN");
    }

    public SqlFormatter(SqlTokenizer tokenizer) {
        this.tokenizer = tokenizer;
    }

    public String format(String sql) {
        List<Token> tokens = tokenizer.tokenize();
        StringBuilder out = new StringBuilder();
        FormatContext ctx = new FormatContext();

        for (int i = 0; i < tokens.size(); i++) {
            Token token = tokens.get(i);
            if (token.getType() == TokenType.EOF) break;
            processToken(token, i, tokens, ctx, out);
        }

        return out.toString().trim();
    }

    private void processToken(Token token, int index, List<Token> tokens, FormatContext ctx, StringBuilder out) {
        switch (token.getType()) {
            case KEYWORD: handleKeyword(token, index, tokens, ctx, out); break;
            case FUNCTION: handleFunction(token, ctx, out); break;
            case COMMA: handleComma(index, tokens, ctx, out); break;
            case LPAREN: handleLparen(ctx, out); break;
            case RPAREN: handleRparen(index, tokens, ctx, out); break;
            case LINE_COMMENT: handleLineComment(token, ctx, out); break;
            case BLOCK_COMMENT: handleBlockComment(token, ctx, out); break;
            case SEMICOLON: out.append(";\n"); break;
            case DOT: handleDot(ctx, out); break;
            default: handleGenericToken(token, ctx, out); break;
        }
    }

    private void handleKeyword(Token token, int index, List<Token> tokens, FormatContext ctx, StringBuilder out) {
        String text = token.getText();
        String upper = text.toUpperCase();

        // Handle clause-starting keywords
        if (isClauseStartKeyword(upper)) {
            // Blank line before INSERT at top level
            if (upper.startsWith("INSERT") && ctx.indentLevel == 0 && out.length() > 0) {
                out.append("\n\n");
                ctx.afterNewline = true;
            } else if (out.length() > 0 && !ctx.justHadNewline) {
                newline(out);
                ctx.afterNewline = true;
            }

            // CTE handling: WITH starts CTE mode
            if (upper.equals("WITH")) {
                ctx.insideCte = true;
                ctx.firstCte = true;
            }

            // SELECT tracking
            if (upper.equals("SELECT")) {
                ctx.currentClause = Clause.SELECT;
                ctx.firstColumn = true;
            } else if (upper.equals("FROM")) {
                ctx.currentClause = Clause.FROM;
            } else if (upper.equals("WHERE")) {
                ctx.currentClause = Clause.WHERE;
            } else if (upper.startsWith("INSERT")) {
                ctx.currentClause = Clause.INSERT;
                ctx.inInsert = true;
            }

            appendIndent(out, ctx.indentLevel);
            out.append(upper);
            ctx.afterKeyword = true;

            // Track column alignment position for SELECT
            if (upper.equals("SELECT")) {
                // "SELECT " is 7 chars — fixed offset from indent
                ctx.columnAlignment = upper.length() + 1;
                ctx.firstColumn = true;
            }

            // Space after clause-starting keywords always
            out.append(" ");

            ctx.afterNewline = false;
            ctx.justHadNewline = false;
            return;
        }

        // AND / OR
        if (upper.equals("AND") || upper.equals("OR")) {
            newline(out);
            appendIndent(out, ctx.indentLevel);
            out.append(upper).append(" ");
            ctx.afterNewline = false;
            ctx.afterKeyword = true;
            ctx.justHadNewline = false;
            return;
        }

        // AS (alias)
        if (upper.equals("AS")) {
            out.append(" as ");
            ctx.afterKeyword = true;
            return;
        }

        // ON
        if (upper.equals("ON")) {
            out.append(" ON ");
            ctx.afterKeyword = true;
            return;
        }

        // JOIN keywords
        if (isJoinKeyword(upper)) {
            if (!ctx.justHadNewline) {
                newline(out);
            }
            appendIndent(out, ctx.indentLevel);
            out.append(upper).append(" ");
            ctx.afterNewline = false;
            ctx.afterKeyword = true;
            ctx.justHadNewline = false;
            return;
        }

        // Default keyword handling
        if (ctx.afterNewline || ctx.afterComma) {
            appendIndent(out, ctx.indentLevel);
        } else if (out.length() > 0 && !ctx.afterKeyword && !ctx.justHadLparen) {
            out.append(" ");
        }
        out.append(upper);
        Token next2 = (index + 1 < tokens.size()) ? tokens.get(index + 1) : null;
        if (next2 != null && next2.getType() != TokenType.RPAREN && next2.getType() != TokenType.COMMA
                && next2.getType() != TokenType.SEMICOLON && next2.getType() != TokenType.LINE_COMMENT) {
            out.append(" ");
        }
        ctx.afterKeyword = true;
        ctx.afterComma = false;
        ctx.afterNewline = false;
        ctx.justHadLparen = false;
        ctx.justHadNewline = false;
    }

    private void handleFunction(Token token, FormatContext ctx, StringBuilder out) {
        String lower = token.getText().toLowerCase();
        if (ctx.afterNewline || ctx.afterComma) {
            appendIndent(out, ctx.indentLevel);
        } else if (out.length() > 0 && !ctx.afterKeyword && !ctx.justHadLparen) {
            out.append(" ");
        }
        out.append(lower);
        ctx.afterKeyword = false;
        ctx.afterComma = false;
        ctx.afterNewline = false;
        ctx.justHadLparen = false;
        ctx.justHadNewline = false;
    }

    private void handleComma(int index, List<Token> tokens, FormatContext ctx, StringBuilder out) {
        out.append(",");

        // Check next non-whitespace token to see if we're in SELECT column list
        Token nextNonWs = null;
        for (int i = index + 1; i < tokens.size(); i++) {
            Token t = tokens.get(i);
            if (t.getType() != TokenType.EOF) {
                nextNonWs = t;
                break;
            }
        }

        // In SELECT clause, comma triggers newline for next column (but not inside function args)
        if (ctx.currentClause == Clause.SELECT && ctx.parenDepth == 0) {
            newline(out);
            // Align to column position
            if (ctx.columnAlignment > 0) {
                for (int i = 0; i < ctx.columnAlignment; i++) {
                    out.append(" ");
                }
            } else {
                appendIndent(out, ctx.indentLevel);
            }
            ctx.afterComma = true;
            ctx.firstColumn = false;
        } else {
            out.append(" ");
            ctx.afterComma = false;
        }
        ctx.afterNewline = false;
        ctx.afterKeyword = false;
        ctx.justHadLparen = false;
        ctx.justHadNewline = false;
    }

    private void handleLparen(FormatContext ctx, StringBuilder out) {
        out.append("(");
        // CTE body starts: the first ( after WITH opens the CTE body
        if (ctx.insideCte && ctx.cteOpenDepth < 0) {
            ctx.cteOpenDepth = ctx.parenDepth;
            ctx.cteIndentLevel = ctx.indentLevel;
            ctx.indentLevel++;
        }
        ctx.parenDepth++;
        ctx.afterLparen = true;
        ctx.afterKeyword = false;
        ctx.justHadLparen = true;
    }

    private void handleRparen(int index, List<Token> tokens, FormatContext ctx, StringBuilder out) {
        ctx.parenDepth--;

        // Check if this closes a CTE's opening paren
        if (ctx.insideCte && ctx.cteOpenDepth >= 0 && ctx.parenDepth == ctx.cteOpenDepth) {
            // End of CTE body - restore indent
            ctx.indentLevel--;
            newline(out);
            appendIndent(out, ctx.indentLevel);
            out.append(")");
            ctx.insideCte = false;
            ctx.cteOpenDepth = -1;
            ctx.afterCte = true;
        } else {
            out.append(")");
        }
        ctx.justHadLparen = false;
    }

    private void handleLineComment(Token token, FormatContext ctx, StringBuilder out) {
        if (!ctx.justHadNewline && out.length() > 0) {
            out.append(" ");
        }
        out.append(token.getText()).append("\n");
        ctx.afterNewline = true;
        ctx.justHadNewline = true;
        ctx.afterKeyword = false;
    }

    private void handleBlockComment(Token token, FormatContext ctx, StringBuilder out) {
        if (!ctx.justHadNewline && out.length() > 0) {
            out.append(" ");
        }
        out.append(token.getText()).append(" ");
        ctx.afterNewline = false;
        ctx.justHadNewline = false;
        ctx.afterKeyword = false;
    }

    private void handleDot(FormatContext ctx, StringBuilder out) {
        // Dot: no spaces around it (e.g., t.id, schema.table)
        out.append(".");
        ctx.afterKeyword = false;
        ctx.afterComma = false;
        ctx.afterNewline = false;
        ctx.justHadLparen = false;
        ctx.justHadNewline = false;
        ctx.justHadDot = true;
    }

    private void handleGenericToken(Token token, FormatContext ctx, StringBuilder out) {
        String text = token.getText();

        if (ctx.afterNewline || ctx.afterComma) {
            appendIndent(out, ctx.indentLevel);
        } else if (out.length() > 0 && !ctx.afterKeyword && !ctx.justHadLparen && !ctx.afterLparen && !ctx.justHadDot) {
            // Check if previous output ends with "("
            String outStr = out.toString();
            if (!outStr.endsWith("(") && !outStr.endsWith(" ") && !outStr.endsWith("\n")) {
                out.append(" ");
            }
        }

        out.append(text);
        ctx.afterKeyword = false;
        ctx.afterComma = false;
        ctx.afterNewline = false;
        ctx.afterLparen = false;
        ctx.justHadLparen = false;
        ctx.justHadNewline = false;
        ctx.justHadDot = false;
    }

    private void newline(StringBuilder out) {
        out.append("\n");
    }

    private void appendIndent(StringBuilder out, int level) {
        for (int i = 0; i < level; i++) {
            out.append(INDENT);
        }
    }

    private enum Clause {
        SELECT, FROM, WHERE, INSERT, NONE
    }

    private static class FormatContext {
        int indentLevel = 0;
        Clause currentClause = Clause.NONE;
        int parenDepth = 0;
        int columnAlignment = 0;  // position where SELECT columns align
        boolean afterKeyword = false;
        boolean afterComma = false;
        boolean afterNewline = true;
        boolean afterLparen = false;
        boolean firstColumn = true;
        boolean justHadNewline = true;
        boolean justHadLparen = false;
        boolean justHadDot = false;

        // CTE state
        boolean insideCte = false;
        boolean firstCte = true;
        int cteOpenDepth = -1;    // paren depth when CTE's ( was opened
        int cteIndentLevel = 0;   // indent level when CTE body starts
        boolean afterCte = false;

        // INSERT state
        boolean inInsert = false;
    }
}
