-- Create a temporary table #Online_Retail with non-null CustomerID records from the original table
select * 
into #Online_Retail
from [Retail Sales database].[dbo].[Online Retail]
where CustomerID is not Null;

-- Create another temporary table #online_retail_main with clean data by removing records with Quantity or UnitPrice less than or equal to 0 and handling duplicates
with online_retail as
(
    SELECT *
    FROM #Online_Retail
    WHERE CustomerID != 0
),
quantity_unit_price as 
(
    select *
    from online_retail
    where Quantity > 0 and UnitPrice > 0
),
dup_check as
(
    select *, ROW_NUMBER() over (partition by InvoiceNo, StockCode, Quantity order by InvoiceDate) as dup_flag
    from quantity_unit_price
)
select *
into #online_retail_main
from dup_check
where dup_flag = 1;

-- Cohort Analysis
-- A cohort is a group of individuals who share a common characteristic or experience within a specific time frame. 
-- For example, customers who made their first purchase in a particular month form a cohort.
-- Create a temporary table #cohort with CustomerID, first_purchase_date, and Cohort_Date
select
    CustomerID,
    min(InvoiceDate) as first_purchase_date,
    DATEFROMPARTS(year(min(InvoiceDate)), month(min(InvoiceDate)), 1) as Cohort_Date
into #cohort
from #online_retail_main
group by CustomerID;

-- Create a temporary table #cohort_retention with cohort_index calculated based on the difference between InvoiceDate and Cohort_Date
select
    mmm.*,
    cohort_index = year_diff * 12 + month_diff + 1
into #cohort_retention
from
    (
        select
            mm.*,
            year_diff = invoice_year - cohort_year,
            month_diff = invoice_month - cohort_month
        from
            (
                select
                    m.*,
                    c.Cohort_Date,
                    year(m.InvoiceDate) as invoice_year,
                    month(m.InvoiceDate) as invoice_month,
                    year(c.Cohort_Date) as cohort_year,
                    month(c.Cohort_Date) as cohort_month
                from #online_retail_main m
                left join #cohort c on m.CustomerID = c.CustomerID
            ) mm
    ) mmm;

-- Create a temporary table #cohort_pivot for cohort table in a pivoted form
select *
into #cohort_pivot
from (
    select distinct 
        CustomerID,
        Cohort_Date,
        cohort_index
    from #cohort_retention
) tbl
pivot (
    Count(CustomerID)
    for Cohort_Index In ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13])
) as pivot_table;

-- Calculate and display the cohort retention rates using dynamic SQL
DECLARE 
    @columns NVARCHAR(MAX) = '',
    @sql     NVARCHAR(MAX) = '';

SELECT 
    @columns += QUOTENAME(cohort_index) + ','
FROM 
    (select distinct cohort_index from #cohort_retention) m
ORDER BY 
    cohort_index;

SET @columns = LEFT(@columns, LEN(@columns) - 1);

-- Display cohort retention rates
SELECT Cohort_Date ,
    round((1.0 * [1]/[1] * 100),2) as [1],
    round(1.0 * [2]/[1] * 100,2) as [2], 
    round(1.0 * [3]/[1] * 100,2) as [3],  
    round(1.0 * [4]/[1] * 100,2) as [4],  
    round(1.0 * [5]/[1] * 100,2) as [5], 
    round(1.0 * [6]/[1] * 100,2) as [6], 
    round(1.0 * [7]/[1] * 100,2) as [7], 
    round(1.0 * [8]/[1] * 100,2) as [8], 
    round(1.0 * [9]/[1] * 100,2) as [9], 
    round(1.0 * [10]/[1] * 100,2) as [10],   
    round(1.0 * [11]/[1] * 100,2) as [11],  
    round(1.0 * [12]/[1] * 100,2) as [12],  
    round(1.0 * [13]/[1] * 100,2) as [13]
FROM #cohort_pivot
ORDER BY Cohort_Date;

-- Dynamic SQL to create a pivot table
-- This will generate a list of cohort_index columns for use in dynamic SQL
-- The columns will be used in the PIVOT clause to create a dynamic pivot table
PRINT @columns;
