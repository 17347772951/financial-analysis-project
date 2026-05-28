-- ============================================================
-- SQL-14：按地区/销售类型维度销售收入和毛利率对比
-- 学到的SQL概念：CUBE式多维聚合 / 内外销对比
-- ============================================================

SELECT
    so.sale_type,
    c.region,
    COUNT(so.order_id)                                  AS order_count,
    ROUND(SUM(so.amount), 2)                            AS revenue,
    ROUND(SUM(so.amount - so.cost_amount), 2)             AS gross_profit,
    ROUND((SUM(so.amount) - SUM(so.cost_amount))
          / SUM(so.amount) * 100, 2)                    AS gross_margin_pct,
    -- 平均订单额
    ROUND(SUM(so.amount) / COUNT(so.order_id), 2)         AS avg_order_value
FROM sales_order so
JOIN customer c ON so.customer_id = c.customer_id
GROUP BY so.sale_type, c.region
ORDER BY revenue DESC;
