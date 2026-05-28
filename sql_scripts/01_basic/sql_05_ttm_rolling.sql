-- ============================================================
-- SQL-05：滚动12个月（TTM）营收和利润
-- 学到的SQL概念：窗口函数 + ROWS 范围 / 滚动汇总
-- TTM = Trailing Twelve Months = 过去12个月的滚动值
-- ============================================================

WITH monthly_finance AS (
    SELECT
        DATE_FORMAT(so.order_date, '%Y-%m') AS period,
        ci.company_name,
        ci.company_type,
        SUM(so.amount)               AS revenue,
        SUM(so.amount - so.cost_amount) AS gross_profit
    FROM sales_order so
    JOIN company_info ci ON so.company_id = ci.company_id
    GROUP BY DATE_FORMAT(so.order_date, '%Y-%m'), ci.company_name, ci.company_type
)
SELECT
    period,
    company_name,
    company_type,
    revenue                                                    AS monthly_revenue,
    gross_profit                                               AS monthly_gross_profit,

    -- ★ 滚动12个月营收：取当前行+前11行求和
    -- ROWS BETWEEN 11 PRECEDING AND CURRENT ROW = 包含当前行往前11行，共12行
    SUM(revenue) OVER (
        PARTITION BY company_name
        ORDER BY period
        ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ) AS ttm_revenue,

    SUM(gross_profit) OVER (
        PARTITION BY company_name
        ORDER BY period
        ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ) AS ttm_gross_profit

FROM monthly_finance
ORDER BY period DESC, company_name;
