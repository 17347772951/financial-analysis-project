-- ============================================================
-- SQL-25：汇率敏感性分析 ★★★★ 面试差异化卖点
-- 模拟汇率变动 ±1%/±3%/±5% 对项目利润的影响
-- 学到的SQL概念：场景分析 / 参数化计算
-- ============================================================

WITH project_summary AS (
    SELECT
        cbp.project_id,
        cbp.project_name,
        cbp.contract_amount,
        cbp.currency,
        cbp.contract_exchange_rate,
        cbp.cumulative_revenue,
        cbp.cumulative_profit,
        -- 未结算的外币余额（合同额 - 已结算比例 × 合同额）
        cbp.contract_amount * 10000 * (1 - cbp.project_progress / 100) AS unsettled_foreign,
        cbp.project_progress
    FROM cross_border_project cbp
)
SELECT
    project_name,
    currency,
    ROUND(contract_amount, 2)           AS contract_amount_wan,
    contract_exchange_rate,
    ROUND(cumulative_profit, 2)         AS current_profit,
    ROUND(unsettled_foreign, 2)         AS unsettled_amount_foreign,
    project_progress,

    -- ★ 汇率 +1%（人民币贬值，合同汇率从6.85变为6.92，外币拿到的RMB增多）
    ROUND(unsettled_foreign * (contract_exchange_rate * 1.01 - contract_exchange_rate), 2) AS fx_impact_plus1pct,
    -- ★ 汇率 -1%
    ROUND(unsettled_foreign * (contract_exchange_rate * 0.99 - contract_exchange_rate), 2) AS fx_impact_minus1pct,
    -- ★ 汇率 +5%
    ROUND(unsettled_foreign * (contract_exchange_rate * 1.05 - contract_exchange_rate), 2) AS fx_impact_plus5pct,
    -- ★ 汇率 -5%
    ROUND(unsettled_foreign * (contract_exchange_rate * 0.95 - contract_exchange_rate), 2) AS fx_impact_minus5pct

FROM project_summary
ORDER BY project_id;
