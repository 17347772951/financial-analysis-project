-- ============================================================
-- SQL-11：制造费用分摊明细（按产品 + 月份）
-- 学到的SQL概念：费用分摊逻辑 / 工时费率 / 多维度分析
-- 面试能讲：制造费用按工时分摊到产品
-- ============================================================

SELECT
    DATE_FORMAT(po.order_date, '%Y-%m') AS period,
    p.product_name,

    -- 产量
    SUM(po.actual_quantity)                                   AS total_output,

    -- 工时
    SUM(po.labor_hours)                                       AS total_labor_hours,
    SUM(po.machine_hours)                                     AS total_machine_hours,

    -- 制造费用总额
    ROUND(SUM(po.overhead_cost), 2)                           AS total_overhead,

    -- 制造费用小时费率 = 制造费用 / 工时
    ROUND(SUM(po.overhead_cost) / NULLIF(SUM(po.labor_hours), 0), 2) AS overhead_rate_per_hour,

    -- 单位产品制造费用
    ROUND(SUM(po.overhead_cost) / NULLIF(SUM(po.actual_quantity), 0), 2) AS overhead_per_unit,

    -- 制造费用占总成本比
    ROUND(SUM(po.overhead_cost) / NULLIF(SUM(po.total_cost), 0) * 100, 2) AS overhead_pct,

    COUNT(*) AS batch_count

FROM production_order po
JOIN product p ON po.product_id = p.product_id
WHERE po.actual_quantity > 0
GROUP BY DATE_FORMAT(po.order_date, '%Y-%m'), p.product_id, p.product_name

ORDER BY period DESC, p.product_name;
