package com.peach.sqlformat.engine;

import java.util.*;

public class KeywordDictionary {

    private static final Set<String> MULTI_WORD_KEYWORDS = Collections.unmodifiableSet(new LinkedHashSet<>(Arrays.asList(
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
    )));

    private static final int MAX_MULTI_WORD_LENGTH = MULTI_WORD_KEYWORDS.stream()
            .mapToInt(mw -> mw.split(" ").length)
            .max().orElse(0);

    private static final Set<String> KEYWORDS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            "SELECT", "FROM", "WHERE", "AND", "OR", "ON", "AS", "IN", "NOT",
            "INSERT", "OVERWRITE", "TABLE", "INTO", "VALUES",
            "LEFT", "RIGHT", "FULL", "INNER", "CROSS", "JOIN", "ANTI", "SEMI", "OUTER",
            "UNION", "ALL", "DISTINCT",
            "ORDER", "GROUP", "BY", "PARTITION", "CLUSTER", "DISTRIBUTE", "SORT",
            "HAVING", "LIMIT", "OFFSET",
            "SET", "CREATE", "ALTER", "DROP", "ADD",
            "ELSE", "THEN", "END", "CASE", "WHEN",
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
            "ARRAY", "STRUCT", "UNIONTYPE",
            "COMMENT",
            "PARTITIONED",
            "ROW", "FORMAT", "DELIMITED", "FIELDS", "TERMINATED",
            "LINES", "STORED", "FILEFORMAT",
            "INPUTFORMAT", "OUTPUTFORMAT",
            "LOCATION",
            "TBLPROPERTIES"
    )));

    private static final Set<String> FUNCTIONS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            "nvl", "coalesce", "if",
            "get_json_object", "json_tuple", "from_json", "to_json",
            "split", "size", "concat", "concat_ws",
            "substr", "substring", "trim", "ltrim", "rtrim",
            "upper", "lower", "length", "replace", "regexp_replace",
            "regexp_extract",
            "date_format", "date_add", "date_sub", "datediff",
            "from_unixtime", "unix_timestamp", "to_date",
            "year", "month", "day", "hour", "minute", "second",
            "row_number", "rank", "dense_rank", "ntile", "lag", "lead",
            "first_value", "last_value",
            "sum", "count", "max", "min", "avg",
            "collect_list", "collect_set",
            "explode", "posexplode",
            "parse_url", "space", "repeat",
            "abs", "ceil", "floor", "round", "pow", "sqrt",
            "rand",
            "greatest", "least",
            "str_to_map", "map_keys", "map_values",
            "typed", "named_struct",
            "encode", "decode",
            "assert_true",
            "current_date", "current_timestamp",
            "next_day", "last_day", "trunc",
            "weekofyear", "dayofmonth", "dayofyear",
            "months_between", "add_months",
            "cast"
    )));

    private KeywordDictionary() {}

    /** Check if text (case-insensitive) starts with a multi-word keyword prefix */
    public static String matchMultiWordKeyword(String text) {
        String upper = text.toUpperCase();
        for (String mw : MULTI_WORD_KEYWORDS) {
            if (upper.startsWith(mw)) {
                return mw;
            }
        }
        return null;
    }

    /** Check if the single word is a keyword (case-insensitive) */
    public static boolean isKeyword(String word) {
        return KEYWORDS.contains(word.toUpperCase());
    }

    /** Check if the word is a known function name (case-insensitive) */
    public static boolean isFunction(String word) {
        return FUNCTIONS.contains(word.toLowerCase());
    }

    public static int maxMultiWordKeywordLength() {
        return MAX_MULTI_WORD_LENGTH;
    }

    public static Set<String> getMultiWordKeywords() {
        return MULTI_WORD_KEYWORDS;
    }
}
