-- ============================================================
-- SQL-06：单位产品成本计算 ★★★ 面试必考题
-- 核心逻辑：单位成本 = 原材料成本 + 人工成本 + 制造费用
-- 原材料成本从 BOM 表计算（用量 × 单价）
-- 人工和制造费用从生产订单取（按实际产量分摊）
-- ============================================================

-- ① 从 BOM 表算出每件产品的标准原材料成本
WITH material_cost_per_product AS (
    SELECT
        product_id,
        SUM(quantity * unit_price) AS std_material_cost  -- 标准原材料成本
    FROM bom
    GROUP BY product_id
),
-- ② 从生产订单算出每件产品的实际生产成本
actual_cost_per_product AS (
    SELECT
        product_id,
        SUM(actual_quantity)                        AS total_quantity,
        SUM(raw_material_cost)                      AS total_material_cost,
        SUM(labor_cost)                             AS total_labor_cost,
        SUM(overhead_cost)                          AS total_overhead_cost,
        SUM(total_cost)                             AS total_cost_all,
        -- 单位成本 = 总成本 / 总产量
        ROUND(SUM(total_cost) / SUM(actual_quantity), 2) AS actual_unit_cost
    FROM production_order
    WHERE actual_quantity > 0
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.product_type,
    p.standard_cost,

    -- BOM 标准原材料成本
    ROUND(mc.std_material_cost, 2)      AS std_material_per_unit,

    -- 实际单位成本拆解
    ROUND(ac.total_material_cost / ac.total_quantity, 2)  AS actual_material_per_unit,
    ROUND(ac.total_labor_cost / ac.total_quantity, 2)     AS actual_labor_per_unit,
    ROUND(ac.total_overhead_cost / ac.total_quantity, 2)  AS actual_overhead_per_unit,
    ac.actual_unit_cost                                    AS actual_total_unit_cost,

    -- 成本差异
    ROUND(ac.actual_unit_cost - p.standard_cost, 2)        AS cost_variance,
    ROUND((ac.actual_unit_cost - p.standard_cost) / p.standard_cost * 100, 2) AS variance_pct,

    -- 产量
    ac.total_quantity AS total_produced

FROM product p
JOIN material_cost_per_product mc ON p.product_id = mc.product_id
JOIN actual_cost_per_product ac     ON p.product_id = ac.product_id

ORDER BY p.product_id;
