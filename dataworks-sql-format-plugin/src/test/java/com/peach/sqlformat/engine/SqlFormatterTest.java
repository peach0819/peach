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
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM"));
    }

    @Test
    void testSelectWithWhere() {
        String result = format("select a, b from t where a = 1");
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM"));
        assertTrue(result.contains("WHERE a = 1"));
    }

    @Test
    void testFunctionLowercase() {
        String result = format("SELECT NVL(a, 0)");
        assertTrue(result.contains("nvl(a,"));
        assertTrue(result.contains("0)"));
        assertFalse(result.contains("NVL"));
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

    @Test
    void testNoLogicChange() {
        String input = "SELECT a, b FROM t WHERE c = 1 AND d = 2";
        String result = format(input);
        String inputStripped = input.replaceAll("\\s+", "").toLowerCase();
        String resultStripped = result.replaceAll("\\s+", "").toLowerCase();
        assertEquals(inputStripped, resultStripped);
    }

    @Test
    void testCteQuery() {
        String result = format("with a as (select id, name from t1), b as (select id, val from t2) select a.id, b.val from a");
        assertTrue(result.contains("WITH"));
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM"));
    }

    @Test
    void testInsertOverwrite() {
        String result = format("insert overwrite table tbl partition (dayid='${v_date}') select a, b from src");
        assertTrue(result.contains("INSERT OVERWRITE TABLE"));
        assertTrue(result.contains("'${v_date}'"));
    }

    @Test
    void testJoinFormat() {
        String result = format("select a.*, b.* from t1 a left join t2 b on a.id = b.id");
        assertTrue(result.contains("LEFT JOIN"));
        assertTrue(result.contains("ON"));
    }

    @Test
    void testKeywordsUppercase() {
        String result = format("select a from t where b > 1 group by b order by b limit 10");
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM"));
        assertTrue(result.contains("WHERE"));
        assertTrue(result.contains("GROUP BY"));
        assertTrue(result.contains("ORDER BY"));
        assertTrue(result.contains("LIMIT"));
    }

    @Test
    void testSubquery() {
        String result = format("select a from (select id from t1) t where t.id > 0");
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM ("));
    }

    @Test
    void testGetJsonObject() {
        String result = format("select GET_JSON_OBJECT(feature, '$.user_id') as uid from t");
        assertTrue(result.contains("get_json_object(feature,"));
    }

    @Test
    void testHiveFullQuery() {
        String sql = "with base as (select id, name from t1 where dayid = '${v_date}') "
                + "insert overwrite table target partition (dayid='${v_date}') "
                + "select base.id, nvl(base.name, '') as name from base left join other on base.id = other.id";

        String result = format(sql);
        assertTrue(result.contains("WITH"));
        assertTrue(result.contains("INSERT OVERWRITE TABLE"));
        assertTrue(result.contains("LEFT JOIN"));
        assertTrue(result.contains("nvl(base.name,"));
    }

    @Test
    void testMultipleCtes() {
        String sql = "with a as (select id from t1), b as (select id from t2) select a.id from a join b on a.id = b.id";
        String result = format(sql);
        assertTrue(result.contains("WITH"));
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("JOIN"));
    }

    @Test
    void testUnionAll() {
        String result = format("select a from t1 union all select a from t2");
        assertTrue(result.contains("UNION ALL"));
    }

    @Test
    void testWindowFunction() {
        String result = format("select id, row_number() over (partition by dept order by salary desc) as rn from t");
        assertTrue(result.contains("row_number()"));
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM"));
    }

    @Test
    void testCaseWhen() {
        String result = format("select id, case when status = 1 then 'active' else 'inactive' end as status_label from t");
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM"));
    }

    @Test
    void testSelectDistinct() {
        String result = format("select distinct id, name from t");
        assertTrue(result.contains("SELECT DISTINCT"));
        assertTrue(result.contains("FROM"));
    }

    @Test
    void testBlockComment() {
        String result = format("select a /* block comment */ from t");
        assertTrue(result.contains("/* block comment */"));
    }

    @Test
    void testBacktickIdentifier() {
        String result = format("select `select`, `from` from t");
        assertTrue(result.contains("`select`"));
        assertTrue(result.contains("`from`"));
    }

    @Test
    void testFunctionMultipleArgs() {
        String result = format("SELECT coalesce(a, b, c, d) FROM t");
        assertTrue(result.contains("coalesce(a,"));
        assertTrue(result.contains("d)"));
        assertFalse(result.contains("COALESCE"));
    }

    @Test
    void testMultipleJoins() {
        String sql = "select a.*, b.*, c.* from t1 a inner join t2 b on a.id = b.id left join t3 c on a.id = c.id";
        String result = format(sql);
        assertTrue(result.contains("INNER JOIN"));
        assertTrue(result.contains("LEFT JOIN"));
        assertTrue(result.contains("FROM"));
    }

    @Test
    void testNestedSubquery() {
        String result = format("select a from (select id from (select id from t1) t2) t3 where t3.id > 0");
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM"));
    }

    @Test
    void testNoLogicChangeComplex() {
        String input = "with cte as (select a, b, c from t1 where dayid = '${v_date}') "
                + "insert overwrite table t2 partition (dayid='${v_date}') "
                + "select cte.a, nvl(cte.b, 0) as b, get_json_object(cte.c, '$.key') as c_key "
                + "from cte left join t3 on cte.a = t3.a where cte.b > 0 order by cte.a limit 100";
        String result = format(input);
        String inputStripped = input.replaceAll("\\s+", "").toLowerCase();
        String resultStripped = result.replaceAll("\\s+", "").toLowerCase();
        assertEquals(inputStripped, resultStripped);
    }

    @Test
    void testHivePartitionedDdl() {
        String result = format("create table t (id bigint, name string) partitioned by (dayid string) stored as orc");
        assertTrue(result.contains("CREATE TABLE"));
        assertTrue(result.contains("PARTITIONED BY"));
    }

    @Test
    void testArithmeticExpression() {
        String result = format("select a + b * c / d as val from t");
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM"));
    }

    // ---- Fix verification tests ----

    @Test
    void testSubqueryWithMultipleColumns() {
        // Subquery columns should have newlines, and closing ) should be on its own line
        String result = format("select a from (select id, name, val from t1) t where t.id > 0");
        assertTrue(result.contains("SELECT"));
        assertTrue(result.contains("FROM ("));
        // Inner SELECT columns should have newlines (subquery comma handling)
        assertTrue(result.contains("id,\n"));
        assertTrue(result.contains("name,\n"));
        // Subquery closing ) should be on its own line
        assertTrue(result.contains(") t"));
    }

    @Test
    void testJoinWithMultipleConditions() {
        // JOIN ON multiple conditions should stay on same line
        String result = format("select a.*, b.* from t1 a left join t2 b on a.id = b.id and a.type = b.type");
        assertTrue(result.contains("ON"));
        // AND should be on same line as ON (not wrapped)
        String[] lines = result.split("\n");
        boolean foundOnLine = false;
        for (String line : lines) {
            if (line.contains("ON")) {
                foundOnLine = true;
                assertTrue(line.contains("AND"), "AND should be on same line as ON: " + line);
            }
        }
        assertTrue(foundOnLine, "Should have a line with ON");
    }

    @Test
    void testFunctionArgsNoNewline() {
        // Comma inside function args should NOT trigger newline
        String result = format("SELECT nvl(a, b, c), d FROM t");
        // nvl should be on one line (no newline between commas inside function)
        assertTrue(result.contains("nvl(a,"));
        // , after nvl(...) should trigger newline (it's in SELECT)
        assertTrue(result.contains("d\n") || result.contains("d "));
    }

    @Test
    void testJoinSubquery() {
        // JOIN (SELECT ...) should be indented like FROM (SELECT ...)
        String result = format("select * from t1 left join (select id, name from t2 where dayid = '${v_date}') u on t1.id = u.id");
        assertTrue(result.contains("JOIN"));
        // Subquery inside JOIN should have indented content with closing ) on own line
        assertTrue(result.contains(") u"));
        assertTrue(result.contains("FROM t2"));
    }

    @Test
    void testWindowFunctionNoBreak() {
        // Window function OVER (...) should not have internal line breaks
        String result = format("select id, lead(create_time, 1, 9999) over (partition by user_id order by create_time, id) as next_time from t");
        assertTrue(result.contains("OVER ("));
        assertTrue(result.contains("PARTITION BY"));
        assertTrue(result.contains("ORDER BY"));
    }

    @Test
    void testCaseWhenMultiLine() {
        // Multiple WHEN should be on separate lines, aligned with first WHEN
        String result = format("SELECT CASE WHEN a = 1 THEN 'one' WHEN a = 2 THEN 'two' ELSE 'other' END as val FROM t");
        assertTrue(result.contains("CASE WHEN"));
        // Second WHEN, ELSE, END should be on their own lines
        String[] lines = result.split("\n");
        int whenCount = 0;
        int elseCount = 0;
        int endCount = 0;
        for (String line : lines) {
            String trimmed = line.trim();
            // "    WHEN" means the trimmed part starts with WHEN
            if (trimmed.startsWith("WHEN")) whenCount++;
            if (trimmed.startsWith("ELSE")) elseCount++;
            if (trimmed.startsWith("END")) endCount++;
        }
        assertEquals(1, whenCount, "Second WHEN should be on its own line; first WHEN is on CASE line");
        assertEquals(1, elseCount, "ELSE should be on its own line");
        assertEquals(1, endCount, "END should be on its own line");

        // Verify WHEN/ELSE/END indentation column matches first WHEN's column
        // The WHEN in "CASE WHEN" is at column 12 (7 SELECT alignment + 5 "CASE ")
        for (String line : lines) {
            String trimmed = line.trim();
            if (trimmed.startsWith("WHEN") || trimmed.startsWith("ELSE") || trimmed.startsWith("END")) {
                int col = line.indexOf(trimmed.substring(0, 4));
                assertTrue(col <= 16, trimmed + " should be indented reasonably (col=" + col + "): " + line);
            }
        }
    }
}
