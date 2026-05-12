package com.peach.sqlformat.engine;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class SqlTokenizer {
    private final String input;
    private int pos;
    private final int length;

    // Cached sorted multi-word keyword list (longest first)
    private static List<String> multiWordList = null;

    public SqlTokenizer(String input) {
        this.input = input;
        this.length = input.length();
        this.pos = 0;
    }

    public List<Token> tokenize() {
        List<Token> tokens = new ArrayList<>();
        while (pos < length) {
            char c = input.charAt(pos);

            if (Character.isWhitespace(c)) {
                pos++;
                continue;
            }

            // Line comment: --
            if (c == '-' && pos + 1 < length && input.charAt(pos + 1) == '-') {
                tokens.add(readLineComment());
                continue;
            }

            // Block comment: /* ... */
            if (c == '/' && pos + 1 < length && input.charAt(pos + 1) == '*') {
                tokens.add(readBlockComment());
                continue;
            }

            // Single-quoted string
            if (c == '\'') {
                tokens.add(readString());
                continue;
            }

            // Variable: ${...}
            if (c == '$' && pos + 1 < length && input.charAt(pos + 1) == '{') {
                tokens.add(readVariable());
                continue;
            }

            // Single character tokens
            if (c == '(') { tokens.add(new Token(TokenType.LPAREN, "(")); pos++; continue; }
            if (c == ')') { tokens.add(new Token(TokenType.RPAREN, ")")); pos++; continue; }
            if (c == ',') { tokens.add(new Token(TokenType.COMMA, ",")); pos++; continue; }
            if (c == '.') { tokens.add(new Token(TokenType.DOT, ".")); pos++; continue; }
            if (c == '*') { tokens.add(new Token(TokenType.STAR, "*")); pos++; continue; }
            if (c == ';') { tokens.add(new Token(TokenType.SEMICOLON, ";")); pos++; continue; }

            // Operators: =, !, <, >, +, -, /, %
            if ("=!<>+-/%".indexOf(c) >= 0) {
                tokens.add(readOperator());
                continue;
            }

            // Number
            if (Character.isDigit(c)) {
                tokens.add(readNumber());
                continue;
            }

            // Word (identifier, keyword, function, or backtick-quoted identifier)
            if (Character.isLetter(c) || c == '_' || c == '`') {
                tokens.add(readWord());
                continue;
            }

            // Skip unknown characters
            pos++;
        }
        tokens.add(new Token(TokenType.EOF, ""));
        return tokens;
    }

    private Token readLineComment() {
        int start = pos;
        // Skip past '--'
        pos += 2;
        while (pos < length && input.charAt(pos) != '\n') {
            pos++;
        }
        return new Token(TokenType.LINE_COMMENT, input.substring(start, pos));
    }

    private Token readBlockComment() {
        int start = pos;
        // Skip past '/*'
        pos += 2;
        while (pos < length) {
            if (input.charAt(pos) == '*' && pos + 1 < length && input.charAt(pos + 1) == '/') {
                pos += 2;
                break;
            }
            pos++;
        }
        return new Token(TokenType.BLOCK_COMMENT, input.substring(start, pos));
    }

    private Token readString() {
        int start = pos;
        // Skip opening quote
        pos++;
        while (pos < length) {
            char c = input.charAt(pos);
            if (c == '\'') {
                // Check for escaped quote ''
                if (pos + 1 < length && input.charAt(pos + 1) == '\'') {
                    pos += 2;
                    continue;
                }
                pos++;
                break;
            }
            pos++;
        }
        return new Token(TokenType.STRING, input.substring(start, pos));
    }

    private Token readVariable() {
        int start = pos;
        // Skip past '${'
        pos += 2;
        while (pos < length && input.charAt(pos) != '}') {
            pos++;
        }
        if (pos < length) {
            pos++; // skip '}'
        }
        return new Token(TokenType.VARIABLE, input.substring(start, pos));
    }

    private Token readOperator() {
        int start = pos;
        char c = input.charAt(pos);
        pos++;
        // Two-character operators
        if (pos < length) {
            char next = input.charAt(pos);
            if ((c == '<' && next == '=') ||
                    (c == '>' && next == '=') ||
                    (c == '!' && next == '=') ||
                    (c == '<' && next == '>')) {
                pos++;
            }
        }
        return new Token(TokenType.OPERATOR, input.substring(start, pos));
    }

    private Token readNumber() {
        int start = pos;
        while (pos < length && Character.isDigit(input.charAt(pos))) {
            pos++;
        }
        // Optional decimal point - but only consume if followed by a digit
        if (pos < length && input.charAt(pos) == '.' &&
                pos + 1 < length && Character.isDigit(input.charAt(pos + 1))) {
            pos++; // consume '.'
            while (pos < length && Character.isDigit(input.charAt(pos))) {
                pos++;
            }
        }
        return new Token(TokenType.NUMBER, input.substring(start, pos));
    }

    private Token readWord() {
        int start = pos;

        // Backtick-quoted identifier
        if (input.charAt(pos) == '`') {
            pos++;
            while (pos < length && input.charAt(pos) != '`') {
                pos++;
            }
            if (pos < length) {
                pos++;
            }
            return new Token(TokenType.IDENTIFIER, input.substring(start, pos));
        }

        // Read the word
        while (pos < length && (Character.isLetterOrDigit(input.charAt(pos)) || input.charAt(pos) == '_')) {
            pos++;
        }
        String word = input.substring(start, pos);

        // Try to match multi-word keyword by peeking ahead
        int savedPos = pos;
        String fullPhrase = readAheadForMultiWord(word);
        if (fullPhrase != null) {
            return new Token(TokenType.KEYWORD, fullPhrase);
        }
        // Restore position if no multi-word keyword matched
        pos = savedPos;

        // Check if followed by LPAREN (for function detection)
        boolean followedByParen = false;
        int peekPos = pos;
        while (peekPos < length && Character.isWhitespace(input.charAt(peekPos))) {
            peekPos++;
        }
        if (peekPos < length && input.charAt(peekPos) == '(') {
            followedByParen = true;
        }

        if (KeywordDictionary.isKeyword(word)) {
            return new Token(TokenType.KEYWORD, word);
        }
        if (followedByParen && KeywordDictionary.isFunction(word)) {
            return new Token(TokenType.FUNCTION, word);
        }
        return new Token(TokenType.IDENTIFIER, word);
    }

    private String readAheadForMultiWord(String firstWord) {
        // Build sorted list (longest first) - do this once, not per call
        if (multiWordList == null) {
            multiWordList = new ArrayList<>(KeywordDictionary.getMultiWordKeywords());
            multiWordList.sort(Comparator.comparingInt(s -> -s.split(" ").length));
        }

        int savedPos = pos;
        for (String mw : multiWordList) {
            String[] parts = mw.split(" ");
            if (!parts[0].equalsIgnoreCase(firstWord)) {
                continue;
            }

            // Reset position and try to match the full phrase
            pos = savedPos;
            StringBuilder sb = new StringBuilder(firstWord);
            boolean match = true;
            for (int i = 1; i < parts.length; i++) {
                // Skip whitespace
                while (pos < length && Character.isWhitespace(input.charAt(pos))) {
                    sb.append(input.charAt(pos));
                    pos++;
                }
                // Read next word
                int wordStart = pos;
                while (pos < length && (Character.isLetterOrDigit(input.charAt(pos)) || input.charAt(pos) == '_')) {
                    pos++;
                }
                if (pos == wordStart) {
                    match = false;
                    break;
                }
                String nextWord = input.substring(wordStart, pos);
                sb.append(nextWord);
                if (!nextWord.equalsIgnoreCase(parts[i])) {
                    match = false;
                    break;
                }
            }
            if (match) {
                return sb.toString();
            }
        }

        pos = savedPos; // restore
        return null;
    }
}
