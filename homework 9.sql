USE ap;

-- 1)
SELECT invoice_total, ROUND(invoice_total, 1), ROUND(invoice_total, 0), TRUNCATE(invoice_total, 0)
FROM invoices;

-- 2)
USE ex;
SELECT *
FROM date_sample;

SELECT start_date, DATE_FORMAT(start_date, '%b/%m/%d/%y' ) AS `Pretty`, DATE_FORMAT(start_date, '%c/%e/%y' ) AS `int`, DATE_FORMAT(start_date, '%l:%i %p') AS `Weird shit`
FROM date_sample;

-- 3)

USE ap;

SELECT vendor_name, UPPER(vendor_name), vendor_phone, RIGHT(vendor_phone, 4), REPLACE(vendor_phone, '-', '.'), 
IF(LOCATE(' ',vendor_name) > 0, SUBSTRING_INDEX(SUBSTRING_INDEX(vendor_name, ' ', 2), ' ', -1), '')
FROM vendors;

-- 4)
SELECT * FROM invoices;

SELECT invoice_number, invoice_date, DATE_ADD(invoice_date, INTERVAL 30 DAY) , payment_date, DATEDIFF(invoice_date, payment_date) AS days_to_pay, MONTH(invoice_date), YEAR(invoice_date)
FROM invoices;
-- 5)
USE ex;

SELECT * FROM string_sample;

SELECT emp_id, LEFT(emp_name, LOCATE(' ', emp_name) -1) AS `first name`, SUBSTRING(emp_name, LOCATE(' ', emp_name) +1) AS `last name`
FROM string_sample;
-- 6)
USE ap;
SELECT * FROM invoices;

SELECT invoice_number, invoice_total - payment_total - credit_total AS `balance due`,
RANK() OVER (ORDER BY invoice_total - payment_total - credit_total  DESC) AS ` rank`
FROM invoices
WHERE invoice_total - payment_total - credit_total > 0;
