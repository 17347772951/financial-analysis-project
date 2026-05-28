-- ============================================================
-- SQL-07：成本结构分析（料/工/费 占比）
-- 学到的SQL概念：CASE WHEN / 占比计算 / CONCAT
-- 面试能讲清楚：制造业成本中原材料占60%、人工20%、制造费用20%
-- ============================================================

SELECT
    p.product_name,
    COUNT(po.order_id) AS batch_count,
    SUM(po.actual_quantity) AS total_output,

    -- 原材料成本及占比
    ROUND(SUM(po.raw_material_cost), 2) AS total_material,
    ROUND(SUM(po.raw_material_cost) / SUM(po.total_cost) * 100, 2) AS material_pct,

    -- 人工成本及占比
    ROUND(SUM(po.labor_cost), 2) AS total_labor,
    ROUND(SUM(po.labor_cost) / SUM(po.total_cost) * 100, 2) AS labor_pct,

    -- 制造费用及占比
    ROUND(SUM(po.overhead_cost), 2) AS total_overhead,
    ROUND(SUM(po.overhead_cost) / SUM(po.total_cost) * 100, 2) AS overhead_pct,

    -- 总成本
    ROUND(SUM(po.total_cost), 2) AS total_cost,

    -- 单位成本
    ROUND(SUM(po.total_cost) / SUM(po.actual_quantity), 2) AS unit_cost

FROM production_order po
JOIN product p ON po.product_id = p.product_id
WHERE po.actual_quantity > 0
GROUP BY p.product_id, p.product_name
ORDER BY total_cost DESC;
