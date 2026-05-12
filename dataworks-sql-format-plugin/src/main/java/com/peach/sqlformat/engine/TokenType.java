package com.peach.sqlformat.engine;

public enum TokenType {
    KEYWORD,
    FUNCTION,
    IDENTIFIER,
    STRING,
    NUMBER,
    OPERATOR,
    COMMA,
    DOT,
    LPAREN,
    RPAREN,
    STAR,
    LINE_COMMENT,
    BLOCK_COMMENT,
    VARIABLE,
    SEMICOLON,
    EOF
}
