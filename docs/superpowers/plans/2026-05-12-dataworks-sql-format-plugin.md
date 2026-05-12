# DataWorks SQL Format Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a standalone IntelliJ IDEA plugin that formats `.sql` files according to dataworks-sql-format rules.

**Architecture:** Plugin with a thin IntelliJ AnAction layer and a zero-dependency pure-Java formatting engine (Tokenizer + Formatter). The engine is independently unit-testable without IDEA SDK.

**Tech Stack:** Java 11, Gradle IntelliJ Plugin (org.jetbrains.intellij), JUnit 5, IntelliJ IDEA 2021.3+

**Project Location:** `C:\pack\peach1\dataworks-sql-format-plugin\` (standalone project, sibling to peach)

---

### Task 1: Project scaffold

**Files:**
- Create: `dataworks-sql-format-plugin/settings.gradle.kts`
- Create: `dataworks-sql-format-plugin/build.gradle.kts`
- Create: `dataworks-sql-format-plugin/src/main/resources/META-INF/plugin.xml`
- Create: `dataworks-sql-format-plugin/gradle.properties`
- Create: `dataworks-sql-format-plugin/src/main/java/com/peach/sqlformat/engine/TokenType.java`
- Create: `dataworks-sql-format-plugin/src/main/java/com/peach/sqlformat/engine/Token.java`

- [ ] **Step 1: Create settings.gradle.kts**

```kotlin
rootProject.name = "dataworks-sql-format-plugin"
```

- [ ] **Step 2: Create build.gradle.kts**

```kotlin
plugins {
    id("java")
    id("org.jetbrains.intellij") version "1.13.3"
}

group = "com.peach"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.9.2")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

intellij {
    version.set("2021.3")
    type.set("IC")
    plugins.set(listOf())
}

tasks {
    withType<JavaCompile> {
        options.encoding = "UTF-8"
    }
    patchPluginXml {
        sinceBuild.set("213")
        untilBuild.set("241.*")
    }
    test {
        useJUnitPlatform()
    }
}
```

- [ ] **Step 3: Create gradle.properties**

```properties
org.gradle.jvmargs=-Xmx512m
```

- [ ] **Step 4: Create plugin.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE idea-plugin PUBLIC "Plugin/DTD" "http://plugins.jetbrains.com/dtd/plugin.dtd">
<idea-plugin>
    <id>com.peach.dataworks-sql-format</id>
    <name>DataWorks SQL Format</name>
    <vendor>peach</vendor>

    <description><![CDATA[
    DataWorks SQL 格式化工具，遵循 dataworks-sql-format 规范。
    支持 Hive SQL / Spark SQL 格式化：
    <ul>
        <li>关键字大写</li>
        <li>函数名小写</li>
        <li>4空格缩进</li>
        <li>CTE / 子查询 / JOIN 规范排版</li>
        <li>保留 ${v_date} 变量和 -- 注释</li>
    </ul>
    ]]></description>

    <depends>com.intellij.modules.platform</depends>

    <extensions defaultExtensionNs="com.intellij">
    </extensions>

    <actions>
        <action id="DataWorksSqlFormatAction"
                class="com.peach.sqlformat.action.DataWorksSqlFormatAction"
                text="DataWorks SQL 格式化"
                description="按 DataWorks SQL 规范格式化">
            <add-to-group group-id="EditorPopupMenu"
                          anchor="after"
                          relative-to="Cut"/>
        </action>
    </actions>
</idea-plugin>
```

- [ ] **Step 5: Create TokenType.java**

```java
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
    VARIABLE,
    EOF
}
```

- [ ] **Step 6: Create Token.java**

```java
package com.peach.sqlformat.engine;

public class Token {
    private final TokenType type;
    private final String text;

    public Token(TokenType type, String text) {
        this.type = type;
        this.text = text;
    }

    public TokenType getType() { return type; }
    public String getText() { return text; }

    @Override
    public String toString() {
        return "Token{" + type + ": '" + text + "'}";
    }
}
```

- [ ] **Step 7: Verify build works**

Run: `cd dataworks-sql-format-plugin && gradlew build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 8: Commit**

```
git add dataworks-sql-format-plugin/
git commit -m "feat: scaffold DataWorks SQL Format plugin project"
```

---

### Task 2: Keyword/Function dictionary

**Files:**
- Create: `dataworks-sql-format-plugin/src/main/java/com/peach/sqlformat/engine/KeywordDictionary.java`

This class provides utilities to classify identifiers as keywords, functions, or plain identifiers.

- [ ] **Step 1: Write KeywordDictionary.java**

```java
package com.peach.sqlformat.engine;

import java.util.*;

public class KeywordDictionary {

    private static final Set<String> MULTI_WORD_KEYWORDS = new LinkedHashSet<>(Arrays.asList(
            "INSERT OVERWRITE TABLE",
            "LEFT ANTI JOIN",
            "LEFT SEMI JOIN",
            "LEFT OUTER JOIN",
            "RIGHT OUTER JOIN",
            "FULL OUTER JOIN",
            "CROSS JOIN",
            "INNER JOIN",
            "LEFT JOIN",
            "RIGHT JOIN",
            "FULL JOIN",
            "UNION ALL",
            "UNION DISTINCT",
            "ORDER BY",
            "GROUP BY",
            "PARTITION BY",
            "CLUSTER BY",
            "DISTRIBUTE BY",
            "SORT BY"
    ));

    private static final Set<String> KEYWORDS = new HashSet<>(Arrays.asList(
            "SELECT", "FROM", "WHERE", "AND", "OR", "ON", "AS", "IN", "NOT",
            "INSERT", "OVERWRITE", "TABLE", "INTO", "VALUES",
            "LEFT", "RIGHT", "FULL", "INNER", "CROSS", "JOIN", "ANTI", "SEMI", "OUTER",
            "UNION", "ALL", "DISTINCT",
            "ORDER", "GROUP", "BY", "PARTITION", "CLUSTER", "DISTRIBUTE", "SORT",
            "HAVING", "LIMIT", "OFFSET",
            "SET", "CREATE", "ALTER", "DROP", "ADD",
            "IF", "ELSE", "THEN", "END", "CASE", "WHEN",
            "LIKE", "RLIKE", "REGEXP",
            "IS", "NULL", "BETWEEN", "EXISTS",
            "TRUE", "FALSE",
            "ASC", "DESC",
            "WITH", "RECURSIVE",
            "OVER", "LATERAL", "VIEW",
            "MAP", "REDUCE",
            "TRANSFORM", "USING",
            "LOAD", "DATA", "LOCAL", "INPATH",
            "SHOW", "DESCRIBE", "USE",
            "EXPLAIN", "EXTENDED",
            "TABLESAMPLE", "BUCKET",
            "ANY", "SOME",
            "ARRAY", "MAP", "STRUCT", "UNIONTYPE",
            "COMMENT",
            "PARTITIONED",
            "ROW", "FORMAT", "DELIMITED", "FIELDS", "TERMINATED",
            "LINES", "STORED", "AS", "FILEFORMAT",
            "INPUTFORMAT", "OUTPUTFORMAT",
            "LOCATION",
            "TBLPROPERTIES",
            "SEMI", "ANTI"
    ));

    private static final Set<String> FUNCTIONS = new HashSet<>(Arrays.asList(
            "nvl", "coalesce", "if", "case", "when",
            "get_json_object", "json_tuple", "from_json", "to_json",
            "split", "size", "concat", "concat_ws",
            "substr", "substring", "trim", "ltrim", "rtrim",
            "upper", "lower", "length", "replace", "regexp_replace",
            "regexp_extract", "cast",
            "date_format", "date_add", "date_sub", "datediff",
            "from_unixtime", "unix_timestamp", "to_date",
            "year", "month", "day", "hour", "minute", "second",
            "row_number", "rank", "dense_rank", "ntile", "lag", "lead",
            "first_value", "last_value",
            "sum", "count", "max", "min", "avg",
            "collect_list", "collect_set",
            "explode", "posexplode", "lateral",
            "parse_url", "space", "repeat",
            "abs", "ceil", "floor", "round", "pow", "sqrt",
            "rand",
            "greatest", "least",
            "str_to_map", "map_keys", "map_values",
            "typed", "named_struct",
            "encode", "decode",
            "cast",
            "assert_true",
            "current_date", "current_timestamp",
            "next_day", "last_day", "trunc",
            "weekofyear", "dayofmonth", "dayofyear",
            "months_between", "add_months"
    ));

    /** Check if text (case-insensitive) starts with a multi-word keyword prefix */
    public static String matchMultiWordKeyword(String textUpper) {
        for (String mw : MULTI_WORD_KEYWORDS) {
            if (textUpper.startsWith(mw)) {
                return mw;
            }
        }
        return null;
    }

    /** Check if the single word (uppercased) is a keyword */
    public static boolean isKeyword(String wordUpper) {
        return KEYWORDS.contains(wordUpper);
    }

    /** Check if the word (lowercased) is a known function name */
    public static boolean isFunction(String wordLower) {
        return FUNCTIONS.contains(wordLower);
    }

    public static int maxMultiWordKeywordLength() {
        int max = 0;
        for (String mw : MULTI_WORD_KEYWORDS) {
            // count words
            int words = mw.split(" ").length;
            if (words > max) max = words;
        }
        return max;
    }
}
```

- [ ] **Step 2: Create the test file**

File: `dataworks-sql-format-plugin/src/test/java/com/peach/sqlformat/engine/KeywordDictionaryTest.java`

```java
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
```

- [ ] **Step 3: Run tests**

Run: `gradlew test --tests "*KeywordDictionaryTest*"` (from plugin directory)
Expected: All tests pass

- [ ] **Step 4: Commit**

```
git add dataworks-sql-format-plugin/
git commit -m "feat: add keyword/function dictionary"
```

---

### Task 3: SqlTokenizer implementation

**Files:**
- Create: `dataworks-sql-format-plugin/src/main/java/com/peach/sqlformat/engine/SqlTokenizer.java`
- Create: `dataworks-sql-format-plugin/src/test/java/com/peach/sqlformat/engine/SqlTokenizerTest.java`

The tokenizer reads SQL string character by character and produces a list of Tokens.

Key rules:
- Multi-word keywords matched first (e.g., `LEFT JOIN` before `LEFT`)
- Single-quoted strings: read until closing quote (skip escaped `\'`)
- `--` line comments: read to end of line
- `${...}` variable: read until `}`
- Single words (letters/digits/underscore): classify via KeywordDictionary (KEYWORD vs FUNCTION vs IDENTIFIER)
- Operators: single chars `=`, `!`, `<`, `>`, `+`, `-`, `/`, `%`
- `,` → COMMA, `.` → DOT, `*` → STAR
- `(` → LPAREN, `)` → RPAREN
- Whitespace between tokens is skipped (not tokenized)

- [ ] **Step 1: Write SqlTokenizer.java**

```java
package com.peach.sqlformat.engine;

import java.util.ArrayList;
import java.util.List;

public class SqlTokenizer {
    private final String input;
    private int pos;
    private final int length;

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

            if (c == '-' && pos + 1 < length && input.charAt(pos + 1) == '-') {
                tokens.add(readLineComment());
                continue;
            }

            if (c == '\'') {
                tokens.add(readString());
                continue;
            }

            if (c == '$' && pos + 1 < length && input.charAt(pos + 1) == '{') {
                tokens.add(readVariable());
                continue;
            }

            if (c == '(') { tokens.add(new Token(TokenType.LPAREN, "(")); pos++; continue; }
            if (c == ')') { tokens.add(new Token(TokenType.RPAREN, ")")); pos++; continue; }
            if (c == ',') { tokens.add(new Token(TokenType.COMMA, ",")); pos++; continue; }
            if (c == '.') { tokens.add(new Token(TokenType.DOT, ".")); pos++; continue; }
            if (c == '*') { tokens.add(new Token(TokenType.STAR, "*")); pos++; continue; }

            // Operators
            if ("=!<>+-/%".indexOf(c) >= 0) {
                tokens.add(readOperator());
                continue;
            }

            // Number
            if (Character.isDigit(c)) {
                tokens.add(readNumber());
                continue;
            }

            // Word (identifier, keyword, function)
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
        while (pos < length && input.charAt(pos) != '\n') {
            pos++;
        }
        return new Token(TokenType.LINE_COMMENT, input.substring(start, pos));
    }

    private Token readString() {
        int start = pos;
        pos++; // skip opening '
        while (pos < length) {
            if (input.charAt(pos) == '\\' && pos + 1 < length) {
                pos += 2; // skip escaped char
                continue;
            }
            if (input.charAt(pos) == '\'') {
                pos++; // skip closing '
                break;
            }
            pos++;
        }
        return new Token(TokenType.STRING, input.substring(start, pos));
    }

    private Token readVariable() {
        int start = pos;
        pos += 2; // skip ${
        while (pos < length && input.charAt(pos) != '}') {
            pos++;
        }
        if (pos < length) pos++; // skip }
        return new Token(TokenType.VARIABLE, input.substring(start, pos));
    }

    private Token readOperator() {
        int start = pos;
        char c = input.charAt(pos);
        pos++;
        // Two-char operators: <=, >=, !=, <>
        if (pos < length && ((c == '<' && input.charAt(pos) == '=') ||
                             (c == '>' && input.charAt(pos) == '=') ||
                             (c == '!' && input.charAt(pos) == '=') ||
                             (c == '<' && input.charAt(pos) == '>'))) {
            pos++;
        }
        return new Token(TokenType.OPERATOR, input.substring(start, pos));
    }

    private Token readNumber() {
        int start = pos;
        while (pos < length && (Character.isDigit(input.charAt(pos)) || input.charAt(pos) == '.')) {
            // Avoid reading .. or . followed by non-digit as part of number
            if (input.charAt(pos) == '.') {
                if (pos + 1 >= length || !Character.isDigit(input.charAt(pos + 1))) {
                    break;
                }
            }
            pos++;
        }
        return new Token(TokenType.NUMBER, input.substring(start, pos));
    }

    private Token readWord() {
        int start = pos;
        // Check for backtick-quoted identifier
        if (input.charAt(pos) == '`') {
            pos++;
            while (pos < length && input.charAt(pos) != '`') {
                pos++;
            }
            if (pos < length) pos++; // skip closing `
            String text = input.substring(start, pos);
            return new Token(TokenType.IDENTIFIER, text);
        }

        while (pos < length && (Character.isLetterOrDigit(input.charAt(pos)) || input.charAt(pos) == '_')) {
            pos++;
        }

        String word = input.substring(start, pos);

        // Try to match multi-word keyword at current position
        // We need to check the remaining input ahead
        String remainingUpper = word.toUpperCase();
        // Check if the full multi-word keyword fits
        for (String mw : KeywordDictionary.MULTI_WORD_KEYWORDS) {
            String mwUpper = mw.toUpperCase();
            if (remainingUpper.equals(mwUpper)) {
                return new Token(TokenType.KEYWORD, word);
            }
            // Check if multi-word keyword starts with our word and more follows
            if (mwUpper.startsWith(remainingUpper + " ")) {
                // Peek ahead in original input
                int savedPos = pos;
                StringBuilder fullPhrase = new StringBuilder(word);
                // skip whitespace and read next words
                while (pos < length && Character.isWhitespace(input.charAt(pos))) {
                    fullPhrase.append(input.charAt(pos));
                    pos++;
                }
                // Read next word
                while (pos < length && (Character.isLetterOrDigit(input.charAt(pos)) || input.charAt(pos) == '_')) {
                    fullPhrase.append(input.charAt(pos));
                    pos++;
                }
                String fullText = fullPhrase.toString();
                String fullUpper = fullText.toUpperCase();
                if (fullUpper.equals(mwUpper)) {
                    return new Token(TokenType.KEYWORD, fullText);
                }
                // Check for 3-word keywords
                if (mwUpper.startsWith(fullUpper + " ")) {
                    // skip whitespace
                    while (pos < length && Character.isWhitespace(input.charAt(pos))) {
                        fullPhrase.append(input.charAt(pos));
                        pos++;
                    }
                    while (pos < length && (Character.isLetterOrDigit(input.charAt(pos)) || input.charAt(pos) == '_')) {
                        fullPhrase.append(input.charAt(pos));
                        pos++;
                    }
                    fullText = fullPhrase.toString();
                    String fullUpper3 = fullText.toUpperCase();
                    if (fullUpper3.equals(mwUpper)) {
                        return new Token(TokenType.KEYWORD, fullText);
                    }
                }
                // Not a multi-word keyword, restore position
                pos = savedPos;
            }
        }

        // Single word: check if it's a function (followed by LPAREN)
        boolean followedByParen = false;
        int savedPos = pos;
        while (savedPos < length && Character.isWhitespace(input.charAt(savedPos))) {
            savedPos++;
        }
        if (savedPos < length && input.charAt(savedPos) == '(') {
            followedByParen = true;
        }

        String wordUpper = word.toUpperCase();
        String wordLower = word.toLowerCase();

        if (KeywordDictionary.isKeyword(wordUpper)) {
            return new Token(TokenType.KEYWORD, word);
        }
        if (followedByParen && KeywordDictionary.isFunction(wordLower)) {
            return new Token(TokenType.FUNCTION, word);
        }
        return new Token(TokenType.IDENTIFIER, word);
    }
}
```

- [ ] **Step 2: Write SqlTokenizerTest.java**

```java
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
    }

    @Test
    void testFunctionToken() {
        List<Token> tokens = tokenize("SELECT nvl(a, 0)");
        assertEquals(TokenType.FUNCTION, tokens.get(1).getType());
        assertEquals("nvl", tokens.get(1).getText());
        assertEquals(TokenType.LPAREN, tokens.get(2).getType());
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
        // Find the variable token inside the string
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
        // The multi-word "LEFT JOIN" should be a single KEYWORD token
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
}
```

- [ ] **Step 3: Run tests**

Run: `gradlew test --tests "*SqlTokenizerTest*"`
Expected: All tests pass

- [ ] **Step 4: Commit**

```
git add dataworks-sql-format-plugin/
git commit -m "feat: implement SqlTokenizer"
```

---

### Task 4: SqlFormatter implementation

**Files:**
- Create: `dataworks-sql-format-plugin/src/main/java/com/peach/sqlformat/engine/SqlFormatter.java`
- Create: `dataworks-sql-format-plugin/src/test/java/com/peach/sqlformat/engine/SqlFormatterTest.java`

The formatter takes a list of tokens and produces a formatted SQL string.

State machine:
- Tracks: `indentLevel` (int), `currentClause` (enum: NONE, SELECT, FROM, WHERE, CTE, INSERT), `insideParen` (int depth), `columnAlignment` (int), `afterNewline` (boolean)
- Output buffer with StringBuilder

Format rules:
1. KEYWORD → UPPERCASE
2. FUNCTION → lowercase
3. IDENTIFIER, STRING, NUMBER, VARIABLE, LINE_COMMENT → as-is
4. SELECT: first column on same line, subsequent columns aligned to S position, comma at end of line
5. FROM, WHERE, JOIN, GROUP BY, ORDER BY, HAVING, LIMIT: newline, aligned with SELECT (indentLevel 0)
6. AND, OR: newline, aligned with WHERE's W
7. CTE: `cte_name as (` on one line, body indented 4, `)` on its own line, blank line between CTEs
8. INSERT OVERWRITE TABLE ...: standalone line
9. Subquery `(`: content indented 4, `)` aligned with opening context
10. Comma: follow with newline (in SELECT context) or space (in other contexts)

- [ ] **Step 1: Write SqlFormatter.java**

```java
package com.peach.sqlformat.engine;

import java.util.List;

public class SqlFormatter {

    private static final String INDENT = "    "; // 4 spaces

    private final SqlTokenizer tokenizer;

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
        String text = token.getText();
        TokenType type = token.getType();

        switch (type) {
            case KEYWORD:
                handleKeyword(token, index, tokens, ctx, out);
                break;
            case FUNCTION:
                handleFunction(token, index, tokens, ctx, out);
                break;
            case COMMA:
                handleComma(ctx, out);
                break;
            case LPAREN:
                handleLparen(ctx, out);
                break;
            case RPAREN:
                handleRparen(ctx, out);
                break;
            case LINE_COMMENT:
                handleLineComment(token, ctx, out);
                break;
            case STRING:
            case NUMBER:
            case IDENTIFIER:
            case VARIABLE:
            case STAR:
            case DOT:
            case OPERATOR:
                handleGenericToken(token, ctx, out);
                break;
            default:
                break;
        }
    }

    private void handleKeyword(Token token, int index, List<Token> tokens, FormatContext ctx, StringBuilder out) {
        String upper = token.getText().toUpperCase();
        TokenType prevType = (index > 0) ? tokens.get(index - 1).getType() : null;
        TokenType nextType = (index + 1 < tokens.size()) ? tokens.get(index + 1).getType() : null;

        // Clause-starting keywords
        if (isClauseStart(upper)) {
            // Blank line before INSERT at top level
            if (upper.startsWith("INSERT") && ctx.indentLevel == 0 && out.length() > 0) {
                out.append("\n\n");
                ctx.afterNewline = true;
            } else if (ctx.indentLevel == 0 && out.length() > 0 && !upper.equals("AS") && !upper.equals("ON")) {
                newline(out);
                ctx.afterNewline = true;
            } else if (ctx.indentLevel > 0) {
                newline(out);
                ctx.afterNewline = true;
            }
            appendIndent(out, ctx.indentLevel);
            out.append(upper);
            ctx.afterKeyword = true;

            // Track current clause for alignment
            if (upper.equals("SELECT")) {
                ctx.currentClause = Clause.SELECT;
                ctx.firstSelectColumn = true;
            } else if (upper.equals("FROM")) {
                ctx.currentClause = Clause.FROM;
            } else if (upper.equals("WHERE")) {
                ctx.currentClause = Clause.WHERE;
            } else if (upper.startsWith("INSERT")) {
                ctx.currentClause = Clause.INSERT;
            }

            // Space after keyword (unless next is LPAREN or specific cases)
            if (nextType != TokenType.LPAREN && nextType != TokenType.RPAREN && !upper.equals("AS")) {
                out.append(" ");
            }
            ctx.afterNewline = false;
            return;
        }

        // AND / OR
        if (upper.equals("AND") || upper.equals("OR")) {
            newline(out);
            appendIndent(out, ctx.indentLevel);
            out.append(upper).append(" ");
            ctx.afterNewline = false;
            ctx.afterKeyword = true;
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

        // Other keywords (IN, NOT, IS, NULL, etc.)
        if (isJoinKeyword(upper)) {
            newline(out);
            appendIndent(out, ctx.indentLevel);
            out.append(upper);
            if (nextType != TokenType.LPAREN) {
                out.append(" ");
            }
            ctx.afterNewline = false;
            return;
        }

        // Default: append as-is
        if (ctx.afterNewline || ctx.afterComma) {
            appendIndent(out, ctx.indentLevel);
        } else if (!ctx.afterKeyword) {
            out.append(" ");
        }
        out.append(upper);
        if (nextType != TokenType.RPAREN && nextType != TokenType.COMMA && nextType != TokenType.LPAREN) {
            out.append(" ");
        }
        ctx.afterKeyword = true;
        ctx.afterComma = false;
        ctx.afterNewline = false;
    }

    private void handleFunction(Token token, int index, List<Token> tokens, FormatContext ctx, StringBuilder out) {
        String lower = token.getText().toLowerCase();
        if (ctx.afterNewline || ctx.afterComma) {
            appendIndent(out, ctx.indentLevel);
        } else if (!ctx.afterKeyword && !ctx.afterLparen) {
            out.append(" ");
        }
        out.append(lower);
        ctx.afterKeyword = false;
        ctx.afterComma = false;
        ctx.afterNewline = false;
        ctx.afterLparen = false;
    }

    private void handleComma(FormatContext ctx, StringBuilder out) {
        out.append(",");
        // In SELECT context, comma triggers newline for next column
        if (ctx.currentClause == Clause.SELECT || ctx.currentClause == Clause.CTE) {
            newline(out);
            // Align to column position
            if (ctx.columnAlignment > 0) {
                for (int i = 0; i < ctx.columnAlignment; i++) {
                    out.append(" ");
                }
            } else {
                appendIndent(out, ctx.indentLevel + 1);
            }
            ctx.afterComma = true;
        } else {
            out.append(" ");
            ctx.afterComma = false;
        }
        ctx.afterNewline = false;
        ctx.afterLparen = false;
    }

    private void handleLparen(FormatContext ctx, StringBuilder out) {
        out.append("(");
        ctx.parenDepth++;
        ctx.afterLparen = true;
        ctx.afterKeyword = false;

        // Check if this is a subquery start (SELECT follows)
        // Don't indent yet - content will handle its own indent
    }

    private void handleRparen(FormatContext ctx, StringBuilder out) {
        ctx.parenDepth--;
        // If this closes a CTE
        if (ctx.insideCte && ctx.parenDepth == ctx.cteParenDepth - 1) {
            // CTE is ending
            out.append("\n)");
            ctx.insideCte = false;
            ctx.cteParenDepth = 0;
            ctx.indentLevel = Math.max(0, ctx.indentLevel - 1);
        } else {
            out.append(")");
        }
        ctx.afterLparen = false;
    }

    private void handleLineComment(Token token, FormatContext ctx, StringBuilder out) {
        // If not at start of line, add a space before comment
        if (out.length() > 0 && out.charAt(out.length() - 1) != '\n') {
            out.append(" ");
        }
        out.append(token.getText()).append("\n");
        ctx.afterNewline = true;
    }

    private void handleGenericToken(Token token, FormatContext ctx, StringBuilder out) {
        String text = token.getText();

        // Handle first SELECT column alignment
        if (ctx.currentClause == Clause.SELECT && ctx.firstSelectColumn) {
            ctx.firstSelectColumn = false;
            // Column alignment is handled - text is on same line as SELECT
        }

        if (ctx.afterNewline || ctx.afterComma) {
            if (ctx.currentClause == Clause.SELECT && ctx.columnAlignment > 0) {
                for (int i = 0; i < ctx.columnAlignment; i++) {
                    out.append(" ");
                }
            } else {
                appendIndent(out, ctx.indentLevel);
            }
        } else if (ctx.afterLparen) {
            // content right after ( like function args
        } else if (!ctx.afterKeyword) {
            out.append(" ");
        }

        out.append(text);
        ctx.afterKeyword = false;
        ctx.afterComma = false;
        ctx.afterNewline = false;
        ctx.afterLparen = false;
    }

    private boolean isClauseStart(String keyword) {
        return keyword.equals("SELECT") || keyword.equals("FROM") || keyword.equals("WHERE")
                || keyword.equals("INSERT") || keyword.startsWith("INSERT")
                || keyword.equals("WITH") || keyword.equals("ORDER BY")
                || keyword.equals("GROUP BY") || keyword.equals("HAVING")
                || keyword.equals("LIMIT") || keyword.equals("PARTITION BY")
                || keyword.equals("CLUSTER BY") || keyword.equals("DISTRIBUTE BY")
                || keyword.equals("SORT BY");
    }

    private boolean isJoinKeyword(String keyword) {
        return keyword.contains("JOIN");
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
        NONE, SELECT, FROM, WHERE, INSERT, CTE
    }

    private static class FormatContext {
        int indentLevel = 0;
        Clause currentClause = Clause.NONE;
        int parenDepth = 0;
        int columnAlignment = 0;
        boolean afterKeyword = false;
        boolean afterComma = false;
        boolean afterNewline = true; // start of output
        boolean afterLparen = false;
        boolean firstSelectColumn = false;
        boolean insideCte = false;
        int cteParenDepth = 0;
    }
}
```

- [ ] **Step 2: Write basic formatter test**

```java
package com.peach.sqlformat.engine;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class SqlFormatterTest {

    private String format(String sql) {
        SqlFormatter formatter = new SqlFormatter(new SqlTokenizer(sql));
        return formatter.format(sql);
    }

    @Test
    void testSimpleSelect() {
        String result = format("select a, b from t");
        assertEquals("SELECT a,\n       b\nFROM t", result);
    }

    @Test
    void testSelectWithWhere() {
        String result = format("select a, b from t where a = 1");
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM t"));
        assertTrue(result.contains("WHERE a = 1"));
    }

    @Test
    void testFunctionLowercase() {
        String result = format("SELECT NVL(a, 0)");
        assertTrue(result.contains("nvl(a, 0)"));
    }

    @Test
    void testVariablePreserved() {
        String result = format("SELECT * FROM t WHERE dayid = '${v_date}'");
        assertTrue(result.contains("'${v_date}'"));
    }

    @Test
    void testCommentPreserved() {
        String result = format("SELECT a -- comment\nFROM b");
        assertTrue(result.contains("-- comment"));
    }
}
```

- [ ] **Step 3: Run tests**

Run: `gradlew test --tests "*SqlFormatterTest*"`
Expected: All tests pass

- [ ] **Step 4: Commit**

```
git add dataworks-sql-format-plugin/
git commit -m "feat: implement SqlFormatter"
```

---

### Task 5: IntelliJ Action implementation

**Files:**
- Create: `dataworks-sql-format-plugin/src/main/java/com/peach/sqlformat/action/DataWorksSqlFormatAction.java`

- [ ] **Step 1: Write DataWorksSqlFormatAction.java**

```java
package com.peach.sqlformat.action;

import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.actionSystem.AnActionEvent;
import com.intellij.openapi.actionSystem.CommonDataKeys;
import com.intellij.openapi.command.WriteCommandAction;
import com.intellij.openapi.editor.Document;
import com.intellij.openapi.editor.Editor;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.vfs.VirtualFile;
import com.peach.sqlformat.engine.SqlFormatter;
import com.peach.sqlformat.engine.SqlTokenizer;
import org.jetbrains.annotations.NotNull;

public class DataWorksSqlFormatAction extends AnAction {

    @Override
    public void actionPerformed(@NotNull AnActionEvent e) {
        Editor editor = e.getData(CommonDataKeys.EDITOR);
        Project project = e.getData(CommonDataKeys.PROJECT);
        if (editor == null || project == null) return;

        Document document = editor.getDocument();
        String selectedText = editor.getSelectionModel().getSelectedText();

        try {
            String source = (selectedText != null) ? selectedText : document.getText();
            SqlFormatter formatter = new SqlFormatter(new SqlTokenizer(source));
            String result = formatter.format(source);

            WriteCommandAction.runWriteCommandAction(project, () -> {
                if (selectedText != null) {
                    int start = editor.getSelectionModel().getSelectionStart();
                    int end = editor.getSelectionModel().getSelectionEnd();
                    document.replaceString(start, end, result);
                } else {
                    document.setText(result);
                }
            });
        } catch (Exception ex) {
            // If formatting fails, leave content unchanged
            System.err.println("DataWorks SQL Format error: " + ex.getMessage());
        }
    }

    @Override
    public void update(@NotNull AnActionEvent e) {
        VirtualFile file = e.getData(CommonDataKeys.VIRTUAL_FILE);
        boolean enabled = file != null && file.getName().endsWith(".sql");
        e.getPresentation().setEnabledAndVisible(enabled);
    }
}
```

- [ ] **Step 2: Build the plugin**

Run: `gradlew buildPlugin`
Expected: BUILD SUCCESSFUL, plugin zip at `build/distributions/`

- [ ] **Step 3: Commit**

```
git add dataworks-sql-format-plugin/
git commit -m "feat: add IntelliJ action for SQL formatting"
```

---

### Task 6: Embed skill documentation in plugin resources

**Files:**
- Copy: `C:\Users\tao.zheng8833\.claude\skills\dataworks-sql-format\SKILL.md` → `dataworks-sql-format-plugin/src/main/resources/dataworks-sql-format-rules.md`

- [ ] **Step 1: Copy the SKILL.md into plugin resources**

```bash
cp "C:\Users\tao.zheng8833\.claude\skills\dataworks-sql-format\SKILL.md" \
   "dataworks-sql-format-plugin/src/main/resources/dataworks-sql-format-rules.md"
```

- [ ] **Step 2: Commit**

```
git add dataworks-sql-format-plugin/
git commit -m "docs: embed dataworks-sql-format rules as plugin resource"
```

---

### Task 7: Comprehensive integration tests

**Files:**
- Create: `dataworks-sql-format-plugin/src/test/java/com/peach/sqlformat/engine/SqlFormatterIntegrationTest.java`

- [ ] **Step 1: Write integration test with full SQL examples**

```java
package com.peach.sqlformat.engine;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class SqlFormatterIntegrationTest {

    private String format(String sql) {
        return new SqlFormatter(new SqlTokenizer(sql)).format(sql);
    }

    @Test
    void testCteQuery() {
        String input = "with a as (select id, name from t1), b as (select id, val from t2) select a.id, b.val from a left join b on a.id = b.id";

        String result = format(input);

        // CTE keyword uppercase
        assertTrue(result.contains("WITH"));
        // Keywords uppercase
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM"));
        assertTrue(result.contains("LEFT JOIN"));
        assertTrue(result.contains("ON"));
    }

    @Test
    void testInsertOverwrite() {
        String input = "insert overwrite table tbl partition (dayid='${v_date}') select a, b from src where a > 1";

        String result = format(input);

        assertTrue(result.contains("INSERT OVERWRITE TABLE"));
        assertTrue(result.contains("PARTITION"));
        assertTrue(result.contains("'${v_date}'"));
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM src"));
        assertTrue(result.contains("WHERE a > 1"));
    }

    @Test
    void testComplexHiveQuery() {
        String input = "SELECT get_json_object(feature, '$.user_id') as user_id, nvl(dept_id, 0) as dept_id FROM shop LEFT JOIN dept ON shop.dept_key = dept.key WHERE dayid = '${v_date}' AND status != 6 -- 排除未合作";

        String result = format(input);

        assertTrue(result.contains("get_json_object(feature, '$.user_id')"));
        assertTrue(result.contains("nvl(dept_id, 0)"));
        assertTrue(result.contains("LEFT JOIN"));
        assertTrue(result.contains("-- 排除未合作"));
        assertTrue(result.contains("'${v_date}'"));
    }

    @Test
    void testSubquery() {
        String input = "select a, b from (select id, name from t1 where id > 0) t where t.id < 100";

        String result = format(input);

        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM ("));
        assertTrue(result.contains("WHERE id > 0"));
    }

    @Test
    void testCaseWhen() {
        String input = "select if(a > 0, 'yes', 'no') as result, case when b = 1 then 'one' else 'other' end as label from t";

        String result = format(input);

        assertTrue(result.contains("if(a > 0, 'yes', 'no')"));
    }

    @Test
    void testNoLogicChange() {
        // Stripping all whitespace and case should produce same logical content
        String input = "SELECT a, b FROM t WHERE c = 1 AND d = 2";
        String result = format(input);

        String inputStripped = input.replaceAll("\\s+", "").toLowerCase();
        String resultStripped = result.replaceAll("\\s+", "").toLowerCase();

        // Same logical content, ignoring spaces and case
        // Note: content in string literals must match exactly
        assertEquals(inputStripped, resultStripped);
    }

    @Test
    void testNoLogicChangeWithStrings() {
        String input = "SELECT a, 'Hello World' as msg FROM t WHERE dayid = '${v_date}'";
        String result = format(input);

        // Original strings preserved
        assertTrue(result.contains("'Hello World'"));
        assertTrue(result.contains("'${v_date}'"));
    }
}
```

- [ ] **Step 2: Run all tests**

Run: `gradlew test`
Expected: All tests pass

- [ ] **Step 3: Commit**

```
git add dataworks-sql-format-plugin/
git commit -m "test: add integration tests"
```

---

### Task 8: Build verification and final packaging

- [ ] **Step 1: Clean build**

Run: `gradlew clean buildPlugin`
Expected: BUILD SUCCESSFUL

- [ ] **Step 2: Verify plugin zip exists**

Run: `ls -la build/distributions/`
Expected: `dataworks-sql-format-plugin-1.0.0.zip` exists

- [ ] **Step 3: Final commit**

```
git add dataworks-sql-format-plugin/
git commit -m "chore: final build verification"
```
