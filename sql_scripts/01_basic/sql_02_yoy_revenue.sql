-- ============================================================
-- SQL-02：营收同比分析（Year-over-Year）
-- 学到的SQL概念：窗口函数 LAG() / 同比公式 / CTE(WITH子句)
-- 面试高频考点：LAG函数取去年同期值，实现同比计算
-- ============================================================

WITH monthly_revenue AS (
    -- ① 先用子查询把每个月每家公司的营收汇总好
    SELECT
        DATE_FORMAT(so.order_date, '%Y-%m') AS period,
        so.company_id,
        SUM(so.amount) AS revenue
    FROM sales_order so
    GROUP BY DATE_FORMAT(so.order_date, '%Y-%m'), so.company_id
)
SELECT
    cur.period,
    ci.company_name,
    ci.company_type,
    cur.revenue                                    AS current_revenue,       -- 本期营收
    prev.revenue                                   AS last_year_revenue,     -- 去年同期营收

    -- ② 同比 = (本期 - 同期) / 同期
    ROUND((cur.revenue - prev.revenue) / prev.revenue * 100, 2) AS yoy_pct   -- 同比增长率(%)

FROM monthly_revenue cur
LEFT JOIN monthly_revenue prev
    ON cur.company_id = prev.company_id
    AND prev.period = DATE_FORMAT(
        STR_TO_DATE(CONCAT(cur.period, '-01'), '%Y-%m-%d') - INTERVAL 1 YEAR,
        '%Y-%m'
    )   -- ③ 把当前月份倒退12个月得到去年同期

JOIN company_info ci ON cur.company_id = ci.company_id

WHERE prev.revenue IS NOT NULL   -- 过滤掉没有去年同期数据的行（2023年）

ORDER BY cur.period DESC, ci.company_name;
