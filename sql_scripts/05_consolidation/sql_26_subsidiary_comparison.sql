-- ============================================================
-- SQL-26：各子公司（制造/贸易/软件）营收利润对比
-- 学到的SQL概念：多维度对比 / 横向分析
-- ============================================================

SELECT
    ci.company_name,
    ci.company_type,
    ROUND(SUM(so.amount), 2)                              AS total_revenue,
    ROUND(SUM(so.amount - so.cost_amount), 2)               AS total_gross_profit,
    ROUND((SUM(so.amount) - SUM(so.cost_amount))
          / SUM(so.amount) * 100, 2)                       AS gross_margin_pct,
    COUNT(DISTINCT so.order_id)                             AS order_count,
    COUNT(DISTINCT so.customer_id)                          AS customer_count,
    ROUND(SUM(so.amount) / COUNT(DISTINCT so.order_id), 2)  AS avg_order_value
FROM sales_order so
JOIN company_info ci ON so.company_id = ci.company_id
GROUP BY ci.company_id, ci.company_name, ci.company_type
ORDER BY total_revenue DESC;
