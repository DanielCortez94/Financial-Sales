-- DATA CLEANING / Data Preprocessing

-- Convert numerical columns(nvarchar to float)
ALTER TABLE dbo.Financials
ALTER COLUMN Gross Sales FLOAT;

ALTER TABLE dbo.Financials
ALTER COLUMN Sales FLOAT;

ALTER TABLE dbo.Financials
ALTER COLUMN COGS FLOAT;

ALTER TABLE dbo.Financials
ALTER COLUMN Profit FLOAT;

-- Delete "$" , ","
UPDATE dbo.Financials
SET [Sale_Price] = REPLACE(REPLACE([Sale_Price], '$', ''), ',', ''),
	[Sales] = REPLACE(REPLACE([Sales], '$', ''), ',', ''),
	[COGS]= REPLACE(REPLACE([COGS], '$', ''), ',', ''),
	[Profit]= REPLACE(REPLACE([Profit], '$', ''), ',', '')

-- Update the Date column
ALTER TABLE dbo.Financials
ALTER COLUMN Date DATE;

-- MAIN QUERIES

-- Sales Perfomance by Segment and Country 
SELECT 
	Segment, 
	Country, 
	Product, 
	SUM(Sales) AS Total_Sales
FROM dbo.Financials
GROUP BY Segment, Country, Product
ORDER BY Total_Sales DESC;

-- Seasonality and Temporal Trends
SELECT 
	Country, 
	Years, 
	[Month Name], 
	SUM(Profit) AS Total_Profit
FROM dbo.Financials
GROUP BY Country, Years, [Month Name]
ORDER BY Years DESC,Total_Profit DESC;

-- Impact of Discounts and Promotions
SELECT 
	Product, 
	SUM(Discounts) AS Total_Discounts
FROM dbo.Financials
GROUP BY Product
ORDER BY Total_Discounts DESC;

-- Customer Segmentation and Purchasing Behavior
SELECT 
	Segment, Country, 
	SUM([Units Sold]) AS Total_Units_Sold
FROM dbo.Financials
GROUP BY Segment, Country
ORDER BY Total_Units_Sold DESC;

-- Profibality Analysis

SELECT 
	Product, 
	SUM(Profit) AS Total_Profit
FROM dbo.Financials
GROUP BY Product
ORDER BY Total_Profit DESC;

-- Profitability Margin by Product
SELECT 
    Product,
    SUM(Profit) AS Total_Profit,
    SUM(Sales) AS Total_Sales,
    (SUM(Profit) / SUM(Sales)) * 100 AS Profit_Margin_Percentage
FROM dbo.Financials
GROUP BY Product
ORDER BY Profit_Margin_Percentage DESC;

-- Temporal Analysis of Profitability
SELECT 
    [Month Number],
    [Month Name], 
    SUM(Profit) AS Total_Profit
FROM dbo.Financials
GROUP BY [Month Number], [Month Name]
ORDER BY [Month Number];

-- Monthly Analysis of Profitability and Best Selling Product
WITH MonthlySales AS (
    SELECT 
        [Month Number],
        [Month Name],
        Product,
        SUM([Units Sold]) AS Total_Units_Sold,
        SUM(Profit) AS Total_Profit,
        ROW_NUMBER() OVER (PARTITION BY [Month Number] ORDER BY SUM([Units Sold]) DESC) AS Rank
    FROM dbo.Financials
    GROUP BY [Month Number], [Month Name], Product
)
SELECT 
    ms.[Month Number],
    ms.[Month Name],
    ms.Total_Profit,
    ms.Product AS Top_Product,
    ms.Total_Units_Sold
FROM (
    SELECT 
        [Month Number],
        [Month Name],
        SUM(Profit) AS Total_Profit
    FROM dbo.Financials
    GROUP BY [Month Number], [Month Name]
) mp
JOIN MonthlySales ms 
    ON mp.[Month Number] = ms.[Month Number] AND ms.Rank = 1
ORDER BY ms.[Month Number];