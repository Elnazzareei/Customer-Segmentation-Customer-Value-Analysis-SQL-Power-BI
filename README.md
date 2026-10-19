# Customer-Segmentation-Customer-Value-Analysis-SQL-Power-BI
Using PostgreSQL and SQL for data preparation, customer-level analysis, and RFM segmentation, and Power BI for interactive visualization, the project translates transactional data into business insights and actionable recommendations.
# Project Overview
This project analyzes customer purchasing behavior using the Olist Brazilian E-Commerce Public Dataset to understand who the customers are, how frequently they purchase, how recently they purchased, and how customer value differs across segments.
Using PostgreSQL and SQL for data preparation, customer-level analysis, and RFM segmentation, and Power BI for interactive visualization, the project translates transactional data into business insights and actionable recommendations.
The analysis focuses on three key questions:
-Who are the most valuable customers?
-Which customer groups show opportunities for repeat purchases or reactivation?
-What actions could help improve customer engagement, retention, and customer value?
# Business Problem
E-commerce businesses need to understand differences in customer behavior to allocate marketing and retention resources effectively. However, transaction-level data alone does not clearly reveal which customers are valuable, which have not purchased recently, or which may have potential for repeat purchases.
The objective of this project was to transform raw e-commerce data into a customer-level analytical dataset, segment customers using RFM-based rules, and develop dashboards that support data-informed business decisions.
Dataset.
# Source: Olist Brazilian E-Commerce Public Dataset, available on Kaggle.
The dataset contains historical e-commerce transactions and related customer, order, product, payment, and review information from 2016–2018.
The project used the following datasets:
Orders: Order identifiers, customer identifiers, order status, and timestamps.
Customers: Customer identifiers and customer location information.
Order Items: Products purchased, item prices, and freight values.
Payments: Payment values, payment methods, and installment information.
Reviews and Products: Additional datasets available for broader e-commerce analysis; the core customer segmentation workflow focused on orders, customers, order items, and payments.
The final customer segmentation dataset contains 93,358 unique customers with delivered-order-based behavioral metrics.
# Tools & Technologies
PostgreSQL: Data preparation, joins, aggregations, and customer-level analysis.
DBeaver: SQL development and database exploration.
Power BI: Interactive dashboards, KPI cards, charts, slicers, and business insights.
SQL: Data validation, common table expressions, aggregations, window functions, and customer segmentation logic.
# Analytical Workflow
1. Data Exploration and Validation
The raw datasets were inspected to understand their structure, key columns, missing values, duplicate records, and relationships between tables.
Key checks included:
Reviewing record counts and key fields.
Checking duplicate customer identifiers.
Inspecting missing or invalid values in important columns.
Validating relationships between orders, customers, order items, and payments.
Checking unmatched order-item records.
These checks helped identify data quality issues before building the analytical dataset.
2. Data Cleaning and Preparation
The raw tables were transformed into cleaned tables using SQL.
The preparation process included:
Standardizing relevant fields and handling empty values.
Converting order timestamps into appropriate date/time formats.
Validating customer and order identifiers.
Preparing cleaned order-item and payment datasets.
Aggregating order items and payments separately at the order level.
Separate order-level aggregations were important to prevent row multiplication when joining order items and payment records. This helped preserve accurate order values.
3. Customer-Level Data Modeling
The cleaned datasets were combined to create an order-level analytical table and a customer-level dataset.
The analysis used customer_unique_id to identify individual customers across orders, rather than treating every order-level customer identifier as a separate person.
Only delivered orders were included in the core customer value and RFM analysis.
Customer-level metrics were then calculated, including:
Total customer value based on delivered-order payment amounts.
Number of delivered orders.
Days since the most recent delivered order.
Recency, frequency, and monetary scores.
The resulting customer-level table provided a consistent foundation for segmentation and visualization.
4. RFM Analysis
RFM stands for:
Recency (R): How recently a customer made a purchase. Lower recency in days indicates a more recent purchase.
Frequency (F): How many delivered orders a customer placed.
Monetary (M): The customer's cumulative value based on delivered-order payments.
Customers were assigned scores for Recency, Frequency, and Monetary value. These scores were combined to create an overall RFM score.
The Recency and Monetary scores were based on quintile-based scoring, while Frequency scoring reflected the number of delivered orders, with customers placing five or more orders receiving the highest frequency score.
The recency reference date was set to 30 August 2018, based on the end of the dataset's observation period.
5. Customer Segmentation
Customers were grouped into six segments using custom business rules based on RFM scores:
High-Value Recent Customers: Recent buyers with high monetary scores.
Loyal Customers: Customers with stronger repeat-purchase behavior and relatively high customer value.
Recent One-Time Customers: Recent buyers with only one delivered order and lower monetary scores.
Developing Customers: Customers who do not meet the criteria for the other segments.
Needs Attention. Customers with high recency in days who may warrant re-engagement.
Low-Value Inactive: Customers with high recency in days and low monetary scores.
These are project-defined analytical segments, not official categories supplied by Olist. The labels describe historical purchasing patterns and do not independently establish future customer behavior or churn.
6. Power BI Dashboard Development
The final customer-level dataset was imported into Power BI to create two complementary report pages.
Dashboard 1: Customer Segmentation & Customer Value Analysis
This page provides an executive overview of the customer base, including:
Total customers.
Total customer value.
Average customer value.
Average orders per customer.
Customer distribution by segment.
Total customer value by segment.
Average customer value by segment.
Average recency by segment.
Customer count versus average customer value.
Key insights and business recommendations.
Dashboard 2: Customer Behavior & RFM Analysis
This page focuses on customer purchasing patterns and segment-level behavior, including:
Average orders per customer by segment.
Average recency by segment.
Recency versus customer value.
Customer segment performance table.
RFM score distribution.
Customer Segment and RFM Score filters.
Targeted insights and recommendations.
The two-page structure separates executive-level customer value analysis from the more detailed investigation of customer behavior.
# Key Findings
The final analytical dataset contains 93,358 unique customers and approximately 15.42 million in cumulative customer payment value.
The principal findings are summarized below.
Needs Attention: 21,895 customers (23.45%). Average recency: 394.1 days. Average orders per customer: 1.05. Average customer value: 242.15. Total customer value: 5,301,788.32.
-High-Value Recent Customers: 15,401 customers (16.50%). Average recency: 91.8 days. Average orders per customer: 1.08. Average customer value: 306.57. Total customer value: 4,721,504.77.
-Developing Customers: 18,168 customers (19.46%). Average recency: 219.9 days. Average orders per customer: 1.01. Average customer value: 151.49. Total customer value: 2,752,133.45.
-Recent One-Time Customers: 21,725 customers (23.27%). Average recency: 90.3 days. Average orders per customer: 1.00. Average customer value: 72.93. Total customer value: 1,584,395.74.
-Low-Value Inactive: 15,447 customers (16.55%). Average recency: 396.5 days. Average orders per customer: 1.01. Average customer value: 55.81. Total customer value: 862,039.28.
-Loyal Customers: 722 customers (0.77%). Average recency: 193.1 days. Average orders per customer: 2.08. Average customer value: 277.46. Total customer value: 200,600.23.
-Overall: The dataset contains 93,358 unique customers with a total customer value of approximately 15,422,461.79.
Values are rounded. Customer share may differ slightly from 100% due to rounding.
1. Needs Attention Represents a Significant Customer Group
This segment contains 21,895 customers, representing approximately 23.45% of the customer base. Its cumulative customer value is approximately 5.30 million, while average recency is about 394 days.
Business implication: This group may warrant a targeted reactivation strategy, especially because of its substantial historical customer value.
2. High-Value Recent Customers Have the Highest Average Customer Value
The segment contains 15,401 customers and has the highest average customer value at approximately 306.57. Average recency is about 92 days.
However, average order frequency is only 1.08.
Business implication: Personalized retention, cross-selling, and relevant follow-up offers could be tested to encourage additional purchases from these customers.
3. Recent One-Time Customers Present a Repeat-Purchase Opportunity
This segment contains 21,725 customers, or approximately 23.27% of the customer base. Its average order frequency is 1.00, and average recency is approximately 90 days.
Business implication: Post-purchase follow-ups and second-order incentives could be tested to determine whether recent one-time buyers can be encouraged to purchase again.
4. Loyal Customers Form a Small but Distinct Segment
Only 722 customers, or approximately 0.77% of the customer base, are classified as Loyal Customers. Their average order frequency is 2.08, the highest among the six segments.
Business implication: Examining their purchasing patterns may help identify behaviors associated with repeat purchases and inform customer loyalty initiatives.
5. Customer Value and Purchase Frequency Are Not the Same
High-Value Recent Customers have the highest average customer value, whereas Loyal Customers have the highest average order frequency.
Business implication: Customer value and purchase frequency should be analyzed separately when designing customer retention and engagement strategies.
# Business Recommendations
Based on the findings, the following actions could be tested:
1. Encourage Repeat Purchases
Test follow-up messages and second-order incentives for recent one-time buyers. Measure success using the second-purchase rate.
2. Reactivate Customers
Test targeted win-back campaigns for the Needs Attention segment. Measure success using the reactivation rate.
3. Retain High-Value Customers
Test personalized offers and relevant cross-selling opportunities for high-value customers. Measure success using the repeat-purchase rate and customer value.
4. Strengthen Loyalty
Analyze Loyal Customers’ purchasing patterns and test loyalty or referral initiatives. Measure success using repeat-purchase frequency and referral conversion.
5. Improve Segmentation
Monitor customer behavior across segments and compare campaign results between customer groups. Measure success using segment migration and campaign conversion rate.
These recommendations are hypotheses for business testing rather than proven causal effects. Campaign performance should be measured before deciding whether to expand an intervention.
# Limitations and Considerations
Historical data: The dataset covers 2016–2018 and does not describe the current customer base.
Customer value: Total customer value represents cumulative delivered-order payment value, not net revenue or profit.
Segmentation rules: The six segments are defined by custom analytical rules and may change if different thresholds or business objectives are used.
Behavioral interpretation: High recency in days indicates a longer period since the last observed purchase; it does not prove that a customer has permanently churned.
No causal evaluation: The project identifies potential business opportunities but does not establish that the proposed campaigns would improve retention or revenue.
# Project Outcome
This project demonstrates an end-to-end analytical workflow, from raw transactional data and SQL-based data preparation to customer-level metrics, RFM scoring, segmentation, and interactive Power BI dashboards.
The final output turns complex transaction data into interpretable customer groups, highlights differences in customer value and purchasing behavior, and provides measurable hypotheses for customer engagement and retention.
# Skills Demonstrated
SQL data cleaning and validation.
Relational data modeling and join management.
Order-level and customer-level aggregations.
Window functions and RFM scoring.
Customer segmentation using business rules.
KPI development and interactive Power BI reporting.
Exploratory customer behavior analysis.
Business insight communication and data-driven recommendations.
