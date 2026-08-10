create database if not exists churn_analysis;
drop database IF exists churn_analysis;
use churn_analysis;
CREATE TABLE customers (
    customer_id varchar(50) PRIMARY KEY,
    churn_probability bigint,
    risk_segment varchar(30),
    payment_delay_days int,
    complaints_last_6m int,
    usage_trend_pct int,
    engagement_score int,
    login_frequency varchar(20),
    churned INT,
    age INTEGER,
    gender varchar(20),
    subscription_type varchar(20),
    watch_hours float,
    last_login_days INT,
    region TEXT,
    device TEXT,
    monthly_fee float,
    payment_method TEXT,
    number_of_profiles INT,
    avg_watch_time_per_day float,
    favorite_genre varchar(20)
);
select*from customers;

-- Overall churn rate 
SELECT churned, 
       COUNT(*) AS customers,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS pct
FROM customers
GROUP BY churned;
SHOW COLUMNS FROM customers WHERE Field = 'churned';
-- Churn rate by login frequency
SELECT login_frequency, 
       COUNT(*) AS customers,
       ROUND(AVG(CAST(churned AS SIGNED)) * 100, 2) AS churn_rate_pct
FROM customers
GROUP BY login_frequency
ORDER BY churn_rate_pct DESC;
-- Churn rate by payment delay band
SELECT
    CASE
        WHEN payment_delay_days = 0 THEN '0 days'
        WHEN payment_delay_days BETWEEN 1 AND 5 THEN '1-5 days'
        WHEN payment_delay_days BETWEEN 6 AND 15 THEN '6-15 days'
        ELSE '15+ days'
    END AS payment_delay_band,
    COUNT(*) AS customers,
    ROUND(AVG(churned) * 100, 2) AS churn_rate_pct
FROM customers
GROUP BY payment_delay_band
ORDER BY churn_rate_pct DESC;
-- Churn rate by complaints
SELECT complaints_last_6m, 
       COUNT(*) AS customers,
       ROUND(AVG(churned) * 100, 2) AS churn_rate_pct
FROM customers
GROUP BY complaints_last_6m
ORDER BY complaints_last_6m;
-- Churn rate by usage trend
SELECT
    CASE
        WHEN usage_trend_pct <= -30 THEN 'Sharp decline'
        WHEN usage_trend_pct <= 0   THEN 'Mild decline'
        WHEN usage_trend_pct <= 30  THEN 'Stable/Growing'
        ELSE 'Strong growth'
    END AS usage_trend_band,
    COUNT(*) AS customers,
    ROUND(AVG(churned) * 100, 2) AS churn_rate_pct
FROM customers
GROUP BY usage_trend_band
ORDER BY churn_rate_pct DESC;
-- Churn rate by region + subscription plan
SELECT region, subscription_type, 
       COUNT(*) AS customers,
       ROUND(AVG(churned) * 100, 2) AS churn_rate_pct
FROM customers
GROUP BY region, subscription_type
ORDER BY churn_rate_pct DESC;
-- High-risk customer list
SELECT customer_id, payment_delay_days, complaints_last_6m,
       usage_trend_pct, login_frequency, churned
FROM customers
WHERE payment_delay_days > 10
   OR complaints_last_6m >= 2
   OR usage_trend_pct < -30
ORDER BY payment_delay_days DESC;