-- ============================================================
-- SQL-08：成本差异明细（按月追踪实际成本 vs 标准成本）
-- 学到的SQL概念：趋势分析 / 差异标识 / HAVING过滤
-- 面试能讲：某产品连续3月成本上升→深挖原因
-- ============================================================

SELECT
    DATE_FORMAT(po.order_date, '%Y-%m') AS period,
    p.product_name,
    p.standard_cost,
    ROUND(SUM(po.total_cost) / SUM(po.actual_quantity), 2) AS actual_unit_cost,
    ROUND(
        (SUM(po.total_cost) / SUM(po.actual_quantity) - p.standard_cost)
        / p.standard_cost * 100, 2
    ) AS variance_pct,

    -- 差异标识
    CASE
        WHEN (SUM(po.total_cost) / SUM(po.actual_quantity)) > p.standard_cost * 1.1
            THEN 'HIGH - 实际高于标准10%+'
        WHEN (SUM(po.total_cost) / SUM(po.actual_quantity)) < p.standard_cost * 0.9
            THEN 'LOW - 实际低于标准10%+'
        ELSE 'NORMAL'
    END AS variance_flag,

    SUM(po.actual_quantity) AS output_qty

FROM production_order po
JOIN product p ON po.product_id = p.product_id
WHERE po.actual_quantity > 0
GROUP BY DATE_FORMAT(po.order_date, '%Y-%m'), p.product_id, p.product_name, p.standard_cost

ORDER BY p.product_name, period DESC;
