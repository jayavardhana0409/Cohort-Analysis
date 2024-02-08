# Retail Sales Cohort Analysis
This repository contains SQL queries for a cohort analysis on a retail sales dataset. The analysis aims to understand customer behavior and retention rates over time.

### Table of Contents
Introduction
Cohort Analysis
Dynamic SQL

### Introduction
Cohort analysis is a statistical method used to analyze and understand the behavior of customer cohorts over time. In this project, we perform cohort analysis on a retail sales dataset, creating temporary tables and calculating cohort retention rates.

### Cohort Analysis
#Online_Retail
This temporary table filters records with non-null CustomerID from the original table.

### online_retail_main
Clean data is obtained by removing records with Quantity or UnitPrice less than or equal to 0 and handling duplicates.

### cohort
This temporary table defines cohorts with CustomerID, first_purchase_date, and Cohort_Date.

### cohort_retention
Cohort indices are calculated based on the difference between InvoiceDate and Cohort_Date.

### cohort_pivot
A pivoted table is created for visualizing cohort data.

Dynamic SQL
Dynamic SQL is used to create a pivot table dynamically based on cohort indices.

![Cohort Analysis](https://github.com/jayavardhana0409/Cohort-Analysis/blob/main/Dashboard%201.png)
