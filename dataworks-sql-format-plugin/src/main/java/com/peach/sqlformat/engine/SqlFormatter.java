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
        // Skip LPAREN already consumed by handleLineComment (e.g., after "as -- comment")
        if (token.getType() == TokenType.LPAREN && ctx.lparenConsumed) {
            ctx.lparenConsumed = false;
            return;
        }
        switch (token.getType()) {
            case KEYWORD: handleKeyword(token, index, tokens, ctx, out); break;
            case FUNCTION: handleFunction(token, ctx, out); break;
            case COMMA: handleComma(index, tokens, ctx, out); break;
            case LPAREN: handleLparen(ctx, out); break;
            case RPAREN: handleRparen(index, tokens, ctx, out); break;
            case LINE_COMMENT: handleLineComment(token, index, tokens, ctx, out); break;
            case BLOCK_COMMENT: handleBlockComment(token, ctx, out); break;
            case SEMICOLON: out.append(";\n"); break;
            case DOT: handleDot(ctx, out); break;
            case LBRACKET: handleBracket("[", ctx, out); break;
            case RBRACKET: handleBracket("]", ctx, out); break;
            default: handleGenericToken(token, ctx, out); break;
        }
    }

    private void handleKeyword(Token token, int index, List<Token> tokens, FormatContext ctx, StringBuilder out) {
        String text = token.getText();
        String upper = text.toUpperCase();

        // UNION ALL / UNION DISTINCT / UNION — set operations with blank lines around them
        if (upper.equals("UNION ALL") || upper.equals("UNION DISTINCT") || upper.equals("UNION")) {
            ctx.inJoinOn = false;
            ctx.afterCte = false;
            ctx.expectingNextCte = false;

            // Blank line before UNION
            if (out.length() > 0) {
                out.append("\n\n");
            }
            // Indent UNION ALL to match current context (inside CTE/subquery body)
            appendIndent(out, ctx.indentLevel);
            out.append(upper);
            // Blank line after UNION
            out.append("\n\n");

            ctx.afterNewline = true;
            ctx.justHadNewline = true;
            ctx.afterKeyword = false;
            ctx.currentClause = Clause.NONE;
            return;
        }

        // Handle clause-starting keywords
        if (isClauseStartKeyword(upper)) {
            // Inside OVER(...) — keep keywords inline (window function)
            if (ctx.inOverClause) {
                out.append(" ").append(upper).append(" ");
                ctx.afterKeyword = true;
                return;
            }

            ctx.inJoinOn = false;  // new clause ends any JOIN ON context
            ctx.afterCte = false;  // new clause ends any CTE context

            // Blank line before INSERT at top level
            if (upper.startsWith("INSERT") && ctx.indentLevel == 0 && out.length() > 0) {
                out.append("\n\n");
                ctx.afterNewline = true;
            } else if (out.length() > 0 && !ctx.justHadNewline) {
                newline(out);
                ctx.afterNewline = true;
            }

            // Reset expectingNextCte when a new clause starts (e.g., SELECT after last CTE)
            ctx.expectingNextCte = false;

            // CTE handling: WITH starts CTE mode
            if (upper.equals("WITH")) {
                ctx.insideCte = true;
                ctx.firstCte = true;
            }

            // SELECT / GROUP BY / ORDER BY tracking
            if (upper.equals("SELECT")) {
                ctx.currentClause = Clause.SELECT;
                ctx.firstColumn = true;
            } else if (upper.equals("FROM")) {
                ctx.currentClause = Clause.FROM;
                ctx.expectingSubquery = true;  // next ( after FROM is a subquery
            } else if (upper.equals("WHERE")) {
                ctx.currentClause = Clause.WHERE;
            } else if (upper.equals("GROUP BY")) {
                ctx.currentClause = Clause.GROUP_BY;
                ctx.firstColumn = true;
            } else if (upper.equals("ORDER BY")) {
                ctx.currentClause = Clause.ORDER_BY;
                ctx.firstColumn = true;
            } else if (upper.startsWith("INSERT")) {
                ctx.currentClause = Clause.INSERT;
                ctx.inInsert = true;
            }

            appendIndent(out, ctx.indentLevel);
            out.append(upper);
            ctx.afterKeyword = true;

            // Track column alignment position for SELECT / GROUP BY / ORDER BY
            if (upper.equals("SELECT")) {
                // "SELECT " is 7 chars — fixed offset from indent
                ctx.columnAlignment = upper.length() + 1;
                ctx.firstColumn = true;
            } else if (upper.equals("GROUP BY") || upper.equals("ORDER BY")) {
                // "GROUP BY " / "ORDER BY " is 9 chars
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
            if (ctx.inJoinOn || ctx.inWhenCondition || ctx.functionDepth > 0) {
                // In JOIN ON conditions, CASE WHEN conditions, or inside function calls, keep AND/OR on same line
                out.append(" ").append(upper).append(" ");
            } else {
                if (!ctx.justHadNewline) {
                    newline(out);
                }
                appendIndent(out, ctx.indentLevel);
                out.append(upper).append(" ");
            }
            ctx.afterNewline = false;
            ctx.afterKeyword = true;
            ctx.justHadNewline = false;
            return;
        }

        // AS (alias)
        if (upper.equals("AS")) {
            if (ctx.expectingNextCte) {
                ctx.insideCte = true;
                ctx.firstCte = false;
                ctx.expectingNextCte = false;
            }
            out.append(" as ");
            ctx.afterKeyword = true;
            return;
        }

        // ON
        if (upper.equals("ON")) {
            out.append(" ON ");
            ctx.afterKeyword = true;
            ctx.inJoinOn = true;  // track that we're in a JOIN-ON condition
            return;
        }

        // CASE WHEN (nested via caseDepth counter)
        if (upper.equals("CASE")) {
            ctx.caseDepth++;
            // Save outer CASE state when entering a nested CASE
            if (ctx.caseDepth > 1) {
                ctx.caseStackIndex++;
                ctx.caseWhenPositionStack[ctx.caseStackIndex] = ctx.caseWhenPosition;
                ctx.caseWhenCountStack[ctx.caseStackIndex] = ctx.caseWhenCount;
            }
            ctx.inCase = true;
            ctx.caseFirstWhen = true;
            ctx.caseWhenPosition = -1;
            ctx.caseWhenCount = 0;
            ctx.inWhenCondition = false;
            if (ctx.justHadNewline || ctx.afterComma) {
                // Add indent when on a new line (e.g., after SELECT comma or line comment)
                appendIndent(out, ctx.indentLevel);
                ctx.afterNewline = false;
                ctx.justHadNewline = false;
            } else if (out.length() > 0) {
                // Ensure space before CASE when it follows an expression/operator (e.g., END+CASE → END + CASE)
                String outStr = out.toString();
                if (!outStr.endsWith(" ") && !outStr.endsWith("(") && !outStr.endsWith("\n")) {
                    out.append(" ");
                }
            }
            out.append("CASE ");
            ctx.afterKeyword = true;
            ctx.afterComma = false;
            return;
        }
        if (ctx.caseDepth > 0 && (upper.equals("WHEN") || upper.equals("THEN") || upper.equals("ELSE") || upper.equals("END"))) {
            if (upper.equals("THEN")) {
                ctx.inWhenCondition = false;
                // Add space before THEN if not already at a word boundary
                String outStr = out.toString();
                if (!outStr.endsWith(" ") && !outStr.endsWith("\n")) {
                    out.append(" ");
                }
                out.append("THEN ");
                ctx.afterKeyword = true;
                return;
            }
            if (upper.equals("WHEN")) {
                ctx.caseWhenCount++;
                ctx.inWhenCondition = true;
                if (ctx.caseFirstWhen) {
                    // First WHEN: stay on same line after CASE
                    // Record column position of WHEN relative to current line start
                    String currentOut = out.toString();
                    int lastNewline = currentOut.lastIndexOf("\n");
                    ctx.caseWhenPosition = (lastNewline >= 0) ? currentOut.length() - lastNewline - 1 : currentOut.length();
                    out.append("WHEN ");
                    ctx.caseFirstWhen = false;
                    ctx.afterComma = false;
                } else {
                    // Subsequent WHEN: new line aligned with first WHEN
                    newline(out);
                    if (ctx.caseWhenPosition > 0) {
                        for (int i = 0; i < ctx.caseWhenPosition; i++) {
                            out.append(" ");
                        }
                    } else {
                        appendIndent(out, ctx.indentLevel);
                    }
                    out.append("WHEN ");
                }
                ctx.afterKeyword = true;
                return;
            }
            if (upper.equals("ELSE")) {
                if (ctx.caseWhenCount <= 1) {
                    // Single WHEN: ELSE on same line
                    out.append(" ELSE ");
                } else {
                    // Multiple WHENs: ELSE on new line aligned with WHEN
                    newline(out);
                    if (ctx.caseWhenPosition > 0) {
                        for (int i = 0; i < ctx.caseWhenPosition; i++) {
                            out.append(" ");
                        }
                    } else {
                        appendIndent(out, ctx.indentLevel);
                    }
                    out.append("ELSE ");
                }
                ctx.afterKeyword = true;
                return;
            }
            if (upper.equals("END")) {
                // END on same line (no line break); avoid double space if buffer ends with space
                String outStr = out.toString();
                if (!outStr.endsWith(" ") && !outStr.endsWith("\n")) {
                    out.append(" ");
                }
                out.append("END");
                ctx.caseDepth--;
                ctx.inCase = ctx.caseDepth > 0;
                // Restore outer CASE state when ending a nested CASE
                if (ctx.caseDepth > 0 && ctx.caseStackIndex >= 0) {
                    ctx.caseWhenPosition = ctx.caseWhenPositionStack[ctx.caseStackIndex];
                    ctx.caseWhenCount = ctx.caseWhenCountStack[ctx.caseStackIndex];
                    ctx.caseStackIndex--;
                }
                ctx.afterKeyword = false;  // allow next token to get proper spacing
                return;
            }
        }

        // JOIN keywords
        if (isJoinKeyword(upper)) {
            ctx.expectingSubquery = true;  // JOIN may be followed by a subquery (SELECT ...)
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

        // IN keyword — next ( opens an IN list (suppress comma line breaks)
        if (upper.equals("IN")) {
            ctx.afterInKeyword = true;
        }

        // OVER keyword — next ( opens a window function clause
        if (upper.equals("OVER")) {
            ctx.afterOver = true;
        }

        Token next2 = (index + 1 < tokens.size()) ? tokens.get(index + 1) : null;
        if (next2 != null && next2.getType() != TokenType.RPAREN && next2.getType() != TokenType.COMMA
                && next2.getType() != TokenType.SEMICOLON && next2.getType() != TokenType.LINE_COMMENT) {
            // Don't add trailing space before AND/OR (they handle their own spacing)
            boolean isAndOr = next2.getType() == TokenType.KEYWORD
                    && (next2.getText().equalsIgnoreCase("AND") || next2.getText().equalsIgnoreCase("OR"));
            if (!isAndOr) {
                out.append(" ");
            }
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
        } else if (out.length() > 0 && !ctx.afterKeyword && !ctx.justHadLparen && !ctx.justHadDot) {
            out.append(" ");
        }
        out.append(lower);
        ctx.afterKeyword = false;
        ctx.afterComma = false;
        ctx.afterNewline = false;
        ctx.justHadLparen = false;
        ctx.justHadNewline = false;
        ctx.functionPending = true;  // next LPAREN is a function call
    }

    private void handleComma(int index, List<Token> tokens, FormatContext ctx, StringBuilder out) {
        // CTE comma: between CTEs — comma after CTE closing ) means next CTE
        if (ctx.afterCte) {
            out.append(",");
            newline(out);
            newline(out);
            ctx.expectingNextCte = true;
            ctx.afterCte = false;
            ctx.afterNewline = true;
            ctx.justHadNewline = true;
            return;
        }

        // Comma already consumed by handleLineComment (put before comment)
        if (ctx.commaConsumed) {
            ctx.commaConsumed = false;
            return;
        }

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

        // In SELECT / GROUP BY / ORDER BY clause, comma triggers newline for next column
        // (but not inside function args, OVER, or IN list)
        boolean isListClause = ctx.currentClause == Clause.SELECT
                || ctx.currentClause == Clause.GROUP_BY
                || ctx.currentClause == Clause.ORDER_BY;
        if (isListClause && ctx.functionDepth == 0 && !ctx.inOverClause && ctx.inClauseDepth == 0) {
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
            ctx.afterNewline = false;
            ctx.afterKeyword = false;
            ctx.justHadLparen = false;
            ctx.justHadNewline = false;
        } else {
            // Inside function args / IN list / OVER: comma already added space
            out.append(" ");
            ctx.afterComma = false;
            ctx.afterNewline = false;
            ctx.afterKeyword = true;  // buffer already has trailing space
            ctx.justHadLparen = false;
            ctx.justHadNewline = false;
        }
    }

    private void handleLparen(FormatContext ctx, StringBuilder out) {
        // Add space before ( when not a function call and output doesn't end with space/paren/newline
        // This ensures operators like + have proper spacing: "5 + (sum(...)" instead of "5 +(sum(...)"
        if (!ctx.functionPending && !ctx.justHadNewline && out.length() > 0) {
            String outStr = out.toString();
            if (!outStr.endsWith(" ") && !outStr.endsWith("(") && !outStr.endsWith("\n")) {
                out.append(" ");
            }
        }
        out.append("(");

        // CTE body starts: the first ( after WITH opens the CTE body
        if (ctx.insideCte && ctx.cteOpenDepth < 0) {
            ctx.cteOpenDepth = ctx.parenDepth;
            ctx.cteIndentLevel = ctx.indentLevel;
            ctx.indentLevel++;
        }

        // Function call paren: the ( after a function name
        if (ctx.functionPending) {
            ctx.functionDepth++;
            ctx.functionDepthIndex++;
            ctx.functionOpenDepths[ctx.functionDepthIndex] = ctx.parenDepth;
            ctx.functionPending = false;
        }

        // IN list paren: ( after IN keyword — suppress comma line breaks
        if (ctx.afterInKeyword) {
            ctx.inClauseDepth++;
            ctx.afterInKeyword = false;
        }

        // Subquery paren: ( after FROM keyword (before any table identifier)
        if (ctx.expectingSubquery) {
            ctx.subqueryOpenDepths[++ctx.subqueryDepthIndex] = ctx.parenDepth;
            ctx.indentLevel++;
            ctx.expectingSubquery = false;
        }

        // OVER (window function) paren — keep keywords inline inside
        if (ctx.afterOver) {
            ctx.overOpenDepth = ctx.parenDepth;
            ctx.inOverClause = true;
            ctx.afterOver = false;
        }

        ctx.parenDepth++;
        ctx.afterLparen = true;
        ctx.afterKeyword = false;
        ctx.justHadLparen = true;
    }

    private void handleRparen(int index, List<Token> tokens, FormatContext ctx, StringBuilder out) {
        ctx.parenDepth--;

        // Decrement IN clause depth if inside an IN list
        if (ctx.inClauseDepth > 0) {
            ctx.inClauseDepth--;
        }

        // Check if this closes a CTE's opening paren
        if (ctx.insideCte && ctx.cteOpenDepth >= 0 && ctx.parenDepth == ctx.cteOpenDepth) {
            // End of CTE body — output ) at same indent as WITH keyword (no extra indent)
            ctx.indentLevel--;   // restore to pre-CTE indent
            if (!ctx.justHadNewline) {
                newline(out);
            }
            out.append(")");
            ctx.insideCte = false;
            ctx.cteOpenDepth = -1;
            ctx.afterCte = true;
            ctx.justHadLparen = false;
            return;
        }

        // Check if this closes OVER's opening paren (window function)
        if (ctx.inOverClause && ctx.overOpenDepth >= 0 && ctx.parenDepth == ctx.overOpenDepth) {
            ctx.inOverClause = false;
            ctx.overOpenDepth = -1;
            out.append(")");
            ctx.justHadLparen = false;
            return;
        }

        // Check if this closes a subquery opening paren
        if (ctx.subqueryDepthIndex >= 0 && ctx.parenDepth == ctx.subqueryOpenDepths[ctx.subqueryDepthIndex]) {
            ctx.subqueryDepthIndex--;
            ctx.indentLevel--;
            if (!ctx.justHadNewline) {
                newline(out);
            }
            appendIndent(out, ctx.indentLevel);
            out.append(")");
            ctx.justHadLparen = false;
            ctx.afterKeyword = false;  // 允许后续 alias 前加空格
            ctx.afterNewline = false;
            return;
        }

        // Decrement function depth if closing the matching function-call paren
        if (ctx.functionDepth > 0 && ctx.functionDepthIndex >= 0
                && ctx.parenDepth == ctx.functionOpenDepths[ctx.functionDepthIndex]) {
            ctx.functionDepth--;
            ctx.functionDepthIndex--;
        }

        out.append(")");
        ctx.afterKeyword = false;
        ctx.justHadLparen = false;
    }

    private void handleLineComment(Token token, int index, List<Token> tokens, FormatContext ctx, StringBuilder out) {
        // Check next token
        Token nextTok = (index + 1 < tokens.size()) ? tokens.get(index + 1) : null;
        boolean nextIsComma = nextTok != null && nextTok.getType() == TokenType.COMMA;
        boolean nextIsLparen = nextTok != null && nextTok.getType() == TokenType.LPAREN;
        boolean commaBeforeComment = nextIsComma && ctx.currentClause == Clause.SELECT && ctx.columnAlignment > 0;

        // When "as" keyword + line comment is followed by LPAREN, place "(" before the comment
        // e.g., "WITH order_base as ( --订单明细" instead of "...as --订单明细\n("
        String outStr = out.toString();
        if (nextIsLparen && outStr.endsWith(" as ")) {
            out.append("(");
            // Replicate handleLparen side effects for CTE opening
            if (ctx.insideCte && ctx.cteOpenDepth < 0) {
                ctx.cteOpenDepth = ctx.parenDepth;
                ctx.cteIndentLevel = ctx.indentLevel;
                ctx.indentLevel++;
            }
            ctx.parenDepth++;
            ctx.afterLparen = true;
            ctx.afterKeyword = false;
            ctx.justHadLparen = true;
            ctx.lparenConsumed = true;  // skip the LPAREN token when it's processed later
        }

        // Special case: comment after a SELECT column comma — keep comment on same line
        // as the column, then add the newline+alignment for the next column
        if (ctx.currentClause == Clause.SELECT && ctx.columnAlignment > 0 && !ctx.justHadNewline) {
            int lastNewline = outStr.lastIndexOf("\n");
            if (lastNewline >= 0) {
                String afterNewline = outStr.substring(lastNewline + 1);
                if (afterNewline.length() == ctx.columnAlignment && afterNewline.chars().allMatch(c -> c == ' ')) {
                    // Strip trailing newline+alignment, put comment (with comma if next is COMMA)
                    // on same line, re-add alignment for next column
                    out.setLength(lastNewline);
                    if (commaBeforeComment) {
                        out.append(",");
                        ctx.commaConsumed = true;
                    }
                    out.append(" ").append(token.getText()).append("\n");
                    for (int i = 0; i < ctx.columnAlignment; i++) {
                        out.append(" ");
                    }
                    ctx.afterNewline = true;
                    ctx.justHadNewline = true;
                    ctx.afterKeyword = false;
                    return;
                }
            }
        }

        if (ctx.justHadNewline) {
            appendIndent(out, ctx.indentLevel);
        } else if (out.length() > 0) {
            if (commaBeforeComment) {
                // Comma should be before the comment on the same line
                out.append(",");
                ctx.commaConsumed = true;
            }
            out.append(" ");
        }
        out.append(token.getText()).append("\n");
        // When comma was consumed, add columnAlignment spaces for the next column
        if (commaBeforeComment) {
            for (int i = 0; i < ctx.columnAlignment; i++) {
                out.append(" ");
            }
        }
        ctx.afterNewline = true;
        ctx.justHadNewline = true;
        ctx.afterKeyword = false;
    }

    private void handleBlockComment(Token token, FormatContext ctx, StringBuilder out) {
        if (ctx.justHadNewline) {
            appendIndent(out, ctx.indentLevel);
        } else if (out.length() > 0) {
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

    private void handleBracket(String bracket, FormatContext ctx, StringBuilder out) {
        // Bracket: no space before [ or after ] (e.g., arr[1])
        out.append(bracket);
        ctx.afterKeyword = false;
        ctx.afterComma = false;
        ctx.afterNewline = false;
        ctx.justHadLparen = false;
        ctx.justHadNewline = false;
        ctx.justHadDot = false;
        // Prevent space after [ (next token should not get leading space)
        if (bracket.equals("[")) {
            ctx.justHadLparen = true;
        }
    }

    private void handleGenericToken(Token token, FormatContext ctx, StringBuilder out) {
        String text = token.getText();

        // Any non-paren token after FROM means no subquery paren immediately
        ctx.expectingSubquery = false;

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
        SELECT, FROM, WHERE, GROUP_BY, ORDER_BY, INSERT, NONE
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

        // Function call tracking (depth for commas inside function args)
        int functionDepth = 0;
        boolean functionPending = false;
        int[] functionOpenDepths = new int[16]; // parenDepth when each function ( was opened
        int functionDepthIndex = -1;            // stack pointer for functionOpenDepths

        // Subquery tracking (stack for nested subqueries)
        int[] subqueryOpenDepths = new int[10];
        int subqueryDepthIndex = -1;
        boolean expectingSubquery = false;

        // JOIN ON tracking (AND/OR inline)
        boolean inJoinOn = false;

        // CTE state
        boolean insideCte = false;
        boolean firstCte = true;
        int cteOpenDepth = -1;    // paren depth when CTE's ( was opened
        int cteIndentLevel = 0;   // indent level when CTE body starts
        boolean afterCte = false;
        boolean expectingNextCte = false;
        boolean commaConsumed = false;
        boolean lparenConsumed = false;

        // INSERT state
        boolean inInsert = false;

        // IN clause list tracking (suppress line breaks inside IN (...))
        boolean afterInKeyword = false;
        int inClauseDepth = 0;

        // CASE WHEN tracking
        int caseDepth = 0;
        boolean inCase = false;
        boolean caseFirstWhen = true;
        int caseWhenPosition = -1;
        int caseWhenCount = 0;
        boolean inWhenCondition = false;
        int[] caseWhenPositionStack = new int[10];
        int[] caseWhenCountStack = new int[10];
        int caseStackIndex = -1;

        // OVER (window function) tracking — keep clause keywords inline
        boolean inOverClause = false;
        int overOpenDepth = -1;
        boolean afterOver = false;
    }
}
