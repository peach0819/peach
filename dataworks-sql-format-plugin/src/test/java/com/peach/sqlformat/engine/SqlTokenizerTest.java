package com.peach.sqlformat.engine;

import org.junit.jupiter.api.Test;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class SqlTokenizerTest {

    private List<Token> tokenize(String sql) {
        return new SqlTokenizer(sql).tokenize();
    }

    @Test
    void testSimpleSelect() {
        List<Token> tokens = tokenize("SELECT a, b FROM t");
        assertEquals(7, tokens.size()); // SELECT, a, COMMA, b, FROM, t, EOF
        assertEquals(TokenType.KEYWORD, tokens.get(0).getType());
        assertEquals("SELECT", tokens.get(0).getText());
        assertEquals(TokenType.IDENTIFIER, tokens.get(1).getType());
        assertEquals("a", tokens.get(1).getText());
        assertEquals(TokenType.COMMA, tokens.get(2).getType());
        assertEquals(TokenType.IDENTIFIER, tokens.get(3).getType());
        assertEquals("b", tokens.get(3).getText());
        assertEquals(TokenType.KEYWORD, tokens.get(4).getType());
        assertEquals("FROM", tokens.get(4).getText());
        assertEquals(TokenType.IDENTIFIER, tokens.get(5).getType());
        assertEquals("t", tokens.get(5).getText());
        assertEquals(TokenType.EOF, tokens.get(6).getType());
    }

    @Test
    void testFunctionToken() {
        List<Token> tokens = tokenize("SELECT nvl(a, 0)");
        assertEquals(TokenType.FUNCTION, tokens.get(1).getType());
        assertEquals("nvl", tokens.get(1).getText());
    }

    @Test
    void testStringLiteral() {
        List<Token> tokens = tokenize("SELECT 'hello world'");
        assertEquals(TokenType.STRING, tokens.get(1).getType());
        assertEquals("'hello world'", tokens.get(1).getText());
    }

    @Test
    void testVariable() {
        List<Token> tokens = tokenize("WHERE dayid = '${v_date}'");
        assertEquals(TokenType.STRING, tokens.get(3).getType());
        assertEquals("'${v_date}'", tokens.get(3).getText());
    }

    @Test
    void testLineComment() {
        List<Token> tokens = tokenize("SELECT a -- comment\nFROM b");
        assertEquals(TokenType.LINE_COMMENT, tokens.get(2).getType());
        assertTrue(tokens.get(2).getText().contains("-- comment"));
    }

    @Test
    void testMultiWordKeyword() {
        List<Token> tokens = tokenize("a LEFT JOIN b");
        assertEquals(TokenType.KEYWORD, tokens.get(1).getType());
        assertTrue(tokens.get(1).getText().equalsIgnoreCase("LEFT JOIN"));
    }

    @Test
    void testInsertOverwriteTable() {
        List<Token> tokens = tokenize("INSERT OVERWRITE TABLE t");
        assertEquals(TokenType.KEYWORD, tokens.get(0).getType());
        assertTrue(tokens.get(0).getText().equalsIgnoreCase("INSERT OVERWRITE TABLE"));
    }

    @Test
    void testBacktickIdentifier() {
        List<Token> tokens = tokenize("SELECT `col name`");
        assertEquals(TokenType.IDENTIFIER, tokens.get(1).getType());
        assertEquals("`col name`", tokens.get(1).getText());
    }

    @Test
    void testNumberToken() {
        List<Token> tokens = tokenize("SELECT 123");
        assertEquals(TokenType.NUMBER, tokens.get(1).getType());
        assertEquals("123", tokens.get(1).getText());
    }

    @Test
    void testOperator() {
        List<Token> tokens = tokenize("a != b AND c <= d");
        assertEquals(TokenType.OPERATOR, tokens.get(1).getType());
        assertEquals("!=", tokens.get(1).getText());
        assertEquals(TokenType.OPERATOR, tokens.get(5).getType());
        assertEquals("<=", tokens.get(5).getText());
    }

    @Test
    void testBlockComment() {
        List<Token> tokens = tokenize("SELECT /* comment */ a");
        assertEquals(TokenType.BLOCK_COMMENT, tokens.get(1).getType());
        assertTrue(tokens.get(1).getText().contains("/* comment */"));
    }

    @Test
    void testRightJoin() {
        List<Token> tokens = tokenize("a RIGHT JOIN b");
        assertEquals(TokenType.KEYWORD, tokens.get(1).getType());
        assertEquals("RIGHT JOIN", tokens.get(1).getText().toUpperCase());
    }
}
