-- ============================================================
-- SQL-27：集团合并利润表（按年度汇总）
-- 学到的SQL概念：合并报表 / ROLLUP式汇总
-- ============================================================

SELECT
    LEFT(period, 4) AS year,
    ci.company_name,
    ci.company_type,
    ROUND(SUM(revenue), 2)           AS revenue,
    ROUND(SUM(cost_of_sales), 2)      AS cost_of_sales,
    ROUND(SUM(gross_profit), 2)       AS gross_profit,
    ROUND(SUM(total_expense), 2)      AS total_expense,
    ROUND(SUM(operating_profit), 2)   AS operating_profit,
    ROUND(SUM(other_income), 2)       AS other_income,
    ROUND(SUM(net_profit), 2)         AS net_profit,
    ROUND(AVG(gross_margin) * 100, 2) AS avg_gross_margin_pct,
    ROUND(AVG(net_margin) * 100, 2)   AS avg_net_margin_pct
FROM income_statement
JOIN company_info ci ON income_statement.company_id = ci.company_id
GROUP BY LEFT(period, 4), ci.company_id, ci.company_name, ci.company_type
ORDER BY year DESC, ci.company_name;
