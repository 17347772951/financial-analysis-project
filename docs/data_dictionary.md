# 数据字典（Data Dictionary）

> 本文档详细说明 11 张核心数据库表的字段含义、业务逻辑和设计原因。
> 面试时被问到"你的表结构是怎么设计的"，可以直接参考本文档作答。

---

## 表关系总览

```
company_info (公司信息)
    │
    ├──▶ product (产品) ──▶ bom (物料清单) ──▶ production_order (生产订单)
    │       │                                        │
    │       └──▶ sales_order (销售订单) ◀── customer (客户)
    │                │                               │
    │                └──▶ cross_border_project (跨境项目) ◀── customer
    │                         │
    │                         └──▶ fx_transaction (外汇交易)
    │
    ├──▶ purchase_order (采购订单)
    ├──▶ expense (费用明细)
    └──▶ income_statement (利润表)
```

**设计原则**：所有表都遵循"宽表+行式存储"，便于 SQL 直接 JOIN 计算，也便于 Power BI 导入后直接建模。

---

## 模块一：基础信息表（3 张）

### 1. company_info — 公司信息表

**对应你的真实工作**：青城集团下 3-4 家子公司（制造×1、贸易×2、软件×1）

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| company_id | INT PK | 自增主键 | 每张表都有独立主键，这是数据库设计的基本规范 |
| company_name | VARCHAR(50) | 公司名称（脱敏） | 不能用真实公司名，安全合规 |
| company_type | VARCHAR(20) | 制造/贸易/软件 | **面试重点**：三种业态的财务特征完全不同——制造业有BOM成本、贸易业看毛利周转、软件业看研发费用率 |
| tax_id | VARCHAR(30) | 纳税人识别号（脱敏） | 身份证号/税号这类字段必须脱敏 |

**你从这张表学到的 SQL 概念**：
- `PRIMARY KEY`：主键，每张表必须有一个唯一标识
- `AUTO_INCREMENT`：自增，插入数据时 MySQL 自动编号
- `COMMENT`：字段注释，实际工作中必须写的

---

### 2. product — 产品表

**对应你的真实工作**：制造子公司矿热炉配件、贸易子公司钢材/设备、软件子公司 ERP 系统

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| product_id | INT PK | 自增主键 | |
| product_name | VARCHAR(50) | 产品名称 | |
| product_type | VARCHAR(20) | 产成品/贸易商品/软件产品 | **关键设计**：用 product_type 区分三种业态的产品，而不是建三张表。这样 SQL 聚合时可以用 `GROUP BY product_type` 直接对比 |
| category | VARCHAR(30) | 产品分类 | 矿热炉配件/钢材/ERP系统等 |
| unit | VARCHAR(10) | 计量单位 | 台/吨/套——不同产品单位不同，影响成本计算方法 |
| standard_cost | DECIMAL(18,2) | 标准成本（元） | 成本差异分析的基础——面试时讲"实际vs标准"的差异就用它 |
| selling_price | DECIMAL(18,2) | 标准售价（元） | |
| company_id | INT FK | 所属公司 | 外键关联 company_info |

**你从这张表学到的 SQL 概念**：
- `DECIMAL(18,2)`：精确小数（金额类型必须用 DECIMAL，不能用 FLOAT，否则会有精度误差）
- `FOREIGN KEY`：外键约束，保证数据引用的完整性

---

### 3. customer — 客户表

**对应你的真实工作**：国内客户 + 海外客户（哈萨克斯坦项目客户）

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| customer_id | INT PK | 自增主键 | |
| customer_name | VARCHAR(80) | 客户名称（脱敏） | |
| customer_type | VARCHAR(20) | 国内/海外 | **区分国内/海外**，出口业务的退税和汇率管理完全不同 |
| region | VARCHAR(30) | 所在地区/国家 | 哈萨克斯坦等——面试时展示你的跨境业务经验 |
| credit_level | VARCHAR(10) | 信用等级 A/B/C/D | 客户信用评分模型的基础数据 |
| credit_limit | DECIMAL(18,2) | 信用额度（元） | 超出额度需要审批——风控意识 |
| payment_terms | VARCHAR(30) | 付款条件 | 月结30天/60天/预付款——影响DSO和现金流 |

**你从这张表学到的 SQL 概念**：
- `DEFAULT`：默认值（客户类型默认"国内"）
- 设计"信用等级"字段——这是你后面做应收账款风险评分模型的数据基础

---

## 模块二：业务表（5 张）

### 4. production_order — 生产订单表 ★★

**对应你的真实工作**：制造子公司矿热炉产品的生产管理

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| order_id | INT PK | 自增主键 | |
| order_no | VARCHAR(30) UNIQUE | 生产订单号 | UNIQUE 约束保证不重复 |
| product_id | INT FK | 产品ID | 关联 product 表 |
| planned_quantity | INT | 计划生产数量 | |
| actual_quantity | INT | 实际完工数量 | 计划vs实际=产能利用率分析 |
| raw_material_cost | DECIMAL(18,2) | 原材料成本 | 与 BOM 表的数据要逻辑一致 |
| labor_cost | DECIMAL(18,2) | 人工成本 | 按工时分摊 |
| overhead_cost | DECIMAL(18,2) | 制造费用 | 按工时分摊（约20%总成本） |
| total_cost | DECIMAL(18,2) | 总生产成本 | = 料+工+费 |
| labor_hours | DECIMAL(10,2) | 生产工时 | 费用分摊的依据 |
| machine_hours | DECIMAL(10,2) | 机器工时 | |
| status | VARCHAR(20) | 计划中/进行中/已完成/已关闭 | 跟踪生产进度 |

**面试问题**："你怎么计算单位产品成本？"
**回答框架**：`(raw_material_cost + labor_cost + overhead_cost) / actual_quantity`，其中原材料成本来自 BOM 表×实际领用，人工和制造费用按工时分摊。这个逻辑对应 production_order 表的结构。

---

### 5. bom — BOM 物料清单表 ★★★ 成本核算核心

**对应你的真实工作**：矿热炉产品的 BOM 结构（每个产品由哪些原材料组成）

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| bom_id | INT PK | 自增主键 | |
| product_id | INT FK | 产品ID | 一个产品对应多条 BOM 记录（一对多） |
| material_name | VARCHAR(50) | 原材料名称 | 钢材/铜材/焊条等 |
| material_code | VARCHAR(30) | 原材料编码 | |
| quantity | DECIMAL(10,4) | 单位用量 | 四位小数——精确到克/毫米 |
| unit | VARCHAR(10) | 用量单位 | kg/个/米 |
| unit_price | DECIMAL(18,4) | 原材料单价 | |
| material_type | VARCHAR(20) | 原材料/半成品/辅料 | 区分直接材料（进成本）和辅料（进制造费用） |

**面试问题**："产品的原材料成本怎么算？"
**回答框架**：`SUM(bom.quantity × bom.unit_price) per product`，即遍历该产品所有 BOM 行的用量×单价求和。这是成本核算最基本的 SQL JOIN 操作。

**从这张表学到的 SQL**：
- `JOIN`：BOM 表通过 product_id 和 product 表关联
- 一对多关系：一个产品有多行 BOM 记录

---

### 6. sales_order — 销售订单表 ★★

**对应你的真实工作**：贸易子公司销售 + 制造子公司内销 + 出口销售

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| order_id | INT PK | 自增主键 | |
| order_no | VARCHAR(30) UNIQUE | 销售订单号 | |
| product_id | INT FK | 产品ID | |
| customer_id | INT FK | 客户ID | |
| quantity | INT | 销售数量 | |
| unit_price | DECIMAL(18,2) | 销售单价 | |
| amount | DECIMAL(18,2) | 销售金额 | = 数量 × 单价 |
| cost_amount | DECIMAL(18,2) | 对应成本 | 用于计算毛利 |
| sale_type | VARCHAR(20) | 国内/出口 | **区分内外销**：出口有退税，外汇结算 |
| currency | VARCHAR(10) | 结算币种 | CNY/USD/EUR |
| exchange_rate | DECIMAL(10,4) | 汇率 | 出口订单填写；内销默认1 |
| payment_method | VARCHAR(30) | 收款方式 | 电汇/信用证/承兑汇票——影响现金流 |
| status | VARCHAR(20) | 状态 | 用于跟踪订单执行进度 |

**面试问题**："你怎么按产品/客户/地区分析毛利率？"
**回答框架**：`(amount - cost_amount) / amount`，在 SQL 中 `GROUP BY product_id / customer_id / region` 即可实现三维分析。

---

### 7. purchase_order — 采购订单表

**对应你的真实工作**：贸易子公司采购 + 制造子公司原材料采购

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| order_id | INT PK | 自增主键 | |
| order_no | VARCHAR(30) UNIQUE | 采购订单号 | |
| product_id | INT FK | 采购产品ID | |
| supplier_name | VARCHAR(80) | 供应商名称（脱敏） | |
| quantity | INT | 采购数量 | |
| unit_price | DECIMAL(18,2) | 采购单价 | |
| amount | DECIMAL(18,2) | 采购金额 | |
| payment_status | VARCHAR(20) | 未付款/部分付款/已付款 | 应付账款管理的核心 |
| payment_due_date | DATE | 约定付款日期 | |
| actual_pay_date | DATE | 实际付款日期 | 用 due_date - actual_date 算出付款延迟天数 |
| purchase_type | VARCHAR(20) | 采购类型 | 原材料/贸易商品/办公用品 |

**面试问题**："怎么分析应付账款周转？"
**回答框架**：按 `payment_status` 筛选未付款记录，按 `payment_due_date` 排账龄（0-30/31-60/61-90/90+天），计算应付账款周转天数。

---

### 8. expense — 费用明细表

**对应你的真实工作**：各子公司的销售费用、管理费用、研发费用（软件子公司加计扣除）、财务费用

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| expense_id | INT PK | 自增主键 | |
| expense_date | DATE | 费用发生日期 | |
| expense_type | VARCHAR(30) | 销售费用/管理费用/研发费用/财务费用 | **四大费用分类是利润表核心** |
| expense_item | VARCHAR(50) | 费用明细项 | 工资/差旅/折旧/咨询费等 |
| amount | DECIMAL(18,2) | 金额 | |
| department | VARCHAR(50) | 归属部门 | 销售部/财务部/研发部等 |
| company_id | INT FK | 所属公司 | |

**面试问题**："研发费用的加计扣除怎么做？"
**回答框架**：先从 expense 表中筛选 `expense_type='研发费用'` 的记录，按月汇总，按加计扣除比例计算可抵扣金额。软件子公司的研发费用必须单独归集，不能混入管理费用。

---

## 模块三：财务主表（2+1 张）

### 9. income_statement — 利润表

**对应你的真实工作**：每月编制的各子公司利润表

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| statement_id | INT PK | 自增主键 | |
| period | VARCHAR(7) | 期间 yyyy-mm | |
| company_id | INT FK | 公司ID | |
| revenue | DECIMAL(18,2) | 营业收入 | = SUM(sales_order.amount) |
| cost_of_sales | DECIMAL(18,2) | 营业成本 | = SUM(sales_order.cost_amount) |
| gross_profit | DECIMAL(18,2) | 毛利 | = revenue - cost_of_sales |
| selling_expense | DECIMAL(18,2) | 销售费用 | = SUM(expense WHERE type='销售费用') |
| admin_expense | DECIMAL(18,2) | 管理费用 | |
| rd_expense | DECIMAL(18,2) | 研发费用 | 软件公司的核心指标 |
| finance_expense | DECIMAL(18,2) | 财务费用 | 含汇兑损益 |
| total_expense | DECIMAL(18,2) | 费用合计 | 四费之和 |
| operating_profit | DECIMAL(18,2) | 营业利润 | = gross_profit - total_expense |
| other_income | DECIMAL(18,2) | 其他收益 | 含出口退税 |
| net_profit | DECIMAL(18,2) | 净利润 | = operating_profit + other_income |
| gross_margin | DECIMAL(10,4) | 毛利率 | = gross_profit / revenue |
| net_margin | DECIMAL(10,4) | 净利率 | = net_profit / revenue |

**设计说明**：采用"行式"而非"列式"存储。行式的好处是 SQL 查询简单——`SELECT * FROM income_statement WHERE company_id=1 AND period='2024-06'` 就能取到一条完整的利润表，Power BI 导入后直接用。

**面试问题**："为什么不做成标准的科目余额表格式？"
**回答**：这个项目的目的是**分析而非记账**，行式存储对分析查询和 BI 可视化更友好。真实 ERP 系统（如 SAP）的底表是科目余额表格式，但分析层一般都会 ETL 成这种宽表。

### 10. cross_border_project — 跨境项目表 ★★★ 王牌

**对应你的真实工作**：哈萨克斯坦矿热炉项目

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| project_id | INT PK | 自增主键 | |
| project_name | VARCHAR(100) | 项目名称 | |
| contract_no | VARCHAR(50) UNIQUE | 合同编号 | |
| contract_amount | DECIMAL(18,2) | 合同总金额（万元） | |
| currency | VARCHAR(10) | 结算币种 | **USD/EUR/KZT——跨境业务的核心变量** |
| trade_terms | VARCHAR(20) | 贸易条款 | FOB/CIF/DAP——影响成本归属和风险转移点 |
| contract_exchange_rate | DECIMAL(10,4) | 合同约定汇率 | **汇兑损益计算的关键** |
| tax_refund_rate | DECIMAL(5,2) | 出口退税率 | 如13%——退税额 = 出口金额 × 退税率 |
| payment_method | VARCHAR(30) | 结算方式 | 信用证/电汇/托收——不同方式成本和风险不同 |
| cumulative_revenue | DECIMAL(18,2) | 累计收入 | 按完工百分比法确认 |
| cumulative_cost | DECIMAL(18,2) | 累计成本 | |
| cumulative_profit | DECIMAL(18,2) | 累计利润 | |
| project_progress | DECIMAL(5,2) | 项目进度 | 0-100% |
| status | VARCHAR(20) | 投标中/进行中/已完工/已结算 | |

**面试时这是你的差异化王牌**：大多数财务分析候选人没有跨境项目经验。你要讲清楚：
1. 如何确认跨境收入（完工百分比法 vs 时点法）
2. 汇兑损益的计算逻辑（合同汇率 vs 实际汇率 × 外币金额）
3. 出口退税的影响（退税率差异、申报流程）
4. 不同贸易条款（FOB/CIF）对成本和风险的影响

### 11. fx_transaction — 外汇交易记录表（附加表）

| 字段 | 类型 | 说明 | 面试要点 |
|------|------|------|----------|
| fx_id | INT PK | 自增主键 | |
| project_id | INT FK | 关联项目 | |
| transaction_date | DATE | 交易日期 | |
| amount_foreign | DECIMAL(18,2) | 外币金额 | |
| exchange_rate | DECIMAL(10,4) | 实际结算汇率 | |
| amount_rmb | DECIMAL(18,2) | 实际RMB金额 | |
| transaction_type | VARCHAR(20) | 收款/付款/换汇 | |
| bank | VARCHAR(50) | 经办银行 | |

**汇兑损益计算**（面试一定会被问）：
```
汇兑损益 = (外币金额 × 合同汇率) - 实际到账RMB金额
正数 = 汇兑收益（合同汇率 > 实际汇率，拿到的人民币比预期多）
负数 = 汇兑损失（合同汇率 < 实际汇率）
```

---

## 常见面试追问 & 回答要点

**Q1: "为什么是11张表而不是更多/更少？"**
A: 10+1张表覆盖了完整分析链路。3张基础表（公司/产品/客户）提供维度数据，5张业务表（生产/BOM/销售/采购/费用）覆盖日常经营，2张财务表（利润表/跨境项目）做分析汇总。够用不冗余，每张表都有明确的分析目的。

**Q2: "外键约束在实际项目中会不会影响性能？"**
A: 这个项目的数据库是单机分析库，数据量在10万行以内，外键的性能影响可以忽略。在实际生产环境中，如果数据量大，可以用逻辑外键（CHECK约束或应用层校验）代替物理外键。

**Q3: "DECIMAL(18,2)为什么这样选？"**
A: 18位总长度+2位小数=整数部分16位（最大约9000万亿），足够覆盖集团级别的财务数据。金额必须用DECIMAL不能用FLOAT/DOUBLE——浮点数有精度丢失，财务数据不允许。
