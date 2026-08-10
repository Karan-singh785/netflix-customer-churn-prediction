Netflix Customer Churn Prediction & Retention Strategy
What This Project Is

A end-to-end data analytics project that answers one business question: why are customers leaving, and what can be done about it?

Using a 5,000-customer Netflix-style subscription dataset, this project identifies the strongest behavioral drivers of churn, builds a machine learning model to predict which customers are at risk, and translates that into a concrete retention strategy with a measurable business impact.

Tech stack: SQL (MySQL) → Python (pandas, scikit-learn) → Power BI

Tasks Performed
1. Data Extraction & Analysis (SQL)
Designed and created a MySQL database (churn_analysis) and imported the raw customer dataset
Wrote 7 extraction queries to analyze churn rate across:
Login frequency
Payment delay
Number of support complaints
Usage trend over time
Region and subscription plan
A combined high-risk customer segment
2. Feature Engineering & Modeling (Python)
Connected Python (Jupyter Notebook) directly to the MySQL database and imported the data with pandas.read_sql
Prepared features for modeling: separated numeric vs categorical columns, scaled numeric features, and one-hot-encoded categorical ones using scikit-learn
Split data into training (75%) and testing (25%) sets
Trained and compared two classification models:
Logistic Regression — 98.88% accuracy, 0.999 ROC-AUC
Random Forest — 98.72% accuracy, 0.999 ROC-AUC
Selected Logistic Regression as the production model (best accuracy + interpretable)
Generated a churn probability score (0-1) for every customer
Segmented all customers into Low / Medium / High Risk based on their score
Pushed the results back into MySQL (churn_predictions table) to feed the dashboard

4. Data Visualization (Power BI)
Connected Power BI to the MySQL database (via CSV export)
Built an interactive dashboard including:
Churn rate by login frequency
Churn rate by payment delay band
Churn rate by number of complaints
Churn rate by usage trend
Churn rate by risk segment
Overall churn rate (KPI card)
Risk segment breakdown (donut chart)
Problems This Project Solves
Reactive vs. proactive retention — instead of finding out a customer churned after they've already cancelled, the model flags at-risk customers in advance, while there's still time to intervene.
Wasted retention spend — rather than running expensive retention campaigns on the entire customer base, the risk segmentation lets a business target only the ~50% of customers who are actually high-risk, making campaigns cost-effective.
Unclear churn drivers — the SQL analysis and correlation findings give the business clear, specific levers to pull (fix billing delays, respond faster to complaints, re-engage customers with declining usage) instead of guessing.
Key Findings
Customers with longer payment delays churn dramatically more than those who pay on time
Churn rate climbs steadily with the number of support complaints in the last 6 months
A declining usage trend (dropping watch time over the past 45 days) is one of the strongest early warning signs of churn
Rare/inactive login behavior is strongly associated with churn, as expected
Final Conclusion

The baseline churn rate in this dataset is 50.3%. By training a Logistic Regression model on behavioral signals (login frequency, payment delay, complaints, usage trend), the project can identify high-risk customers with 98.88% accuracy.

Simulating a targeted retention campaign — reaching out only to the ~2,496 customers flagged High Risk, with a realistic 25% campaign success rate — projects:

Metric	Value
Customers saved	619
New churn rate	37.92%
Reduction in attrition	~24.6%

In short: by predicting churn instead of reacting to it, and focusing retention efforts only on the customers who actually need it, this model-driven strategy can reduce customer attrition by roughly a quarter — without wasting resources on customers who were never going to leave.

Project Files
sql/ — database schema and extraction queries
python/ — feature engineering, model training, churn scoring notebook
powerbi/ — interactive dashboard (.pbix file)
Netflix_Churn_Prediction_Report.docx — full written report with all charts
Tools Used

Python (pandas, scikit-learn, matplotlib, seaborn) · MySQL · Power BI · Jupyter Notebook
