-- ============================================================
-- SQL-30：集团合并关键指标看板（一个SQL输出所有核心KPI）
-- 学到的SQL概念：多CTE组合 / UNION ALL / 一体化查询
-- 用途：Power BI 导入此查询即可直接生成 C-level 看板
-- ============================================================

WITH revenue_kpi AS (
    SELECT '营收' AS kpi_name,
           '集团总计' AS entity,
           ROUND(SUM(revenue), 0) AS value,
           '元' AS unit
    FROM income_statement
),
profit_kpi AS (
    SELECT '净利润', '集团总计', ROUND(SUM(net_profit), 0), '元' FROM income_statement
),
margin_kpi AS (
    SELECT '净利率', '集团总计',
           ROUND(SUM(net_profit) / NULLIF(SUM(revenue), 0) * 100, 2), '%'
    FROM income_statement
),
manufacturing_rev AS (
    SELECT '制造板块营收', '青城重工', ROUND(SUM(revenue), 0), '元'
    FROM income_statement WHERE company_id = 1
),
trade_rev AS (
    SELECT '贸易板块营收', '青城贸易', ROUND(SUM(revenue), 0), '元'
    FROM income_statement WHERE company_id = 2
),
software_rev AS (
    SELECT '软件板块营收', '青城科技', ROUND(SUM(revenue), 0), '元'
    FROM income_statement WHERE company_id = 3
),
cross_border_kpi AS (
    SELECT '跨境项目累计利润', '跨境合计',
           ROUND(SUM(cumulative_profit), 0), '元'
    FROM cross_border_project
),
fx_kpi AS (
    SELECT '汇兑损益合计', '跨境合计',
           ROUND(SUM(amount_foreign * cbp.contract_exchange_rate - fxt.amount_rmb), 0), '元'
    FROM fx_transaction fxt
    JOIN cross_border_project cbp ON fxt.project_id = cbp.project_id
)

SELECT * FROM revenue_kpi
UNION ALL SELECT * FROM profit_kpi
UNION ALL SELECT * FROM margin_kpi
UNION ALL SELECT * FROM manufacturing_rev
UNION ALL SELECT * FROM trade_rev
UNION ALL SELECT * FROM software_rev
UNION ALL SELECT * FROM cross_border_kpi
UNION ALL SELECT * FROM fx_kpi;
