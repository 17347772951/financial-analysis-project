-- ============================================================
-- SQL-29：各业态ROE/ROA对比（简化版）
-- ROE = 净利润 / 净资产（这里用利润表数据简化计算）
-- ROA = 净利润 / 总资产
-- 学到的SQL概念：财务比率 / 跨表计算
-- ============================================================

WITH annual_profit AS (
    SELECT
        ci.company_type,
        LEFT(period, 4) AS year,
        SUM(revenue)     AS revenue,
        SUM(net_profit)  AS net_profit
    FROM income_statement
    JOIN company_info ci ON income_statement.company_id = ci.company_id
    GROUP BY ci.company_type, LEFT(period, 4)
)
SELECT
    company_type,
    year,
    ROUND(revenue, 2)    AS revenue,
    ROUND(net_profit, 2) AS net_profit,

    -- 利润率
    ROUND(net_profit / NULLIF(revenue, 0) * 100, 2) AS net_margin_pct,

    -- 简化的ROE（假设净资产约为营收的30%/20%/50% 对应制造/贸易/软件）
    ROUND(net_profit / NULLIF(revenue *
        CASE
            WHEN company_type LIKE _utf8mb4'%制造%' THEN 0.30
            WHEN company_type LIKE _utf8mb4'%贸易%' THEN 0.20
            WHEN company_type LIKE _utf8mb4'%软件%' THEN 0.50
            ELSE 0.25
        END, 0) * 100, 2) AS estimated_roe_pct

FROM annual_profit
ORDER BY year DESC, company_type;
