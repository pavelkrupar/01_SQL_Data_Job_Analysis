# 📖 Introduction

This SQL project is based on [**Luke Barousse's**](https://github.com/lukebarousse) Data Jobs dataset, originally used in his [SQL course](https://www.youtube.com/watch?v=7mz73uXD9DA). After re-creating the guided course project, I developed **my own SQL project** that explores salary premiums associated with different technical skills.

My project can be found in the [sql_my_project](./sql_my_project/) folder and is more deeply described in the following sections.

# 📁 Dataset
- job_postings_fact.csv - Fact table containing more than 78,000 data jobs postings.
- company_dim – Dimension table with listed companies.
- skills_dim – Dimension table with listed skills.
- skills_job_dim – Junction table mapping the M:N relationship between jobs and skills.


# 🛠️ SQL Techniques Used
- Common Table Expressions (CTEs)
- Aggregate Functions (COUNT, AVG)
- Filtering (WHERE, HAVING)
- Grouping (GROUP BY)
- Ordering (ORDER BY)
- Joining tables (INNER JOIN, CROSS JOIN)
- Window Function (ROW_NUMBER)
- String Function (CONCAT)

# 🎯 My objectives
Identify the skills associated with the highest-paying job listings, calculate the salary premium relative to the average salary for a Data Analyst in the US, and calculate the total number of job listings for each skill. The goal is to identify the skills that combine high salaries with strong demand for Data Analysts.

>NOTE: The analysis reflects only the average salary of job postings where a specific skill is required. Higher average salary associated with certain skill indicates a correlation, but it does not necessarily mean that the skill itself is the reason for the higher salary.

# ⚙️ Methodology
The project is structured into four CTE–based steps:

### 1. Filtering relevant data
Filters full-time Data Analyst job postings in the US, where yearly salary is not empty, and then elects relevant columns.

```sql
WITH filtered_fact AS (
        SELECT 
        job_id,
        salary_year_avg
    FROM job_postings_fact
    WHERE
        job_title_short = 'Data Analyst' AND
        job_country = 'United States' AND
        job_schedule_type = 'Full-time' AND
        salary_year_avg IS NOT NULL
),
```

### 2. Calculating average salary
Calculates a single value — the overall average salary across all filtered job postings. This is later used to calculate the salary premium.

```sql
avg_salary AS (
    SELECT
        ROUND(AVG(salary_year_avg), 0) AS salary_job_avg
    FROM filtered_fact
),
```

### 3. Aggregating data by skill
Joins the skills table to aggregate job postings by skill, calculates the average salary per skill, and count total number of job postings per skill. The results are filtered only for the skills that appear in at least 40 job postings to exclude low-demand skills.

```sql
aggregated_table AS (
    SELECT 
        skills,
        COUNT(filtered_fact.job_id) AS job_count,
        ROUND(AVG(salary_year_avg), 0) AS salary_skill_avg
    FROM filtered_fact
    INNER JOIN skills_job_dim ON filtered_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    GROUP BY 
        skills
    HAVING
        COUNT(filtered_fact.job_id) > 40
)
```

### 4. Calculating salary premium and skills ranking 
Calculates the salary premium in percentage. The final results are ranked using a window function and sorted in descending order by average skill salary.

```sql
SELECT 
    ROW_NUMBER() OVER (
        ORDER BY (salary_skill_avg) DESC
    ) AS skill_rank,
    *,
    CONCAT(ROUND((salary_skill_avg / salary_job_avg) * 100 - 100, 2), '%') AS skill_premium
FROM aggregated_table
CROSS JOIN avg_salary
ORDER BY 
    salary_skill_avg DESC;
```

# 🔥 Results and Key Findings

- **Pandas**, a Python library, has the highest salary premium. **Python** itself has the highest salary premium among the most demanded skills with more than 1,000 job listings. **Python is king.**
- On the top of the list, there are also some specialized Cloud Platforms, Big Data and collaboration tools. **These modern tools can make the difference.**
- SQL is a core skill with by far the highest number of listings. But it's no surprise that the average salary is close to the overall average.
- General skills such as Spreadsheet, Outlook, Word or Windows, which are not directly related to Data Analytics, are at the bottom of the table. In higher-paying jobs, these are probably taken for granted.

<details>
<summary>👉 Click here to expand full results table</summary>

<br>

| skill_rank | skills | job_count | salary_skill_avg | salary_job_avg | skill_premium |
| ---: | :--- | ---: | ---: | ---: | ---: |
| 1 | pandas | 56 | 115811 | 95052 | 21.84% |
| 2 | confluence | 45 | 115610 | 95052 | 21.63% |
| 3 | spark | 87 | 115342 | 95052 | 21.35% |
| 4 | hadoop | 95 | 114995 | 95052 | 20.98% |
| 5 | express | 72 | 114699 | 95052 | 20.67% |
| 6 | databricks | 61 | 114198 | 95052 | 20.14% |
| 7 | bigquery | 43 | 114105 | 95052 | 20.04% |
| 8 | snowflake | 182 | 113383 | 95052 | 19.29% |
| 9 | git | 42 | 112364 | 95052 | 18.21% |
| 10 | jira | 108 | 109789 | 95052 | 15.50% |
| 11 | redshift | 58 | 109592 | 95052 | 15.30% |
| 12 | aws | 198 | 108516 | 95052 | 14.16% |
| 13 | looker | 165 | 108119 | 95052 | 13.75% |
| 14 | alteryx | 102 | 106649 | 95052 | 12.20% |
| 15 | azure | 201 | 105898 | 95052 | 11.41% |
| 16 | c++ | 51 | 104924 | 95052 | 10.39% |
| 17 | qlik | 72 | 104446 | 95052 | 9.88% |
| 18 | python | 1356 | 104036 | 95052 | 9.45% |
| 19 | visio | 87 | 102947 | 95052 | 8.31% |
| 20 | java | 90 | 102805 | 95052 | 8.16% |
| 21 | nosql | 79 | 102388 | 95052 | 7.72% |
| 22 | ssis | 79 | 101461 | 95052 | 6.74% |
| 23 | oracle | 258 | 101267 | 95052 | 6.54% |
| 24 | matlab | 70 | 101050 | 95052 | 6.31% |
| 25 | dax | 57 | 100653 | 95052 | 5.89% |
| 26 | r | 845 | 100551 | 95052 | 5.79% |
| 27 | c | 71 | 100483 | 95052 | 5.71% |
| 28 | tableau | 1295 | 100135 | 95052 | 5.35% |
| 29 | go | 208 | 99932 | 95052 | 5.13% |
| 30 | mysql | 49 | 99588 | 95052 | 4.77% |
| 31 | flow | 205 | 99264 | 95052 | 4.43% |
| 32 | sql | 2389 | 97937 | 95052 | 3.04% |
| 33 | c# | 53 | 97900 | 95052 | 3.00% |
| 34 | vba | 143 | 96642 | 95052 | 1.67% |
| 35 | sql server | 263 | 96251 | 95052 | 1.26% |
| 36 | t-sql | 57 | 95198 | 95052 | 0.15% |
| 37 | sap | 127 | 94542 | 95052 | -0.54% |
| 38 | sas | 866 | 93973 | 95052 | -1.14% |
| 39 | power bi | 792 | 93226 | 95052 | -1.92% |
| 40 | javascript | 123 | 91913 | 95052 | -3.30% |
| 41 | ssrs | 111 | 91820 | 95052 | -3.40% |
| 42 | cognos | 60 | 90583 | 95052 | -4.70% |
| 43 | powerpoint | 444 | 89529 | 95052 | -5.81% |
| 44 | sharepoint | 146 | 89022 | 95052 | -6.34% |
| 45 | crystal | 73 | 87759 | 95052 | -7.67% |
| 46 | excel | 1733 | 87336 | 95052 | -8.12% |
| 47 | html | 44 | 86166 | 95052 | -9.35% |
| 48 | sheets | 109 | 85352 | 95052 | -10.20% |
| 49 | ms access | 58 | 85147 | 95052 | -10.42% |
| 50 | spss | 178 | 85037 | 95052 | -10.54% |
| 51 | windows | 58 | 84829 | 95052 | -10.76% |
| 52 | word | 442 | 84147 | 95052 | -11.47% |
| 53 | outlook | 147 | 81685 | 95052 | -14.06% |
| 54 | spreadsheet | 85 | 79495 | 95052 | -16.37% |

</details>