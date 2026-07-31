
-- Analyze skill-specific salary premiums for Data Analyst roles in the US.

-- Step 1: Apply filters to ensure clean baseline data.
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

-- Step 2: Calculate the average salary for the job position specified above.
avg_salary AS (
    SELECT
        ROUND(AVG(salary_year_avg), 0) AS salary_job_avg
    FROM filtered_fact
),

-- Step 3: Aggregate salary per skill.
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

-- Step 4: Calculate relative skill premium and rank results.
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