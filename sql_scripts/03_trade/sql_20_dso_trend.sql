-- ============================================================
-- SQL-20：DSO（应收账款周转天数）按月趋势
-- 学到的SQL概念：DSO公式 = 应收/营收×天数 / 趋势监控
-- DSO是衡量回款速度的核心指标，越低越好
-- ============================================================

WITH monthly_ar AS (
    -- 每月末未付款的采购订单 = 应收账款余额
    SELECT
        DATE_FORMAT(payment_due_date, '%Y-%m') AS period,
        SUM(amount) AS ar_balance
    FROM purchase_order
    WHERE payment_status = 'Unpaid'
    GROUP BY DATE_FORMAT(payment_due_date, '%Y-%m')
),
monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS period,
        SUM(amount) AS revenue
    FROM sales_order
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    mr.period,
    ROUND(mr.revenue, 2) AS monthly_revenue,
    ROUND(COALESCE(mar.ar_balance, 0), 2) AS ar_balance,
    -- DSO = (AR / Revenue) * 30  (月度口径)
    ROUND(COALESCE(mar.ar_balance / mr.revenue * 30, 0), 1) AS dso_days,
    -- 预警
    CASE
        WHEN COALESCE(mar.ar_balance / mr.revenue * 30, 0) > 45 THEN 'DSO偏高'
        WHEN COALESCE(mar.ar_balance / mr.revenue * 30, 0) > 30 THEN '注意监控'
        ELSE '健康'
    END AS dso_alert
FROM monthly_revenue mr
LEFT JOIN monthly_ar mar ON mr.period = mar.period
ORDER BY mr.period DESC;
