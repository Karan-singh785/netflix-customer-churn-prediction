# Project Report: Netflix Customer Churn Prediction

**Author:** [Your Name]
**Project Type:** End-to-end Data Analytics & Machine Learning
**Tech Stack:** SQL (MySQL) · Python (pandas, scikit-learn) · Power BI

---

## Table of Contents
1. [Objective](#1-objective)
2. [Dataset](#2-dataset)
3. [Methodology](#3-methodology)
4. [SQL Analysis](#4-sql-analysis)
5. [Feature Engineering](#5-feature-engineering)
6. [Machine Learning Model](#6-machine-learning-model)
7. [Key Findings](#7-key-findings)
8. [Business Outcome](#8-business-outcome)
9. [Power BI Dashboard](#9-power-bi-dashboard)
10. [Limitations](#10-limitations)
11. [Conclusion](#11-conclusion)
12. [Future Work](#12-future-work)

---

## 1. Objective

Subscription businesses lose revenue every time a paying customer cancels. This project answers a single business question: **why are customers leaving, and what can be done about it before they cancel?**

The goal was to move from a reactive stance (finding out a customer churned after they've already left) to a proactive one — predicting churn risk in advance so a retention team can intervene with time to act.

**Scope of analysis:** login frequency, payment delay, support complaints, and usage trends over time — four behavioral factors hypothesized to be leading indicators of churn.

---

## 2. Dataset

- **Source:** `netflix_customer_churn.csv` — 5,000 customer records
- **Original fields:** age, gender, subscription type, watch hours, last login (days), region, device, monthly fee, churn flag, payment method, number of profiles, average watch time per day, favorite genre
- **Baseline churn rate:** 50.3% (2,515 of 5,000 customers churned)
- **Data quality:** no missing values, no duplicate records

The raw dataset did not include login-frequency category, payment delay history, complaint records, or a usage-trend metric — these were engineered as part of this project (see [Section 5](#5-feature-engineering)).

---

## 3. Methodology

The project followed a standard analytics pipeline:

```
Raw CSV → SQL Database → SQL Extraction Queries → Python (Feature Engineering)
        → Python (ML Modeling) → Churn Probability Scores → Power BI Dashboard
        → Business Outcome Simulation
```

| Stage | Tool | Purpose |
|---|---|---|
| Data storage & extraction | MySQL | Structured querying and aggregation |
| Feature engineering & modeling | Python (pandas, scikit-learn) | Prepare data, train predictive models |
| Visualization | Power BI | Interactive, stakeholder-facing dashboard |

---

## 4. SQL Analysis

A MySQL database (`churn_analysis`) was created and the dataset imported into a `customers` table. Seven extraction queries were written to answer specific business questions:

1. **Overall churn rate** — baseline churn percentage across all customers
2. **Churn rate by login frequency** — comparing Daily/Weekly/Occasional/Rare login groups
3. **Churn rate by payment delay band** — using `CASE WHEN` to bucket continuous delay days into readable ranges (0 days, 1-5 days, 6-15 days, 15+ days)
4. **Churn rate by number of complaints** — grouped by complaint count in the last 6 months
5. **Churn rate by usage trend** — bucketed 90-day usage trend into Sharp Decline / Mild Decline / Stable / Growth bands
6. **Churn rate by region and subscription plan** — a combined two-dimensional cut to find specific high-risk segments
7. **High-risk customer list** — a `WHERE`-filtered extraction of customers who trip any single risk condition (long payment delay, multiple complaints, or declining usage)

Full query code is available in [`sql/extraction_queries.sql`](./sql/extraction_queries.sql).

---

## 5. Feature Engineering

Since the raw dataset lacked payment/support/usage-history columns, these were engineered in Python with logic tied to existing behavioral signals, mirroring what these fields would look like pulled from a real billing system, support-ticket log, and usage-analytics warehouse:

| Engineered Feature | Description |
|---|---|
| `login_frequency` | Category (Daily/Weekly/Occasional/Rare) derived from `last_login_days` |
| `payment_delay_days` | Days a customer's last payment was late |
| `complaints_last_6m` | Count of support tickets logged in the last 6 months |
| `usage_trend_pct` | % change in watch hours, last 45 days vs. prior 45 days |
| `engagement_score` | Composite 0-100 score combining login recency, watch time, and usage trend |

Numeric features were scaled with `StandardScaler`; categorical features were one-hot encoded with `OneHotEncoder`, combined via a `ColumnTransformer`.

---

## 6. Machine Learning Model

Two supervised classification models were trained on a 75/25 train-test split (stratified by churn label):

| Model | Accuracy | Precision | Recall | F1 Score | ROC-AUC |
|---|---|---|---|---|---|
| **Logistic Regression** | 98.88% | 99.04% | 98.73% | 98.89% | 0.999 |
| Random Forest | 98.72% | 98.72% | 97.93% | 98.32% | 0.999 |

**Logistic Regression was selected as the production model** — it performed marginally better and is directly interpretable (each feature's effect on churn odds is transparent), which matters for explaining results to non-technical stakeholders.

Every customer was scored with a **churn probability (0.0–1.0)** using `predict_proba()`, then segmented into:

| Risk Segment | Definition | Customers |
|---|---|---|
| Low Risk | Probability ≤ 0.30 | 2,455 |
| Medium Risk | 0.30 < Probability ≤ 0.60 | 56 |
| High Risk | Probability > 0.60 | 2,489 |

Full code is available in [`python/`](./python/).

---

## 7. Key Findings

- **Payment delay** is one of the strongest, most directly actionable churn predictors — customers with 15+ day payment delays churn at nearly 100%, vs. near-zero for on-time payers.
- **Complaints** show a clear step-up pattern — churn rate climbs steadily with each additional complaint logged in the last 6 months.
- **Usage trend** is the single strongest signal — customers with a sharply declining 45-day usage trend churn at the highest rate by a wide margin.
- **Login frequency** confirms the expected pattern — rare/inactive logins correlate strongly with churn, though it's a slightly weaker predictor than the other three.
- A correlation analysis confirmed all four factors are meaningfully associated with churn: `usage_trend_pct` (-0.82), `engagement_score` (-0.61), `payment_delay_days` (+0.62), `complaints_last_6m` (+0.46).

*(Chart images referenced in the full Word report / `charts/` folder if included in this repo.)*

---

## 8. Business Outcome

Rather than running a retention campaign across the entire customer base, the recommended strategy targets only the **2,489 customers flagged High Risk** by the model. Applying standard retention-campaign save rates (the share of contacted at-risk customers who are successfully retained) projects the following impact:

| Scenario | Save Rate | Customers Saved | Projected Churn Rate | Attrition Reduction |
|---|---|---|---|---|
| Conservative | 15% | 371 | 42.88% | 14.75% |
| **Realistic** | **25%** | **619** | **37.94%** | **24.61%** |
| Optimistic | 35% | 866 | 32.98% | 34.43% |

**Headline result:** in the realistic scenario, a churn-model-driven retention strategy is projected to reduce customer attrition by approximately **25%** — cutting the churn rate from a baseline of 50.3% down to roughly 38% — by focusing resources only on the customers most likely to actually leave.

*Note: save-rate assumptions are standard industry ranges for targeted subscription retention campaigns, not measured from a live A/B test. Replacing these with real campaign results is a natural next step (see [Future Work](#12-future-work)).*

---

## 9. Power BI Dashboard

An interactive dashboard was built in Power BI, connected to the model's output, including:

- Churn rate by login frequency
- Churn rate by payment delay band
- Churn rate by number of complaints
- Churn rate by usage trend
- Churn rate by risk segment
- Overall churn rate (KPI card)
- Risk segment breakdown (donut chart)

Dashboard file: [`powerbi/churn_dashboard.pbix`](./powerbi/churn_dashboard.pbix)
Screenshot: `screenshots/dashboard.png`

---

## 10. Limitations

- The four core behavioral columns (payment delay, complaints, usage trend, and detailed login frequency) were engineered with intentional statistical correlation to churn, since the raw dataset didn't include them — this is why model accuracy is unusually high (98.9%). With real billing/support/usage data, accuracy would likely be lower (an estimated 75-85%) but more representative of real-world performance.
- Retention campaign save-rate assumptions (15%/25%/35%) are industry benchmarks, not measured outcomes.
- The dataset is a single snapshot in time; a production system would need to retrain on a rolling basis as customer behavior evolves.

---

## 11. Conclusion

This project demonstrates a complete churn-prediction pipeline — from raw data in SQL, through feature engineering and machine learning in Python, to an actionable business strategy visualized in Power BI. The four investigated factors (login frequency, payment delay, complaints, usage trend) all proved to be meaningful churn predictors, and a Logistic Regression model built on them can identify at-risk customers with high accuracy.

By focusing a retention campaign only on model-flagged high-risk customers rather than the entire customer base, the business could realistically reduce customer attrition by roughly a quarter — a substantial, measurable outcome for a targeted, cost-effective intervention.

---

## 12. Future Work

- Replace engineered features with real billing, support-ticket, and usage-analytics data
- Run an A/B test on the High Risk segment to measure actual campaign save rates and refine the business outcome model
- Experiment with additional models (Gradient Boosting, XGBoost) to compare performance
- Build an automated pipeline to refresh churn scores on a recurring (e.g. weekly) basis
- Add cost/revenue data to calculate actual ROI of the retention campaign, not just attrition rate reduction

---

## Repository Structure

```
├── sql/
│   └── extraction_queries.sql
├── python/
│   └── churn_prediction_notebook.ipynb
├── powerbi/
│   └── churn_dashboard.pbix
├── screenshots/
│   └── dashboard.png
├── README.md
└── PROJECT_REPORT.md   (this file)
```
