--ex1
alter table sales_dataset_rfm_prj
alter COLUMN quantityordered type int USING(quantityordered::int);
alter table sales_dataset_rfm_prj
alter COLUMN priceeach type numeric USING(priceeach::numeric);
alter table sales_dataset_rfm_prj
alter COLUMN orderlinenumber type int USING(orderlinenumber::int);
alter table sales_dataset_rfm_prj
alter COLUMN sales type numeric USING(sales::numeric);
ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN orderdate TYPE DATE USING TO_DATE(orderdate, 'DD/MM/YYYY HH24:MI');
alter table sales_dataset_rfm_prj
alter COLUMN msrp type decimal USING(msrp::decimal);
--ex2
SELECT *
FROM sales_dataset_rfm_prj
WHERE 
     (ORDERNUMBER IS NULL OR CAST(ORDERNUMBER AS TEXT) = '') OR
    (QUANTITYORDERED IS NULL OR CAST(QUANTITYORDERED AS TEXT) = '') OR
    (PRICEEACH IS NULL OR CAST(PRICEEACH AS TEXT) = '') OR
    (ORDERLINENUMBER IS NULL OR CAST(ORDERLINENUMBER AS TEXT) = '') OR
    (SALES IS NULL OR CAST(SALES AS TEXT) = '') OR
    ORDERDATE IS NULL;
--ex3
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN CONTACTLASTNAME VARCHAR(50), -- Điều chỉnh độ dài tương ứng với độ dài tên
    ADD COLUMN CONTACTFIRSTNAME VARCHAR(50);
-- Cập nhật dữ liệu trong cột mới
--
UPDATE sales_dataset_rfm_prj
SET --SỬ DỤNG HÀM SPLIT_PART ĐỂ CHIA CHUỖI CONTACTFULLNAME
    CONTACTLASTNAME = INITCAP(SPLIT_PART(CONTACTFULLNAME, '-', 1)),--HÀM INITCAP ĐƯỢC DÙNG ĐỂ CHUẨN HÓA THEO YÊU CẦU
    CONTACTFIRSTNAME = INITCAP(SPLIT_PART(CONTACTFULLNAME, '-', 2))
WHERE POSITION('-' IN CONTACTFULLNAME) > 0;
--ex4
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN QTR_ID INT,
    ADD COLUMN MONTH_ID INT,
    ADD COLUMN YEAR_ID INT;
-- Cập nhật dữ liệu trong cột mới
--
UPDATE sales_dataset_rfm_prj
SET 
    QTR_ID = EXTRACT(QUARTER FROM ORDERDATE),
    MONTH_ID = EXTRACT(MONTH FROM ORDERDATE),
    YEAR_ID = EXTRACT(YEAR FROM ORDERDATE);
--ex5
with cte as
(
select QUANTITYORDERED,
(select avg(QUANTITYORDERED)
from sales_dataset_rfm_prj) as avg,
(select stddev (QUANTITYORDERED)
from sales_dataset_rfm_prj) as stddev
from sales_dataset_rfm_prj)
select QUANTITYORDERED,(QUANTITYORDERED-avg)/stddev as z_score from cte
where QUANTITYORDERED IN (
    SELECT QUANTITYORDERED
    FROM sales_dataset_rfm_prj
    GROUP BY QUANTITYORDERED
    HAVING ABS((QUANTITYORDERED - avg)) /stddev > 1 --phần này em để >2 và >3 thì không có cái nào ạ
);
-- Bước 2: Xử lý outlier - Xóa bản ghi chứa outlier
DELETE FROM sales_dataset_rfm_prj
WHERE ABS((QUANTITYORDERED - AVG(QUANTITYORDERED)) / STDDEV(QUANTITYORDERED)) > 3;
-- Bước 3: Xử lý outlier - Thay thế outlier bằng giá trị trung bình
UPDATE sales_dataset_rfm_prj
SET QUANTITYORDERED = AVG(QUANTITYORDERED)
WHERE QUANTITYORDERED IN (
    SELECT QUANTITYORDERED
    FROM sales_dataset_rfm_prj
    GROUP BY QUANTITYORDERED
    HAVING ABS((QUANTITYORDERED - avg)) /stddev > 2 
);
--ex6
CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS
SELECT *
FROM sales_dataset_rfm_prj;


