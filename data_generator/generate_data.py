# -*- coding: utf-8 -*-
"""
高端装备制造 · 跨境出海全链路财务分析系统
数据生成脚本 —— 基于真实业务逻辑生成脱敏模拟数据

使用方法：
  1. 修改下方 config 中的业务参数
  2. python generate_data.py
  3. 生成的 CSV 文件在 ./output/ 目录下
  4. 用 DBeaver 导入 CSV 到 MySQL
"""

import csv
import os
import random
import numpy as np
from datetime import datetime, timedelta

# ============================================================
# 业务规则配置（可调整参数）
# ============================================================
class Config:
    # 时间范围
    START_DATE = datetime(2023, 1, 1)
    END_DATE = datetime(2025, 12, 31)
    MONTHS = 36  # 3年 × 12个月

    # 公司配置（对应青城集团3家子公司）
    COMPANIES = [
        {"id": 1, "name": "青城重工有限公司",        "type": "制造", "desc": "矿热炉制造"},
        {"id": 2, "name": "青城贸易发展有限公司",    "type": "贸易", "desc": "钢铁及设备贸易"},
        {"id": 3, "name": "青城科技信息有限公司",    "type": "软件", "desc": "ERP及工业软件"},
    ]

    # 产品配置
    PRODUCTS = [
        # 制造公司产品
        {"id": 1, "name": "矿热炉整机",       "type": "产成品", "category": "矿热炉",   "unit": "台",  "cost": 5000000, "price": 6500000, "company_id": 1},
        {"id": 2, "name": "矿热炉配件A型",     "type": "产成品", "category": "矿热炉配件", "unit": "套",  "cost": 800000,   "price": 1050000, "company_id": 1},
        {"id": 3, "name": "矿热炉配件B型",     "type": "产成品", "category": "矿热炉配件", "unit": "套",  "cost": 500000,   "price": 680000,  "company_id": 1},
        # 贸易公司产品
        {"id": 4, "name": "特种钢材",          "type": "贸易商品", "category": "钢材",     "unit": "吨",  "cost": 4200,    "price": 5100,    "company_id": 2},
        {"id": 5, "name": "工业设备配件",       "type": "贸易商品", "category": "设备配件", "unit": "件",  "cost": 1500,    "price": 1950,    "company_id": 2},
        {"id": 6, "name": "耐火材料",          "type": "贸易商品", "category": "耐火材料", "unit": "吨",  "cost": 2800,    "price": 3400,    "company_id": 2},
        # 软件公司产品
        {"id": 7, "name": "ERP系统-标准版",    "type": "软件产品", "category": "ERP系统",  "unit": "套",  "cost": 300000,  "price": 800000,  "company_id": 3},
        {"id": 8, "name": "MES系统-定制版",    "type": "软件产品", "category": "MES系统",  "unit": "套",  "cost": 500000,  "price": 1200000, "company_id": 3},
        {"id": 9, "name": "软件运维服务",       "type": "软件产品", "category": "运维服务", "unit": "年",  "cost": 80000,   "price": 200000,  "company_id": 3},
    ]

    # 客户配置
    CUSTOMERS = [
        {"id": 1,  "name": "中冶南方工程技术有限公司", "type": "国内", "region": "湖北武汉", "credit": "A"},
        {"id": 2,  "name": "宝钢工程技术集团有限公司", "type": "国内", "region": "上海",     "credit": "A"},
        {"id": 3,  "name": "江苏永钢集团有限公司",     "type": "国内", "region": "江苏张家港", "credit": "B"},
        {"id": 4,  "name": "Kazakhstan Steel Ltd",    "type": "海外", "region": "哈萨克斯坦", "credit": "B"},
        {"id": 5,  "name": "唐山钢铁集团有限公司",     "type": "国内", "region": "河北唐山", "credit": "B"},
        {"id": 6,  "name": "四川德胜集团钒钛有限公司", "type": "国内", "region": "四川乐山", "credit": "C"},
        {"id": 7,  "name": "Uzbekistan Mining Corp",  "type": "海外", "region": "乌兹别克斯坦", "credit": "C"},
        {"id": 8,  "name": "成都建工集团有限公司",     "type": "国内", "region": "四川成都", "credit": "A"},
    ]

    # BOM配置（每个产品的原材料组成）
    BOM = {
        1: [  # 矿热炉整机
            {"material_name": "特种钢板",     "code": "RM001", "qty": 120, "unit": "吨",   "price": 5200},
            {"material_name": "铜材",         "code": "RM002", "qty": 18,  "unit": "吨",   "price": 68000},
            {"material_name": "耐火砖",       "code": "RM003", "qty": 500, "unit": "块",   "price": 120},
            {"material_name": "绝缘材料",      "code": "RM004", "qty": 200, "unit": "kg",   "price": 85},
            {"material_name": "电控系统组件",  "code": "RM005", "qty": 8,   "unit": "套",   "price": 150000},
        ],
        2: [  # 矿热炉配件A型
            {"material_name": "特种钢板",     "code": "RM001", "qty": 20,  "unit": "吨",   "price": 5200},
            {"material_name": "铜材",         "code": "RM002", "qty": 4,   "unit": "吨",   "price": 68000},
            {"material_name": "绝缘材料",      "code": "RM004", "qty": 30,  "unit": "kg",   "price": 85},
        ],
        3: [  # 矿热炉配件B型
            {"material_name": "特种钢板",     "code": "RM001", "qty": 12,  "unit": "吨",   "price": 5200},
            {"material_name": "耐火砖",       "code": "RM003", "qty": 150, "unit": "块",   "price": 120},
            {"material_name": "电控系统组件",  "code": "RM005", "qty": 2,   "unit": "套",   "price": 150000},
        ],
    }

    # 成本结构比例
    MANUFACTURING_COST_RATIO = {"material": 0.60, "labor": 0.20, "overhead": 0.20}
    TRADE_GROSS_MARGIN_RANGE = (0.15, 0.25)
    SOFTWARE_GROSS_MARGIN_RANGE = (0.55, 0.70)

    # 费用比例（占营收%）
    SELLING_EXPENSE_RATIO = {"制造": 0.05, "贸易": 0.08, "软件": 0.12}
    ADMIN_EXPENSE_RATIO = {"制造": 0.06, "贸易": 0.04, "软件": 0.08}
    RD_EXPENSE_RATIO = {"软件": 0.18}       # 软件公司研发费用占营收比
    FINANCE_EXPENSE_RATIO = {"制造": 0.02, "贸易": 0.015, "软件": 0.01}

    # 跨境项目配置（哈萨克斯坦矿热炉项目）
    CROSS_BORDER_PROJECTS = [
        {
            "project_id": 1,
            "project_name": "哈萨克斯坦矿热炉出口项目(一期)",
            "contract_no": "CB-2023-001",
            "customer_id": 4,
            "contract_amount": 3200,  # 万元
            "currency": "USD",
            "trade_terms": "FOB",
            "start_date": "2023-03-01",
            "end_date": "2024-06-30",
            "tax_refund_rate": 13.00,
            "contract_exchange_rate": 6.8500,
            "payment_method": "信用证"
        },
        {
            "project_id": 2,
            "project_name": "乌兹别克斯坦设备出口项目",
            "contract_no": "CB-2024-002",
            "customer_id": 7,
            "contract_amount": 1800,
            "currency": "USD",
            "trade_terms": "CIF",
            "start_date": "2024-01-15",
            "end_date": "2024-12-31",
            "tax_refund_rate": 13.00,
            "contract_exchange_rate": 7.1000,
            "payment_method": "电汇"
        },
    ]

    # 随机波动幅度（给数据加噪音，模仿真实业务）
    NOISE_LEVEL = 0.10  # ±10%波动
    SEASONALITY = {     # 月度季节性系数
        1: 0.85, 2: 0.75, 3: 1.05, 4: 1.10, 5: 1.15, 6: 1.20,
        7: 1.10, 8: 1.05, 9: 1.15, 10: 1.10, 11: 1.05, 12: 1.25
    }

# ============================================================
# 辅助函数
# ============================================================
def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)

def noise(factor=None):
    """生成随机波动系数"""
    if factor is None:
        factor = Config.NOISE_LEVEL
    return 1.0 + np.random.uniform(-factor, factor)

def monthly_dates():
    """生成36个月——用月份增量而非天数增量，确保每月唯一"""
    from dateutil.relativedelta import relativedelta
    months = []
    for m in range(Config.MONTHS):
        start = Config.START_DATE + relativedelta(months=m)
        year_month = start.strftime("%Y-%m")
        months.append({
            "year": start.year,
            "month": start.month,
            "period": year_month,
            "start": start,
            "end": start
        })
    return months

def seasonality(month):
    return Config.SEASONALITY.get(month, 1.0)

# ============================================================
# 数据生成函数（每张表一个函数）
# ============================================================

def generate_company_info():
    rows = []
    for c in Config.COMPANIES:
        rows.append([
            c["id"], c["name"], c["type"],
            f"91510{random.randint(100000,999999)}XXXX",
            f"成都市都江堰区工业园{random.choice(['A','B','C'])}区",
            f"联系人{c['id']}", f"138{random.randint(10000000,99999999)}"
        ])
    return rows, ["company_id","company_name","company_type","tax_id","address","contact","phone"]

def generate_product():
    rows = []
    for p in Config.PRODUCTS:
        rows.append([
            p["id"], p["name"], p["type"], p["category"],
            p["unit"], round(p["cost"] * noise(0.03), 2),
            round(p["price"] * noise(0.03), 2), p["company_id"]
        ])
    return rows, ["product_id","product_name","product_type","category","unit","standard_cost","selling_price","company_id"]

def generate_customer():
    rows = []
    for c in Config.CUSTOMERS:
        payment = "Net 30" if c["credit"] in ("A","B") else "Net 60"
        rows.append([
            c["id"], c["name"], c["type"], c["region"],
            c["credit"], 0, payment, f"联系人{c['id']}",
            f"139{random.randint(10000000,99999999)}"
        ])
    return rows, ["customer_id","customer_name","customer_type","region","credit_level","credit_limit","payment_terms","contact_person","phone"]

def generate_bom():
    rows = []
    bom_id = 1
    for product_id, materials in Config.BOM.items():
        for mat in materials:
            rows.append([
                bom_id, product_id, mat["material_name"], mat["code"],
                mat["qty"], mat["unit"], round(mat["price"] * noise(0.03), 2),
                random.randint(1, 8), mat.get("material_type", "Raw Material") if product_id <= 3 else "Raw Material"
            ])
            bom_id += 1
    return rows, ["bom_id","product_id","material_name","material_code","quantity","unit","unit_price","supplier_id","material_type"]

def generate_production_order(months):
    """生成制造业生产订单（公司1）"""
    rows = []
    order_num = 1
    products = [p for p in Config.PRODUCTS if p["company_id"] == 1]

    for m in months:
        for p in products:
            # 每月每个产品1-3个生产批
            batches = random.randint(1, 3)
            for _ in range(batches):
                planned_qty = random.randint(2, 8) if p["id"] == 1 else random.randint(5, 20)
                actual_qty = planned_qty if random.random() > 0.15 else planned_qty - random.randint(1, 2)

                # 成本计算
                bom_cost = 0
                if p["id"] in Config.BOM:
                    for mat in Config.BOM[p["id"]]:
                        bom_cost += mat["qty"] * mat["price"]

                material_cost = round(bom_cost * actual_qty * noise(0.08), 2)
                labor_ratio = Config.MANUFACTURING_COST_RATIO["labor"]
                overhead_ratio = Config.MANUFACTURING_COST_RATIO["overhead"]
                material_ratio = Config.MANUFACTURING_COST_RATIO["material"]

                total_cost = round(material_cost / material_ratio * noise(0.05), 2) if material_ratio > 0 else 0
                labor_cost = round(total_cost * labor_ratio, 2)
                overhead_cost = round(total_cost * overhead_ratio, 2)

                labor_hours = round(actual_qty * p["cost"] / 500 * noise(0.1), 1)  # 每500元成本≈1工时
                machine_hours = round(labor_hours * 0.7 * noise(0.1), 1)

                order_no = f"MO-{m['year']}-{m['month']:02d}-{order_num:04d}"
                status = "Completed" if m["end"] < Config.END_DATE - timedelta(days=30) else random.choice(["In Progress", "Completed"])

                rows.append([
                    order_num, order_no, p["id"], m["start"].strftime("%Y-%m-%d"),
                    planned_qty, actual_qty, material_cost, labor_cost, overhead_cost,
                    round(material_cost + labor_cost + overhead_cost, 2),
                    labor_hours, machine_hours, status, 1,
                    (m["start"] + timedelta(days=random.randint(20,28))).strftime("%Y-%m-%d")
                ])
                order_num += 1

    return rows, ["order_id","order_no","product_id","order_date","planned_quantity","actual_quantity",
                  "raw_material_cost","labor_cost","overhead_cost","total_cost","labor_hours","machine_hours",
                  "status","company_id","finish_date"]

def generate_sales_order(months):
    """生成销售订单（制造+贸易+软件）"""
    rows = []
    order_num = 1

    for m in months:
        for p in Config.PRODUCTS:
            # 不同产品有不同的月度销售频率
            if p["company_id"] == 1:  # 制造：每月1-3笔
                transactions = random.randint(1, 3)
            elif p["company_id"] == 2:  # 贸易：每月3-8笔
                transactions = random.randint(3, 8)
            else:  # 软件：每月0-2笔
                transactions = random.randint(0, 2)

            for _ in range(transactions):
                qty = random.randint(1, 5) if p["id"] in [1,7,8] else random.randint(5, 50)
                unit_price = round(p["price"] * noise(0.1) * seasonality(m["month"]), 2)
                amount = round(qty * unit_price, 2)
                cost = round(qty * p["cost"] * noise(0.1), 2)

                # 选择客户（海外客户只能买制造端产品=公司1的产品）
                if p["company_id"] == 1 and random.random() < 0.2:  # 20%出口
                    cust = random.choice([c for c in Config.CUSTOMERS if c["type"] == "海外"])
                    sale_type = "Export"
                    currency = "USD"
                    ex_rate = round(6.8 + random.uniform(-0.5, 0.5), 4)
                else:
                    cust = random.choice([c for c in Config.CUSTOMERS if c["type"] == "国内"])
                    sale_type = "Domestic"
                    currency = "CNY"
                    ex_rate = 1.0000

                order_no = f"SO-{m['year']}-{m['month']:02d}-{order_num:04d}"
                status = random.choice(["Shipped","Shipped","Shipped","Completed"])

                rows.append([
                    order_num, order_no, p["id"], cust["id"],
                    m["start"].strftime("%Y-%m-%d"), qty, unit_price, amount, cost,
                    sale_type, currency, ex_rate,
                    (m["start"] + timedelta(days=random.randint(15,40))).strftime("%Y-%m-%d"),
                    "T/T" if sale_type == "Export" else "银行承兑汇票",
                    status, p["company_id"]
                ])
                order_num += 1

    return rows, ["order_id","order_no","product_id","customer_id","order_date","quantity","unit_price","amount",
                  "cost_amount","sale_type","currency","exchange_rate","delivery_date","payment_method","status","company_id"]

def generate_purchase_order(months):
    """生成采购订单（制造+贸易采购）"""
    rows = []
    order_num = 1
    suppliers = ["成都钢材供应商A","重庆设备供应商B","上海贸易商C","广州原料供应商D","杭州软件服务商E"]

    for m in months:
        # 制造公司采购原材料
        for _ in range(random.randint(2, 5)):
            supplier = random.choice(suppliers[:3])
            amount = round(random.uniform(50000, 500000) * noise(0.2), 2)
            due_date = m["start"] + timedelta(days=random.randint(30, 90))
            paid = random.random() < 0.85  # 85%已付款
            rows.append([
                order_num, f"PO-{m['year']}-{m['month']:02d}-{order_num:04d}",
                random.choice([1,2,3]), supplier, m["start"].strftime("%Y-%m-%d"),
                random.randint(10, 200), round(amount / random.randint(10, 200), 2), amount,
                "Raw Material", "Paid" if paid else "Unpaid",
                due_date.strftime("%Y-%m-%d"),
                (due_date - timedelta(days=random.randint(-10, 20))).strftime("%Y-%m-%d") if paid else None,
                1
            ])
            order_num += 1

        # 贸易公司采购
        for _ in range(random.randint(2, 4)):
            supplier = random.choice(suppliers[2:])
            amount = round(random.uniform(30000, 300000) * noise(0.2), 2)
            due_date = m["start"] + timedelta(days=random.randint(30, 60))
            paid = random.random() < 0.80
            rows.append([
                order_num, f"PO-{m['year']}-{m['month']:02d}-{order_num:04d}",
                random.choice([4,5,6]), supplier, m["start"].strftime("%Y-%m-%d"),
                random.randint(20, 500), round(amount / random.randint(20, 500), 2), amount,
                "Trade Goods", "Paid" if paid else "Unpaid",
                due_date.strftime("%Y-%m-%d"),
                (due_date - timedelta(days=random.randint(-5, 15))).strftime("%Y-%m-%d") if paid else None,
                2
            ])
            order_num += 1

    return rows, ["order_id","order_no","product_id","supplier_name","order_date","quantity","unit_price","amount",
                  "purchase_type","payment_status","payment_due_date","actual_pay_date","company_id"]

def generate_expense(months):
    """生成费用明细（四费）"""
    rows = []
    expense_id = 1
    expense_types = {
        "制造": {"销售费用": ["差旅费","招待费","广告费","工资"], "管理费用": ["工资","折旧费","办公费","咨询费"], "财务费用": ["利息支出","手续费"]},
        "贸易": {"销售费用": ["差旅费","招待费","展会费","工资"], "管理费用": ["工资","办公费","租赁费"], "财务费用": ["利息支出","手续费","汇兑损益"]},
        "软件": {"销售费用": ["差旅费","工资"], "管理费用": ["工资","办公费","折旧费"], "研发费用": ["研发工资","研发设备","测试费","外包费"], "财务费用": ["手续费"]},
    }

    for m in months:
        for comp in Config.COMPANIES:
            ct = comp["type"]
            if ct not in expense_types:
                continue
            for exp_type, items in expense_types[ct].items():
                for item in items:
                    if random.random() < 0.7:  # 70%概率当月发生这笔费用
                        if exp_type == "研发费用":
                            base = random.uniform(20000, 80000)
                        elif exp_type == "销售费用":
                            base = random.uniform(5000, 30000)
                        elif exp_type == "财务费用":
                            base = random.uniform(2000, 15000)
                        else:
                            base = random.uniform(8000, 40000)

                        amount = round(base * noise(0.3) * seasonality(m["month"]), 2)
                        rows.append([
                            expense_id, m["start"].strftime("%Y-%m-%d"), exp_type, item,
                            amount, f"{ct}业务部", comp["id"], ""
                        ])
                        expense_id += 1

    return rows, ["expense_id","expense_date","expense_type","expense_item","amount","department","company_id","remark"]

def generate_income_statement(months, sales_rows, expense_rows):
    """从销售和费用汇总生成利润表——保证数据逻辑自洽"""
    from collections import defaultdict

    rows = []

    # 按月度和公司汇总销售收入
    rev = defaultdict(float)
    cost_dict = defaultdict(float)
    for s in sales_rows:
        # s: [order_id, order_no, product_id, customer_id, order_date, qty, unit_price, amount, cost_amount, ...]
        order_date = s[4]
        year_month = order_date[:7]
        amount = float(s[7])
        cost = float(s[8]) if s[8] else 0
        company_id = int(s[15])
        rev[(year_month, company_id)] += amount
        cost_dict[(year_month, company_id)] += cost

    # 按月度汇总费用
    exp_sum = defaultdict(lambda: defaultdict(float))
    for e in expense_rows:
        # e: [expense_id, expense_date, expense_type, expense_item, amount, department, company_id, remark]
        expense_date = e[1]
        year_month = expense_date[:7]
        exp_type = e[2]
        amount = float(e[4])
        company_id = int(e[6])
        exp_sum[(year_month, company_id)][exp_type] += amount

    for m in months:
        for comp in Config.COMPANIES:
            key = (m["period"], comp["id"])
            revenue = round(rev[key], 2)
            cost_sales = round(cost_dict[key], 2)
            gross_profit = round(revenue - cost_sales, 2)

            selling = round(exp_sum[key].get("销售费用", 0), 2)
            admin = round(exp_sum[key].get("管理费用", 0), 2)
            rd = round(exp_sum[key].get("研发费用", 0), 2)
            finance = round(exp_sum[key].get("财务费用", 0), 2)
            total_exp = round(selling + admin + rd + finance, 2)

            op_profit = round(gross_profit - total_exp, 2)
            other_income = round(revenue * 0.002 * noise(0.5), 2)  # 其他收益（退税等）
            net_profit = round(op_profit + other_income, 2)

            gross_margin = round(gross_profit / revenue, 4) if revenue > 0 else 0
            net_margin = round(net_profit / revenue, 4) if revenue > 0 else 0

            rows.append([
                m["period"], comp["id"], revenue, cost_sales, gross_profit,
                selling, admin, rd, finance, total_exp, op_profit,
                other_income, net_profit, gross_margin, net_margin
            ])

    return rows, ["period","company_id","revenue","cost_of_sales","gross_profit",
                  "selling_expense","admin_expense","rd_expense","finance_expense",
                  "total_expense","operating_profit","other_income","net_profit",
                  "gross_margin","net_margin"]

def generate_cross_border_project(months):
    """生成跨境项目数据——每个项目一行最终快照 + 每月外汇交易记录"""
    cb_rows = []
    fx_rows = []
    fx_id = 1

    for proj in Config.CROSS_BORDER_PROJECTS:
        proj_start = datetime.strptime(proj["start_date"], "%Y-%m-%d")
        proj_end = datetime.strptime(proj["end_date"], "%Y-%m-%d")
        total_months = max(1, (proj_end.year - proj_start.year) * 12 + (proj_end.month - proj_start.month))
        progress_per_month = 100.0 / total_months if total_months > 0 else 100

        cumulative_rev = 0
        cumulative_cost = 0
        contract_amount_wan = proj["contract_amount"]
        contract_rate = proj["contract_exchange_rate"]
        project_months = 0
        final_status = "In Progress"
        actual_end_date = None

        for i, m in enumerate(months):
            if m["start"] < proj_start or m["start"] > proj_end:
                continue
            project_months += 1

            progress = min(100, round((i + 1) * progress_per_month * noise(0.1), 2))

            monthly_rev = round(contract_amount_wan * 10000 * progress_per_month / 100 * noise(0.1), 2)
            cumulative_rev += monthly_rev
            cost_rate = 0.75 + random.uniform(-0.05, 0.05)
            monthly_cost = round(monthly_rev * cost_rate, 2)
            cumulative_cost += monthly_cost

            if progress >= 100:
                final_status = "Completed"
                actual_end_date = m["start"].strftime("%Y-%m-%d")

            # 外汇交易记录
            actual_rate = round(contract_rate + random.uniform(-0.15, 0.25), 4)
            amount_usd = round(monthly_rev / contract_rate, 2)
            amount_rmb = round(amount_usd * actual_rate, 2)
            fx_rows.append([
                fx_id, proj["project_id"], m["start"].strftime("%Y-%m-%d"),
                amount_usd, "USD", actual_rate, amount_rmb,
                "收款", f"中国银行四川省分行{random.randint(100,999)}"
            ])
            fx_id += 1

        # 只插入一条项目主记录（最终状态）
        cumulative_profit = round(cumulative_rev - cumulative_cost, 2)
        cb_rows.append([
            proj["project_id"], proj["project_name"], proj["contract_no"],
            proj["customer_id"], contract_amount_wan, proj["currency"],
            proj["trade_terms"], proj_start.strftime("%Y-%m-%d"),
            proj_end.strftime("%Y-%m-%d"), actual_end_date,
            contract_rate, proj["tax_refund_rate"], proj["payment_method"],
            round(cumulative_rev, 2), round(cumulative_cost, 2),
            cumulative_profit, 100.0 if final_status == "Completed" else round(project_months * progress_per_month, 2),
            final_status, ""
        ])

    cb_headers = ["project_id","project_name","contract_no","customer_id","contract_amount",
                  "currency","trade_terms","start_date","planned_end_date","actual_end_date",
                  "contract_exchange_rate","tax_refund_rate","payment_method",
                  "cumulative_revenue","cumulative_cost","cumulative_profit",
                  "project_progress","status","remark"]
    fx_headers = ["fx_id","project_id","transaction_date","amount_foreign","currency",
                  "exchange_rate","amount_rmb","transaction_type","bank"]
    return (cb_rows, cb_headers), (fx_rows, fx_headers)

# ============================================================
# 写入 CSV
# ============================================================
def write_csv(filename, rows, headers):
    filepath = f"./output/{filename}"
    with open(filepath, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(rows)
    print(f"  [OK] {filename} ({len(rows)} rows)")

# ============================================================
# 主程序
# ============================================================
def main():
    print("=" * 60)
    print("  财务分析系统 · 模拟数据生成器")
    print("=" * 60)
    print()

    ensure_dir("./output")
    months = monthly_dates()
    print(f"时间范围：{Config.START_DATE.strftime('%Y-%m-%d')} ~ {Config.END_DATE.strftime('%Y-%m-%d')}")
    print(f"共 {len(months)} 个月")
    print()

    # 1. 基础信息表
    print("[1/11] 基础信息表...")
    write_csv("company_info.csv", *generate_company_info())
    write_csv("product.csv", *generate_product())
    write_csv("customer.csv", *generate_customer())

    # 2. 业务表
    print("[2/11] BOM表...")
    write_csv("bom.csv", *generate_bom())

    print("[3/11] 生产订单...")
    write_csv("production_order.csv", *generate_production_order(months))

    print("[4/11] 销售订单...")
    sales_rows, sales_headers = generate_sales_order(months)
    write_csv("sales_order.csv", sales_rows, sales_headers)

    print("[5/11] 采购订单...")
    write_csv("purchase_order.csv", *generate_purchase_order(months))

    print("[6/11] 费用明细...")
    exp_rows, exp_headers = generate_expense(months)
    write_csv("expense.csv", exp_rows, exp_headers)

    print("[7/11] 利润表（从销售和费用汇总...）")
    write_csv("income_statement.csv", *generate_income_statement(months, sales_rows, exp_rows))

    print("[8/11] 跨境项目...")
    cb_data, fx_data = generate_cross_border_project(months)
    write_csv("cross_border_project.csv", *cb_data)
    write_csv("fx_transaction.csv", *fx_data)

    print()
    print("=" * 60)
    print("  数据生成完毕！请在 DBeaver 中导入 CSV 文件")
    print("  文件路径：./output/")
    print("=" * 60)

if __name__ == "__main__":
    main()
