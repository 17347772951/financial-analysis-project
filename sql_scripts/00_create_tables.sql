-- ============================================================
-- 高端装备制造 · 跨境出海全链路财务分析系统
-- 建表脚本：10 张核心表
-- 数据库名：financial_analysis_db
-- ============================================================

-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS financial_analysis_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE financial_analysis_db;

-- 暂时禁用外键检查，避免删表顺序问题
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 模块一：基础信息表（3 张）
-- ============================================================

-- -------------------------------------------
-- 表1：公司信息表 company_info
-- 对应你工作中的集团下各子公司
-- 学到的SQL语法：CREATE TABLE / PRIMARY KEY / COMMENT
-- -------------------------------------------
DROP TABLE IF EXISTS company_info;
CREATE TABLE company_info (
    company_id      INT             PRIMARY KEY AUTO_INCREMENT  COMMENT '公司ID',
    company_name    VARCHAR(50)     NOT NULL                    COMMENT '公司名称',
    company_type    VARCHAR(20)     NOT NULL                    COMMENT '公司类型：制造/贸易/软件',
    tax_id          VARCHAR(30)     NOT NULL                    COMMENT '纳税人识别号(脱敏)',
    address         VARCHAR(100)                                COMMENT '注册地址',
    contact         VARCHAR(20)                                 COMMENT '联系人',
    phone           VARCHAR(20)                                 COMMENT '联系电话',
    create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间'
) COMMENT '公司信息表';

-- -------------------------------------------
-- 表2：产品表 product
-- 包含制造产品 + 贸易商品 + 软件产品
-- 学到的SQL语法：DECIMAL 精确小数 / UNIQUE 唯一约束
-- -------------------------------------------
DROP TABLE IF EXISTS product;
CREATE TABLE product (
    product_id      INT             PRIMARY KEY AUTO_INCREMENT  COMMENT '产品ID',
    product_name    VARCHAR(50)     NOT NULL                    COMMENT '产品名称',
    product_type    VARCHAR(20)     NOT NULL                    COMMENT '产品类型：产成品/贸易商品/软件产品',
    category        VARCHAR(30)                                 COMMENT '产品分类：矿热炉配件/钢材/ERP系统等',
    unit            VARCHAR(10)     NOT NULL                    COMMENT '计量单位：台/吨/套',
    standard_cost   DECIMAL(18,2)                               COMMENT '标准成本(元)',
    selling_price   DECIMAL(18,2)                               COMMENT '标准售价(元)',
    company_id      INT             NOT NULL                    COMMENT '所属公司ID',
    create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间',
    FOREIGN KEY (company_id) REFERENCES company_info(company_id)
) COMMENT '产品表';

-- -------------------------------------------
-- 表3：客户表 customer
-- 国内客户 + 海外客户（对应跨境业务）
-- 学到的SQL语法：CHECK 约束 / DEFAULT 默认值
-- -------------------------------------------
DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
    customer_id     INT             PRIMARY KEY AUTO_INCREMENT  COMMENT '客户ID',
    customer_name   VARCHAR(80)     NOT NULL                    COMMENT '客户名称(脱敏)',
    customer_type   VARCHAR(20)     DEFAULT 'Domestic'           COMMENT '客户类型：Domestic/Overseas',
    region          VARCHAR(30)                                 COMMENT '所在地区/国家',
    credit_level    VARCHAR(10)     DEFAULT 'A'                 COMMENT '信用等级：A/B/C/D',
    credit_limit    DECIMAL(18,2)   DEFAULT 0                   COMMENT '信用额度(元)',
    payment_terms   VARCHAR(30)     DEFAULT 'Net 30'            COMMENT '付款条件',
    contact_person  VARCHAR(20)                                 COMMENT '联系人(脱敏)',
    phone           VARCHAR(20)                                 COMMENT '联系电话(脱敏)',
    create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间'
) COMMENT '客户表';


-- ============================================================
-- 模块二：业务表（5 张）
-- ============================================================

-- -------------------------------------------
-- 表4：生产订单表 production_order
-- 对应制造业子公司矿热炉产品生产
-- 学到的SQL语法：DATE 日期类型 / FOREIGN KEY 外键
-- -------------------------------------------
DROP TABLE IF EXISTS production_order;
CREATE TABLE production_order (
    order_id            INT             PRIMARY KEY AUTO_INCREMENT  COMMENT '生产订单ID',
    order_no            VARCHAR(30)     NOT NULL UNIQUE             COMMENT '生产订单号',
    product_id          INT             NOT NULL                    COMMENT '产品ID',
    order_date          DATE            NOT NULL                    COMMENT '订单日期',
    planned_quantity    INT             NOT NULL                    COMMENT '计划生产数量',
    actual_quantity     INT                                         COMMENT '实际完工数量',
    raw_material_cost   DECIMAL(18,2)                               COMMENT '原材料成本(元)',
    labor_cost          DECIMAL(18,2)                               COMMENT '人工成本(元)',
    overhead_cost       DECIMAL(18,2)                               COMMENT '制造费用(元)',
    total_cost          DECIMAL(18,2)                               COMMENT '总生产成本(元)',
    labor_hours         DECIMAL(10,2)                               COMMENT '生产工时(小时)',
    machine_hours       DECIMAL(10,2)                               COMMENT '机器工时(小时)',
    status              VARCHAR(20)     DEFAULT 'In Progress'       COMMENT '状态：Planned/In Progress/Completed/Closed',
    company_id          INT             NOT NULL                    COMMENT '所属公司ID',
    finish_date         DATE                                        COMMENT '完工日期',
    create_time         DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间',
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (company_id) REFERENCES company_info(company_id)
) COMMENT '生产订单表';

-- -------------------------------------------
-- 表5：BOM物料清单表 bom
-- 成本核算的核心——连接产品与原材料
-- 学到的SQL语法：DECIMAL(10,4) 四位小数精度（适用于用量）
-- -------------------------------------------
DROP TABLE IF EXISTS bom;
CREATE TABLE bom (
    bom_id          INT             PRIMARY KEY AUTO_INCREMENT  COMMENT 'BOM ID',
    product_id      INT             NOT NULL                    COMMENT '产品ID',
    material_name   VARCHAR(50)     NOT NULL                    COMMENT '原材料名称',
    material_code   VARCHAR(30)                                 COMMENT '原材料编码',
    quantity        DECIMAL(10,4)   NOT NULL                    COMMENT '单位用量(每单位产品消耗)',
    unit            VARCHAR(10)     NOT NULL                    COMMENT '用量单位：kg/个/米',
    unit_price      DECIMAL(18,4)   NOT NULL                    COMMENT '原材料单价(元)',
    supplier_id     INT                                         COMMENT '供应商ID',
    material_type   VARCHAR(20)     DEFAULT 'Raw Material'       COMMENT '物料类型：Raw Material/Semi-finished/Auxiliary',
    create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间',
    FOREIGN KEY (product_id) REFERENCES product(product_id)
) COMMENT 'BOM物料清单表——成本核算核心表';

-- -------------------------------------------
-- 表6：销售订单表 sales_order
-- 贸易+制造+软件的销售数据统一存放
-- 学到的SQL语法：区分内销/出口字段设计
-- -------------------------------------------
DROP TABLE IF EXISTS sales_order;
CREATE TABLE sales_order (
    order_id            INT             PRIMARY KEY AUTO_INCREMENT  COMMENT '销售订单ID',
    order_no            VARCHAR(30)     NOT NULL UNIQUE             COMMENT '销售订单号',
    product_id          INT             NOT NULL                    COMMENT '产品ID',
    customer_id         INT             NOT NULL                    COMMENT '客户ID',
    order_date          DATE            NOT NULL                    COMMENT '订单日期',
    quantity            INT             NOT NULL                    COMMENT '销售数量',
    unit_price          DECIMAL(18,2)   NOT NULL                    COMMENT '销售单价(元)',
    amount              DECIMAL(18,2)   NOT NULL                    COMMENT '销售金额(元)',
    cost_amount         DECIMAL(18,2)                               COMMENT '对应成本(元)',
    sale_type           VARCHAR(20)     DEFAULT 'Domestic'           COMMENT '销售类型：Domestic/Export',
    currency            VARCHAR(10)     DEFAULT 'CNY'               COMMENT '结算币种：CNY/USD/EUR',
    exchange_rate       DECIMAL(10,4)   DEFAULT 1.0000              COMMENT '汇率(外币→人民币)',
    delivery_date       DATE                                        COMMENT '交货日期',
    payment_method      VARCHAR(30)                                 COMMENT '收款方式：电汇/信用证/承兑汇票',
    status              VARCHAR(20)     DEFAULT 'Shipped'           COMMENT '状态：Pending/Shipped/Completed/Cancelled',
    company_id          INT             NOT NULL                    COMMENT '所属公司ID',
    create_time         DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间',
    FOREIGN KEY (product_id)     REFERENCES product(product_id),
    FOREIGN KEY (customer_id)    REFERENCES customer(customer_id),
    FOREIGN KEY (company_id)     REFERENCES company_info(company_id)
) COMMENT '销售订单表';

-- -------------------------------------------
-- 表7：采购订单表 purchase_order
-- 对应贸易子公司采购 + 制造业原材料采购
-- -------------------------------------------
DROP TABLE IF EXISTS purchase_order;
CREATE TABLE purchase_order (
    order_id            INT             PRIMARY KEY AUTO_INCREMENT  COMMENT '采购订单ID',
    order_no            VARCHAR(30)     NOT NULL UNIQUE             COMMENT '采购订单号',
    product_id          INT             NOT NULL                    COMMENT '采购产品ID',
    supplier_name       VARCHAR(80)     NOT NULL                    COMMENT '供应商名称(脱敏)',
    order_date          DATE            NOT NULL                    COMMENT '采购日期',
    quantity            INT             NOT NULL                    COMMENT '采购数量',
    unit_price          DECIMAL(18,2)   NOT NULL                    COMMENT '采购单价(元)',
    amount              DECIMAL(18,2)   NOT NULL                    COMMENT '采购金额(元)',
    purchase_type       VARCHAR(20)     DEFAULT 'Raw Material'       COMMENT '采购类型：Raw Material/Trade Goods/Office Supplies',
    payment_status      VARCHAR(20)     DEFAULT 'Unpaid'             COMMENT '付款状态：Unpaid/Partial/Paid',
    payment_due_date    DATE                                        COMMENT '约定付款日期',
    actual_pay_date     DATE                                        COMMENT '实际付款日期',
    company_id          INT             NOT NULL                    COMMENT '所属公司ID',
    create_time         DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间',
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (company_id) REFERENCES company_info(company_id)
) COMMENT '采购订单表';

-- -------------------------------------------
-- 表8：费用明细表 expense
-- 销售费用 + 管理费用 + 研发费用 + 财务费用
-- 学到的SQL语法：枚举型费用分类
-- -------------------------------------------
DROP TABLE IF EXISTS expense;
CREATE TABLE expense (
    expense_id      INT             PRIMARY KEY AUTO_INCREMENT  COMMENT '费用ID',
    expense_date    DATE            NOT NULL                    COMMENT '费用发生日期',
    expense_type    VARCHAR(30)     NOT NULL                    COMMENT '费用大类：销售费用/管理费用/研发费用/财务费用',
    expense_item    VARCHAR(50)     NOT NULL                    COMMENT '费用明细项：工资/差旅费/折旧费/咨询费等',
    amount          DECIMAL(18,2)   NOT NULL                    COMMENT '费用金额(元)',
    department      VARCHAR(50)                                 COMMENT '归属部门',
    company_id      INT             NOT NULL                    COMMENT '所属公司ID',
    remark          VARCHAR(200)                                COMMENT '备注',
    create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间',
    FOREIGN KEY (company_id) REFERENCES company_info(company_id)
) COMMENT '费用明细表';


-- ============================================================
-- 模块三：财务主表（2 张）
-- ============================================================

-- -------------------------------------------
-- 表9：利润表 income_statement
-- 按子公司 + 月份汇总，包含完整利润表科目
-- 学到的SQL语法：用行式存储利润表（方便SQL聚合查询）
-- -------------------------------------------
DROP TABLE IF EXISTS income_statement;
CREATE TABLE income_statement (
    statement_id        INT             PRIMARY KEY AUTO_INCREMENT  COMMENT '主键ID',
    period              VARCHAR(7)      NOT NULL                    COMMENT '期间：yyyy-mm',
    company_id          INT             NOT NULL                    COMMENT '公司ID',
    revenue             DECIMAL(18,2)   DEFAULT 0                   COMMENT '营业收入(元)',
    cost_of_sales       DECIMAL(18,2)   DEFAULT 0                   COMMENT '营业成本(元)',
    gross_profit        DECIMAL(18,2)   DEFAULT 0                   COMMENT '毛利(元)=营收-成本',
    selling_expense     DECIMAL(18,2)   DEFAULT 0                   COMMENT '销售费用(元)',
    admin_expense       DECIMAL(18,2)   DEFAULT 0                   COMMENT '管理费用(元)',
    rd_expense          DECIMAL(18,2)   DEFAULT 0                   COMMENT '研发费用(元)',
    finance_expense     DECIMAL(18,2)   DEFAULT 0                   COMMENT '财务费用(元)(含汇兑损益)',
    total_expense       DECIMAL(18,2)   DEFAULT 0                   COMMENT '费用合计(元)',
    operating_profit    DECIMAL(18,2)   DEFAULT 0                   COMMENT '营业利润(元)=毛利-费用合计',
    other_income        DECIMAL(18,2)   DEFAULT 0                   COMMENT '其他收益(元)(含出口退税)',
    net_profit          DECIMAL(18,2)   DEFAULT 0                   COMMENT '净利润(元)',
    gross_margin        DECIMAL(10,4)                               COMMENT '毛利率(%)',
    net_margin          DECIMAL(10,4)                               COMMENT '净利率(%)',
    create_time         DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间',
    FOREIGN KEY (company_id) REFERENCES company_info(company_id),
    UNIQUE KEY uk_period_company (period, company_id)               COMMENT '每个公司每月只有一条'
) COMMENT '利润表——按子公司+月份汇总';

-- -------------------------------------------
-- 表10：跨境项目表 cross_border_project  ★★★ 你的王牌表
-- 完全参考你公司哈萨克斯坦矿热炉项目的业务结构
-- 学到的SQL语法：外汇/汇率相关字段设计
-- -------------------------------------------
DROP TABLE IF EXISTS cross_border_project;
CREATE TABLE cross_border_project (
    project_id          INT             PRIMARY KEY AUTO_INCREMENT  COMMENT '项目ID',
    project_name        VARCHAR(100)    NOT NULL                    COMMENT '项目名称',
    contract_no         VARCHAR(50)     NOT NULL UNIQUE             COMMENT '合同编号',
    customer_id         INT             NOT NULL                    COMMENT '海外客户ID',
    contract_amount     DECIMAL(18,2)   NOT NULL                    COMMENT '合同总金额(万元)',
    currency            VARCHAR(10)     NOT NULL                    COMMENT '结算币种：USD/EUR/KZT',
    trade_terms         VARCHAR(20)     NOT NULL                    COMMENT '贸易条款：FOB/CIF/DAP',
    start_date          DATE            NOT NULL                    COMMENT '项目开始日期',
    planned_end_date    DATE            NOT NULL                    COMMENT '计划结束日期',
    actual_end_date     DATE                                        COMMENT '实际结束日期',
    contract_exchange_rate  DECIMAL(10,4)   NOT NULL                COMMENT '合同约定汇率',
    tax_refund_rate     DECIMAL(5,2)    NOT NULL                    COMMENT '出口退税率(%)',
    payment_method      VARCHAR(30)     NOT NULL                    COMMENT '结算方式：信用证/电汇/托收',
    cumulative_revenue  DECIMAL(18,2)   DEFAULT 0                   COMMENT '累计确认收入(元)',
    cumulative_cost     DECIMAL(18,2)   DEFAULT 0                   COMMENT '累计发生成本(元)',
    cumulative_profit   DECIMAL(18,2)   DEFAULT 0                   COMMENT '累计利润(元)',
    project_progress    DECIMAL(5,2)    DEFAULT 0                   COMMENT '项目进度(%)',
    status              VARCHAR(20)     DEFAULT 'In Progress'        COMMENT '项目状态：Bidding/In Progress/Completed/Settled',
    remark              VARCHAR(200)                                COMMENT '备注',
    create_time         DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间',
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
) COMMENT '跨境项目主表 ★ 核心竞争力表';

-- -------------------------------------------
-- 附加表11：外汇交易记录表 fx_transaction
-- 记录每笔实际换汇，关联跨境项目
-- 学到的SQL语法：计算列概念（汇兑损益 = 外币金额×合同汇率 - 实际结算RMB）
-- -------------------------------------------
DROP TABLE IF EXISTS fx_transaction;
CREATE TABLE fx_transaction (
    fx_id               INT             PRIMARY KEY AUTO_INCREMENT  COMMENT '交易ID',
    project_id          INT             NOT NULL                    COMMENT '关联项目ID',
    transaction_date    DATE            NOT NULL                    COMMENT '交易日期',
    amount_foreign      DECIMAL(18,2)   NOT NULL                    COMMENT '外币金额',
    currency            VARCHAR(10)     NOT NULL                    COMMENT '币种',
    exchange_rate       DECIMAL(10,4)   NOT NULL                    COMMENT '实际结算汇率',
    amount_rmb          DECIMAL(18,2)   NOT NULL                    COMMENT '实际结算人民币金额',
    transaction_type    VARCHAR(20)     NOT NULL                    COMMENT '交易类型：收款/付款/换汇',
    bank                VARCHAR(50)                                 COMMENT '经办银行(脱敏)',
    create_time         DATETIME        DEFAULT CURRENT_TIMESTAMP   COMMENT '创建时间',
    FOREIGN KEY (project_id) REFERENCES cross_border_project(project_id)
) COMMENT '外汇交易记录表——汇兑损益计算核心表';


-- 重新启用外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 验证：查看所有已创建的表
-- ============================================================
SHOW TABLES;

-- 查看每张表的结构（执行下面这行可以逐表检查）
-- DESCRIBE company_info;
-- DESCRIBE product;
-- DESCRIBE customer;
-- DESCRIBE production_order;
-- DESCRIBE bom;
-- DESCRIBE sales_order;
-- DESCRIBE purchase_order;
-- DESCRIBE expense;
-- DESCRIBE income_statement;
-- DESCRIBE cross_border_project;
-- DESCRIBE fx_transaction;
