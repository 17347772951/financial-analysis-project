-- ============================================================
-- SQL-10：产成品库存周转率 & 周转天数
-- 学到的SQL概念：产销联动 / 库存分析
-- 周转率 = 销售成本 / 平均产成品库存
-- 数字越高=库存卖得越快
-- ============================================================

WITH monthly_cogs AS (
    -- 每月销售成本（从销售订单取制造公司的成本）
    SELECT
        DATE_FORMAT(so.order_date, '%Y-%m') AS period,
        SUM(so.cost_amount) AS cogs
    FROM sales_order so
    WHERE so.company_id = 1  -- 只取制造公司
    GROUP BY DATE_FORMAT(so.order_date, '%Y-%m')
),
annual_cogs AS (
    SELECT
        LEFT(period, 4) AS year,
        SUM(cogs) AS annual_cogs,
        SUM(cogs) / 12 AS monthly_avg_cogs
    FROM monthly_cogs
    GROUP BY LEFT(period, 4)
),
annual_production AS (
    -- 年度产量
    SELECT
        LEFT(DATE_FORMAT(po.order_date, '%Y-%m'), 4) AS year,
        SUM(po.total_cost) AS annual_production_cost
    FROM production_order po
    WHERE po.actual_quantity > 0
    GROUP BY LEFT(DATE_FORMAT(po.order_date, '%Y-%m'), 4)
)
SELECT
    ac.year,
    ROUND(ac.annual_cogs, 2)            AS annual_cogs,
    ROUND(ap.annual_production_cost, 2) AS annual_production_cost,
    -- 假设产成品库存 = (期初+期末)/2 → 简化：平均库存≈1个月产量
    ROUND(ac.monthly_avg_cogs, 2)       AS estimated_avg_inventory,

    -- 周转率
    ROUND(ac.annual_cogs / ac.monthly_avg_cogs, 2) AS turnover_rate,

    -- 周转天数
    ROUND(360 / (ac.annual_cogs / ac.monthly_avg_cogs), 1) AS turnover_days

FROM annual_cogs ac
JOIN annual_production ap ON ac.year = ap.year
ORDER BY ac.year;
