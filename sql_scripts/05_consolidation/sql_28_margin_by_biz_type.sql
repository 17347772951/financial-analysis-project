-- ============================================================
-- SQL-28：各业态毛利率对比（制造 vs 贸易 vs 软件）
-- 学到的SQL概念：业态对比 / 业务特征分析
-- ============================================================

SELECT
    ci.company_type,
    LEFT(period, 4) AS year,
    ROUND(SUM(revenue), 2)           AS revenue,
    ROUND(SUM(gross_profit), 2)       AS gross_profit,
    ROUND(SUM(net_profit), 2)         AS net_profit,
    ROUND(SUM(gross_profit) / SUM(revenue) * 100, 2) AS gross_margin_pct,
    ROUND(SUM(net_profit) / SUM(revenue) * 100, 2)   AS net_margin_pct,
    -- 费用率
    ROUND(SUM(selling_expense + admin_expense + rd_expense + finance_expense)
          / SUM(revenue) * 100, 2)    AS expense_ratio_pct
FROM income_statement
JOIN company_info ci ON income_statement.company_id = ci.company_id
GROUP BY ci.company_type, LEFT(period, 4)
ORDER BY year DESC, ci.company_type;
