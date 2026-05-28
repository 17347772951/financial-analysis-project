-- ============================================================
-- SQL-17：逾期应收账款明细（实际付款 > 约定付款日期）
-- 学到的SQL概念：日期比较 / 逾期天数计算
-- ============================================================

SELECT
    po.order_no,
    po.supplier_name,
    po.order_date,
    po.amount,
    po.payment_due_date,
    po.actual_pay_date,
    DATEDIFF(COALESCE(po.actual_pay_date, CURDATE()), po.payment_due_date) AS overdue_days,
    CASE
        WHEN DATEDIFF(COALESCE(po.actual_pay_date, CURDATE()), po.payment_due_date) <= 0
            THEN 'On Time'
        WHEN DATEDIFF(COALESCE(po.actual_pay_date, CURDATE()), po.payment_due_date) <= 30
            THEN '1-30 Days'
        WHEN DATEDIFF(COALESCE(po.actual_pay_date, CURDATE()), po.payment_due_date) <= 60
            THEN '31-60 Days'
        WHEN DATEDIFF(COALESCE(po.actual_pay_date, CURDATE()), po.payment_due_date) <= 90
            THEN '61-90 Days'
        ELSE '90+ Days - HIGH RISK'
    END AS overdue_level
FROM purchase_order po
WHERE po.payment_status = 'Unpaid'
   OR (po.payment_status = 'Paid' AND po.actual_pay_date > po.payment_due_date)
ORDER BY overdue_days DESC;
