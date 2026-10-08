/* =====================================================================
   POC DOANH THU BẢO HIỂM — DỮ LIỆU NGUỒN v2  (PostgreSQL ≥ 12)
   ---------------------------------------------------------------------
   PHẠM VI: DỮ LIỆU NGUỒN — 2 lớp:
     ref   Danh mục chuẩn hóa — dựng từ nguồn PUBLIC (Luật KDBH 2022,
           NĐ 46/2023, NĐ 67/2023, TT 67/2023, TT 232/2012, NQ 202/2025)
     core  Giao dịch nghiệp vụ — mô hình "hệ thống lõi bảo hiểm" tổng quát
           (hợp đồng → giao dịch → chi tiết phí theo sản phẩm, đồng BH,
           phân bổ doanh thu)
   Căn cứ của từng bảng/cột: xem DESIGN_RATIONALE.md
   Chạy:  psql -d <db> -f 01_ddl.sql
   ===================================================================== */

-- Chạy lại từ đầu (XÓA toàn bộ dữ liệu POC) — bỏ comment nếu cần:
-- DROP SCHEMA IF EXISTS core, ref CASCADE;

CREATE SCHEMA IF NOT EXISTS ref;
CREATE SCHEMA IF NOT EXISTS core;

/* =====================================================================
   LỚP REF — DANH MỤC
   ===================================================================== */

-- Vùng / tỉnh thành theo đơn vị hành chính sau sắp xếp 2025 (34 tỉnh/thành)
CREATE TABLE ref.region (
    region_code      varchar(10)   PRIMARY KEY,   -- BAC / TRUNG / NAM
    region_name      varchar(50)   NOT NULL
);
CREATE TABLE ref.province (
    province_code    varchar(10)   PRIMARY KEY,
    province_name    varchar(100)  NOT NULL,
    region_code      varchar(10)   NOT NULL REFERENCES ref.region(region_code)
);

-- Tổ chức: Tổng công ty -> Công ty thành viên (cây cha-con, nhiều cấp)
CREATE TABLE ref.company (
    company_code        varchar(10)   PRIMARY KEY,
    company_name        varchar(200)  NOT NULL,
    company_type        varchar(20)   NOT NULL,   -- CORPORATION / HEAD_OFFICE / MEMBER / DIGITAL
    parent_company_code varchar(10)   REFERENCES ref.company(company_code),
    province_code       varchar(10)   REFERENCES ref.province(province_code),
    established_date    date
);

-- Nghiệp vụ bảo hiểm (Luật KDBH 2022 Đ7, NĐ 46/2023 Đ4–5) + nhóm phân tích POC
CREATE TABLE ref.line_of_business (
    lob_code         varchar(10)   PRIMARY KEY,
    lob_name         varchar(200)  NOT NULL,
    legal_category   varchar(100)  NOT NULL,   -- Bảo hiểm sức khỏe / Bảo hiểm phi nhân thọ
    poc_group_code   varchar(20)   NOT NULL,   -- XE / CON_NGUOI / TAI_SAN
    poc_group_name   varchar(100)  NOT NULL,
    legal_basis      varchar(300)  NOT NULL
);
-- Dòng báo cáo nghiệp vụ theo TT 67/2023/TT-BTC Phụ lục VI (Mẫu 1-PNT/2-PNT)
CREATE TABLE ref.regulatory_line (
    report_line_code   varchar(10)   PRIMARY KEY,
    report_line_name   varchar(200)  NOT NULL,
    parent_line_code   varchar(10)   REFERENCES ref.regulatory_line(report_line_code),
    legal_basis        varchar(300)  NOT NULL
);
-- Nhóm sản phẩm (cấp giữa Nghiệp vụ và Sản phẩm) — đúng các nhóm nêu trong đề bài
CREATE TABLE ref.product_group (
    product_group_code varchar(20)   PRIMARY KEY,
    product_group_name varchar(100)  NOT NULL,
    lob_code           varchar(10)   NOT NULL REFERENCES ref.line_of_business(lob_code),
    sort_order         int           NOT NULL
);
CREATE TABLE ref.product (
    product_code       varchar(20)   PRIMARY KEY,
    product_name       varchar(300)  NOT NULL,
    product_group_code varchar(20)   NOT NULL REFERENCES ref.product_group(product_group_code),
    report_line_code   varchar(10)   NOT NULL REFERENCES ref.regulatory_line(report_line_code),
    is_compulsory      boolean       NOT NULL,   -- bảo hiểm bắt buộc (NĐ 67/2023)
    pricing_basis      varchar(20)   NOT NULL,   -- TARIFF / RATE_ON_SI / PER_PERSON
    vat_rate           numeric(5,2)  NOT NULL,   -- 0 = không chịu thuế (Luật GTGT 48/2024 Đ5 k8), 10 = còn lại
    max_commission_pct numeric(5,2)  NOT NULL,   -- trần hoa hồng đại lý (TT 67/2023 Điều 51)
    legal_basis        varchar(300),
    solvency2_lob      varchar(60)   NOT NULL    -- đối chiếu quốc tế: Solvency II LoB (Delegated Reg. 2015/35 Annex I)
);

-- Kênh phân phối theo hình thức cung cấp sản phẩm (Luật KDBH 2022 Điều 87 khoản 4)
CREATE TABLE ref.channel (
    channel_code         varchar(20)   PRIMARY KEY,
    channel_name         varchar(150)  NOT NULL,
    report_channel_group varchar(100)  NOT NULL,  -- nhóm kênh Mẫu 3-PNT: Qua tổ chức tín dụng / Qua môi trường mạng / Qua kênh phân phối khác
    legal_basis          varchar(300)  NOT NULL,
    sort_order           int           NOT NULL
);
-- Đối tác phân phối (ẩn danh hóa)
CREATE TABLE ref.partner (
    partner_code     varchar(20)   PRIMARY KEY,
    partner_name     varchar(200)  NOT NULL,
    partner_type     varchar(30)   NOT NULL,   -- NGAN_HANG / CTY_TAI_CHINH / DANG_KIEM / SHOWROOM_OTO / OTA_DU_LICH / VI_DIEN_TU / ...
    channel_code     varchar(20)   NOT NULL REFERENCES ref.channel(channel_code)
);

-- Khách hàng
CREATE TABLE ref.customer_segment (
    segment_code     varchar(20)   PRIMARY KEY,
    segment_name     varchar(100)  NOT NULL,
    is_organization  boolean       NOT NULL
);
CREATE TABLE ref.customer (
    customer_code        varchar(20)   PRIMARY KEY,
    customer_name        varchar(200)  NOT NULL,
    segment_code         varchar(20)   NOT NULL REFERENCES ref.customer_segment(segment_code),
    tax_code             varchar(20),             -- MST (tổ chức)
    province_code        varchar(10)   REFERENCES ref.province(province_code),
    home_company_code    varchar(10)   NOT NULL REFERENCES ref.company(company_code),  -- đơn vị quản lý khách
    is_aggregated_retail boolean       NOT NULL,  -- "khách lẻ theo bảng kê" (đơn lô GCN qua đối tác)
    created_date         date          NOT NULL
);

-- Tiền tệ & tỷ giá hạch toán theo tháng
CREATE TABLE ref.currency (
    currency_code    char(3)       PRIMARY KEY,
    currency_name    varchar(50)   NOT NULL
);
CREATE TABLE ref.fx_rate (
    currency_code    char(3)       NOT NULL REFERENCES ref.currency(currency_code),
    rate_month       date          NOT NULL,   -- ngày đầu tháng
    rate_to_vnd      numeric(18,2) NOT NULL,
    source_note      varchar(200)  NOT NULL,
    PRIMARY KEY (currency_code, rate_month)
);

-- Loại giao dịch: cấp mới, tái tục, SĐBS tăng/giảm phí, hoàn phí, hủy
CREATE TABLE ref.transaction_type (
    txn_type_code        varchar(20)   PRIMARY KEY,
    txn_type_name        varchar(100)  NOT NULL,
    premium_sign         smallint      NOT NULL,   -- +1 / -1 / 0
    is_revenue_deduction boolean       NOT NULL,   -- khoản giảm thu (NĐ 46/2023 Đ49 k3)
    gl_account           varchar(10),              -- TK kế toán (TT 232/2012): 5111 / 5311 / 5321
    acord_business_purpose_cd char(3)    NOT NULL, -- đối chiếu ACORD P&C BusinessPurposeTypeCd: NBS / RWL / PCH / XLC
    note                 varchar(300)
);
-- DN bảo hiểm tham gia đồng bảo hiểm (ẩn danh hóa); 'OWN' = chính công ty
CREATE TABLE ref.insurer (
    insurer_code     varchar(10)   PRIMARY KEY,
    insurer_name     varchar(200)  NOT NULL,
    is_own_company   boolean       NOT NULL
);
-- Loại phân bổ doanh thu giữa các đơn vị
CREATE TABLE ref.allocation_type (
    allocation_type_code varchar(20)   PRIMARY KEY,
    allocation_type_name varchar(150)  NOT NULL,
    note                 varchar(300)
);

/* =====================================================================
   LỚP CORE — GIAO DỊCH
   ===================================================================== */

-- Hợp đồng / đơn bảo hiểm (1 dòng / hợp đồng)
CREATE TABLE core.policy (
    policy_id            bigint        PRIMARY KEY,
    policy_no            varchar(40)   NOT NULL UNIQUE,
    issuing_company_code varchar(10)   NOT NULL REFERENCES ref.company(company_code),  -- đơn vị cấp đơn
    customer_code        varchar(20)   NOT NULL REFERENCES ref.customer(customer_code),
    channel_code         varchar(20)   REFERENCES ref.channel(channel_code),          -- NULL = chưa khai báo (dữ liệu bẩn có chủ đích)
    partner_code         varchar(20)   REFERENCES ref.partner(partner_code),
    currency_code        char(3)       NOT NULL REFERENCES ref.currency(currency_code),
    issue_date           date          NOT NULL,   -- ngày cấp đơn
    effective_date       date          NOT NULL,   -- hiệu lực từ
    expiry_date          date          NOT NULL,   -- hiệu lực đến
    is_group_policy      boolean       NOT NULL,   -- đơn nhóm / theo lô giấy chứng nhận
    renewal_of_policy_id bigint        REFERENCES core.policy(policy_id)
);

-- Giao dịch phát sinh phí của hợp đồng: cấp mới / SĐBS / hoàn phí / hủy
CREATE TABLE core.policy_transaction (
    txn_id           bigint        PRIMARY KEY,
    policy_id        bigint        NOT NULL REFERENCES core.policy(policy_id),
    txn_no           varchar(50)   NOT NULL,
    txn_type_code    varchar(20)   NOT NULL REFERENCES ref.transaction_type(txn_type_code),
    txn_date         date          NOT NULL,   -- ngày chứng từ
    accounting_date  date          NOT NULL,   -- ngày ghi nhận doanh thu (phát sinh trách nhiệm — TT 67/2023 Đ41)
    status           varchar(10)   NOT NULL,   -- APPROVED / PENDING / VOID
    fx_rate          numeric(18,2) NOT NULL,   -- tỷ giá hạch toán (VND = 1)
    created_by       varchar(30)   NOT NULL,
    created_at       timestamp(0)  NOT NULL
);
CREATE INDEX ix_policy_transaction_acc_date ON core.policy_transaction (accounting_date) INCLUDE (policy_id, txn_type_code, status, fx_rate);
CREATE INDEX ix_policy_transaction_policy ON core.policy_transaction (policy_id);

-- Chi tiết phí theo sản phẩm của từng giao dịch (phí 100% hợp đồng, trước đồng BH)
CREATE TABLE core.transaction_coverage (
    coverage_id         bigint        PRIMARY KEY,
    txn_id              bigint        NOT NULL REFERENCES core.policy_transaction(txn_id),
    product_code        varchar(20)   NOT NULL REFERENCES ref.product(product_code),
    sum_insured         numeric(20,2) NOT NULL,   -- số tiền BH (nguyên tệ)
    premium_rate_pct    numeric(9,6),             -- tỷ lệ phí % (sản phẩm tính theo % STBH)
    insured_count       int           NOT NULL,   -- số người / xe / GCN trong lô
    premium_orig        numeric(18,2) NOT NULL,   -- phí 100% nguyên tệ, chưa VAT (âm với hoàn/giảm phí)
    premium_vnd         numeric(18,0) NOT NULL,   -- = premium_orig * fx_rate
    vat_vnd             numeric(18,0) NOT NULL,
    commission_rate_pct numeric(7,4)  NOT NULL
);
CREATE INDEX ix_transaction_coverage_txn ON core.transaction_coverage (txn_id) INCLUDE (product_code, premium_vnd);

-- Đồng bảo hiểm: tỷ lệ tham gia của từng DNBH trên hợp đồng (tổng = 100%)
-- Đơn không đồng BH: 1 dòng insurer_code = 'OWN', role = 'SOLE', share_pct = 100
CREATE TABLE core.coinsurance_share (
    policy_id        bigint        NOT NULL REFERENCES core.policy(policy_id),
    insurer_code     varchar(10)   NOT NULL REFERENCES ref.insurer(insurer_code),
    role             varchar(10)   NOT NULL,   -- LEADER (đồng chính) / FOLLOWER (đồng phụ) / SOLE
    share_pct        numeric(7,4)  NOT NULL,
    PRIMARY KEY (policy_id, insurer_code)
);

-- Phân bổ doanh thu phần của công ty cho các đơn vị (tổng = 100% / hợp đồng)
CREATE TABLE core.revenue_allocation (
    policy_id            bigint        NOT NULL REFERENCES core.policy(policy_id),
    company_code         varchar(10)   NOT NULL REFERENCES ref.company(company_code),
    allocation_type_code varchar(20)   NOT NULL REFERENCES ref.allocation_type(allocation_type_code),
    allocation_pct       numeric(7,4)  NOT NULL,
    PRIMARY KEY (policy_id, company_code)
);


COMMENT ON TABLE core.policy IS 'Hợp đồng bảo hiểm — Luật KDBH 2022; ACORD Policy / IBM IIW Agreement';
COMMENT ON TABLE core.policy_transaction IS 'Giao dịch phí: cấp mới, tái tục, SĐBS, hoàn phí, hủy — NĐ 46/2023 Đ49; TT 232/2012 TK 5111/5311/5321';
COMMENT ON TABLE core.transaction_coverage IS 'Phí 100% theo sản phẩm của giao dịch — TT 232/2012 Đ12 (DT chi tiết theo nghiệp vụ)';
COMMENT ON TABLE core.coinsurance_share IS 'Đồng bảo hiểm — Luật KDBH 2022 Đ4 k29; TT 232/2012 Đ19; TT 67/2023 Đ41 k2';
COMMENT ON TABLE core.revenue_allocation IS 'Phân bổ doanh thu phần công ty cho đơn vị (thông lệ quản trị Tổng công ty – công ty thành viên)';
