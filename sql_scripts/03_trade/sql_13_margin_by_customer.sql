-- ============================================================
-- SQL-13：按客户维度毛利贡献度（识别TOP客户和亏损客户）
-- 学到的SQL概念：HAVING 过滤 / 客户分级
-- ============================================================

SELECT
    c.customer_name,
    c.customer_type,
    c.region,
    c.credit_level,

    COUNT(so.order_id)                            AS order_count,
    ROUND(SUM(so.amount), 2)                      AS revenue,
    ROUND(SUM(so.amount - so.cost_amount), 2)       AS gross_profit,
    ROUND((SUM(so.amount) - SUM(so.cost_amount))
          / SUM(so.amount) * 100, 2)              AS gross_margin_pct,

    -- 毛利贡献占比
    ROUND(
        (SUM(so.amount) - SUM(so.cost_amount)) /
        (SELECT SUM(amount - cost_amount) FROM sales_order) * 100, 2
    ) AS profit_contribution_pct,

    -- 客户分类
    CASE
        WHEN (SUM(so.amount) - SUM(so.cost_amount)) < 0 THEN 'LOSS - 亏损客户'
        WHEN SUM(so.amount) > 500000000 THEN 'VIP - 大客户'
        WHEN SUM(so.amount) > 100000000 THEN 'KEY - 重点客户'
        ELSE 'NORMAL'
    END AS customer_tier

FROM sales_order so
JOIN customer c ON so.customer_id = c.customer_id

GROUP BY c.customer_id, c.customer_name, c.customer_type, c.region, c.credit_level
ORDER BY gross_profit DESC;
