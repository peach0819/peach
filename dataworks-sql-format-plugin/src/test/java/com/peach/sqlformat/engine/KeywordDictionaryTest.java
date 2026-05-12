package com.peach.sqlformat.engine;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class KeywordDictionaryTest {

    @Test
    void testMultiWordKeyword() {
        assertEquals("LEFT JOIN", KeywordDictionary.matchMultiWordKeyword("LEFT JOIN"));
        assertEquals("INSERT OVERWRITE TABLE", KeywordDictionary.matchMultiWordKeyword("INSERT OVERWRITE TABLE ..."));
    }

    @Test
    void testIsKeyword() {
        assertTrue(KeywordDictionary.isKeyword("SELECT"));
        assertTrue(KeywordDictionary.isKeyword("where"));
        assertFalse(KeywordDictionary.isKeyword("nvl"));
    }

    @Test
    void testIsFunction() {
        assertTrue(KeywordDictionary.isFunction("nvl"));
        assertTrue(KeywordDictionary.isFunction("get_json_object"));
        assertFalse(KeywordDictionary.isFunction("SELECT"));
    }
}
