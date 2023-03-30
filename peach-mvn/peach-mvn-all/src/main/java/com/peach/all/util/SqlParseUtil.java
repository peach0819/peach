package com.peach.all.util;

import com.alibaba.druid.sql.SQLUtils;
import com.alibaba.druid.sql.ast.SQLExpr;
import com.alibaba.druid.sql.ast.SQLStatement;
import com.alibaba.druid.sql.ast.expr.SQLBinaryOpExpr;
import com.alibaba.druid.sql.ast.expr.SQLIdentifierExpr;
import com.alibaba.druid.sql.ast.expr.SQLQueryExpr;
import com.alibaba.druid.sql.ast.statement.SQLExprTableSource;
import com.alibaba.druid.sql.ast.statement.SQLJoinTableSource;
import com.alibaba.druid.sql.ast.statement.SQLSelectQuery;
import com.alibaba.druid.sql.ast.statement.SQLSelectStatement;
import com.alibaba.druid.sql.ast.statement.SQLSubqueryTableSource;
import com.alibaba.druid.sql.ast.statement.SQLTableSource;
import com.alibaba.druid.sql.ast.statement.SQLUnionQuery;
import com.alibaba.druid.sql.ast.statement.SQLUnionQueryTableSource;
import com.alibaba.druid.sql.dialect.mysql.ast.statement.MySqlSelectQueryBlock;
import com.alibaba.druid.util.JdbcConstants;
import com.peach.all.exception.PeachException;
import org.apache.commons.lang3.StringUtils;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class SqlParseUtil {

    public static Set<String> parseTablesFromSql(String sql) {
        sql = SQLUtils.formatMySql(sql);
        List<SQLStatement> sqlStatements = SQLUtils.parseStatements(sql, JdbcConstants.MYSQL);
        if (sqlStatements.size() > 1) {
            throw new PeachException("仅支持解析一条sql");
        }
        Set<String> tables = new HashSet<>();
        MySqlSelectQueryBlock queryBlock = (MySqlSelectQueryBlock) ((SQLSelectStatement) sqlStatements.get(0)).getSelect()
                .getQuery();
        //解析select条件中涉及的table
        queryBlock.getSelectList().forEach(s -> parseSQLExpr(s.getExpr(), tables));

        //解析from条件中涉及的table
        parseSqlTableSource(queryBlock.getFrom(), tables);

        //解析where条件中涉及的table
        parseSQLExpr(queryBlock.getWhere(), tables);
        return tables;
    }

    private static void parseSqlTableSource(SQLTableSource source, Set<String> tables) {
        if (source == null) {
            return;
        }
        if (source instanceof SQLJoinTableSource) {
            parseSqlJoinTableSource((SQLJoinTableSource) source, tables);
        } else if (source instanceof SQLExprTableSource) {
            parseSqlExprTableSource((SQLExprTableSource) source, tables);
        }
        if (source instanceof SQLSubqueryTableSource) {
            parseSqlSubqueryTableSource((SQLSubqueryTableSource) source, tables);
        }
        if (source instanceof SQLUnionQueryTableSource) {
            parseSqlUnionQuery(((SQLUnionQueryTableSource) source).getUnion(), tables);
        }
    }

    /**
     * join语句
     */
    private static void parseSqlJoinTableSource(SQLJoinTableSource source, Set<String> tables) {
        if (source == null) {
            return;
        }
        parseSqlTableSource(source.getRight(), tables);
        parseSqlTableSource(source.getLeft(), tables);
    }

    /**
     * 直接表达式，来源表
     */
    private static void parseSqlExprTableSource(SQLExprTableSource source, Set<String> tables) {
        if (source == null) {
            return;
        }
        SQLIdentifierExpr expr = (SQLIdentifierExpr) source.getExpr();
        String tableName = expr.getName();
        if (StringUtils.isNotBlank(tableName)) {
            tables.add(tableName);
        }
    }

    /**
     * 子查询
     */
    private static void parseSqlSubqueryTableSource(SQLSubqueryTableSource source, Set<String> tables) {
        if (source == null) {
            return;
        }
        MySqlSelectQueryBlock queryBlock = (MySqlSelectQueryBlock) source.getSelect().getQuery();
        parseSqlTableSource(queryBlock.getFrom(), tables);
    }

    /**
     * union语句
     */
    private static void parseSqlUnionQuery(SQLUnionQuery unionQuery, Set<String> tables) {
        if (unionQuery == null) {
            return;
        }
        parseSqlSelectQuery(unionQuery.getLeft(), tables);
        parseSqlSelectQuery(unionQuery.getRight(), tables);
    }

    /**
     * 解析union语句中的块查询语句
     */
    private static void parseSqlSelectQuery(SQLSelectQuery sqlSelectQuery, Set<String> tables) {
        if (sqlSelectQuery == null) {
            return;
        }
        if (sqlSelectQuery instanceof MySqlSelectQueryBlock) {
            parseSqlTableSource(((MySqlSelectQueryBlock) sqlSelectQuery).getFrom(), tables);
        } else if (sqlSelectQuery instanceof SQLUnionQuery) {
            parseSqlUnionQuery((SQLUnionQuery) sqlSelectQuery, tables);
        }
    }

    /**
     * 解析where语句中的表
     */
    private static void parseSQLExpr(SQLExpr expr, Set<String> tables) {
        if (expr == null) {
            return;
        }
        //SQLBinaryOpExpr 和 SQLQueryExpr 需要处理，SQLNullExpr 和 SQLPropertyExpr直接跳过
        if (expr instanceof SQLBinaryOpExpr) {
            parseBinaryOpExpr((SQLBinaryOpExpr) expr, tables);
        } else if (expr instanceof SQLQueryExpr) {
            parseSqlQueryExpr((SQLQueryExpr) expr, tables);
        }
    }

    /**
     * 解析二元操作条件
     */
    private static void parseBinaryOpExpr(SQLBinaryOpExpr expr, Set<String> tables) {
        if (expr == null) {
            return;
        }
        parseSQLExpr(expr.getLeft(), tables);
        parseSQLExpr(expr.getRight(), tables);
    }

    /**
     * 处理包含sql查询的条件
     */
    private static void parseSqlQueryExpr(SQLQueryExpr expr, Set<String> tables) {
        if (expr == null) {
            return;
        }
        parseSqlSelectQuery(expr.getSubQuery().getQuery(), tables);
    }


}
