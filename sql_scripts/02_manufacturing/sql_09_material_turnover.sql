-- ============================================================
-- SQL-09：原材料周转率 & 周转天数
-- 学到的SQL概念：周转率公式 = 耗用成本 / 平均库存
-- 周转天数 = 360 / 周转率（天数越短，周转越快）
-- ============================================================

WITH monthly_material_usage AS (
    -- 每月原材料耗用 = 当月生产订单的原材料成本汇总
    SELECT
        DATE_FORMAT(po.order_date, '%Y-%m') AS period,
        SUM(po.raw_material_cost) AS material_used
    FROM production_order po
    WHERE po.actual_quantity > 0
    GROUP BY DATE_FORMAT(po.order_date, '%Y-%m')
),
annual_usage AS (
    -- 年度总耗用（用于计算年度周转率）
    SELECT
        LEFT(period, 4) AS year,
        SUM(material_used) AS annual_material_used,
        -- 假设平均库存为年度耗用的1/6（即约2个月库存水平）
        SUM(material_used) / 6 AS avg_inventory
    FROM monthly_material_usage
    GROUP BY LEFT(period, 4)
)
SELECT
    year,
    ROUND(annual_material_used, 2) AS annual_material_used,
    ROUND(avg_inventory, 2)         AS estimated_avg_inventory,
    -- 周转率 = 耗用 / 平均库存
    ROUND(annual_material_used / avg_inventory, 2) AS turnover_rate,
    -- 周转天数 = 360 / 周转率
    ROUND(360 / (annual_material_used / avg_inventory), 1) AS turnover_days
FROM annual_usage
ORDER BY year;
