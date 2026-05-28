-- ============================================================
-- SQL-12：按产品维度毛利/毛利率/销售额占比
-- 学到的SQL概念：多维分组 / 毛利贡献分析
-- ============================================================

SELECT
    p.product_name,
    p.product_type,
    p.category,
    ci.company_name,

    COUNT(so.order_id)                          AS order_count,
    SUM(so.quantity)                            AS total_quantity,
    ROUND(SUM(so.amount), 2)                    AS revenue,
    ROUND(SUM(so.cost_amount), 2)               AS cost_total,
    ROUND(SUM(so.amount) - SUM(so.cost_amount), 2) AS gross_profit,
    ROUND((SUM(so.amount) - SUM(so.cost_amount))
          / SUM(so.amount) * 100, 2)            AS gross_margin_pct,

    -- 销售额占集团总营收的比例
    ROUND(SUM(so.amount) / (
        SELECT SUM(amount) FROM sales_order
    ) * 100, 2)                                 AS revenue_pct

FROM sales_order so
JOIN product p     ON so.product_id = p.product_id
JOIN company_info ci ON so.company_id = ci.company_id

GROUP BY p.product_id, p.product_name, p.product_type, p.category, ci.company_name
ORDER BY revenue DESC;
