-- ============================================================
-- SQL-03：营收环比分析（Month-over-Month）
-- 学到的SQL概念：LAG() 窗口函数 ★★★ 面试必考题
-- LAG(字段, 偏移量, 默认值) 取前面第N行的值
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(so.order_date, '%Y-%m') AS period,
        so.company_id,
        SUM(so.amount) AS revenue
    FROM sales_order so
    GROUP BY DATE_FORMAT(so.order_date, '%Y-%m'), so.company_id
)
SELECT
    period,
    ci.company_name,
    ci.company_type,
    revenue,

    -- ★ LAG函数：取同一家公司上个月的营收
    -- LAG(revenue, 1) = 取前一行的revenue值
    LAG(revenue, 1) OVER (
        PARTITION BY mr.company_id     -- 按公司分组（每家独立计算）
        ORDER BY mr.period             -- 按时间排序
    ) AS last_month_revenue,

    -- 环比增长率 = (本月 - 上月) / 上月
    ROUND(
        (revenue - LAG(revenue, 1) OVER (
            PARTITION BY mr.company_id ORDER BY mr.period
        )) / LAG(revenue, 1) OVER (
            PARTITION BY mr.company_id ORDER BY mr.period
        ) * 100,
        2
    ) AS mom_pct

FROM monthly_revenue mr
JOIN company_info ci ON mr.company_id = ci.company_id

ORDER BY mr.period DESC, ci.company_name;
