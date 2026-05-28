-- ============================================================
-- SQL-21：跨境项目全周期收入-成本-利润跟踪 ★★★
-- 面试必讲：展示你的跨境项目财务管理能力
-- ============================================================

SELECT
    cbp.project_name,
    cbp.contract_no,
    c.customer_name,
    c.region,
    cbp.contract_amount  AS contract_amount_wan,
    cbp.currency,
    cbp.trade_terms,
    cbp.payment_method,
    cbp.contract_exchange_rate,
    cbp.tax_refund_rate,

    -- 时间线
    cbp.start_date,
    cbp.planned_end_date,
    cbp.actual_end_date,
    DATEDIFF(COALESCE(cbp.actual_end_date, cbp.planned_end_date), cbp.start_date) AS project_duration_days,

    -- 财务表现
    ROUND(cbp.cumulative_revenue, 2) AS cumulative_revenue,
    ROUND(cbp.cumulative_cost, 2)   AS cumulative_cost,
    ROUND(cbp.cumulative_profit, 2) AS cumulative_profit,
    ROUND(cbp.cumulative_profit / NULLIF(cbp.cumulative_revenue, 0) * 100, 2) AS profit_margin_pct,

    -- 出口退税估算（退税额 = 累计收入 × 退税率）
    ROUND(cbp.cumulative_revenue * cbp.tax_refund_rate / 100, 2) AS estimated_tax_refund,

    cbp.project_progress,
    cbp.status

FROM cross_border_project cbp
JOIN customer c ON cbp.customer_id = c.customer_id
ORDER BY cbp.start_date;
