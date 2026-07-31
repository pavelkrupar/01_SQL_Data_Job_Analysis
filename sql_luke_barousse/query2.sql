
-- Skills that are required for the top 10 highest-paying remote Data Analyst jobs.


WITH TopPayingJobs AS (
    SELECT
        job_id,
        job_title_short,
        job_title,
        company_dim.name AS company_name,
        salary_year_avg,
        job_posted_date
    FROM 
        job_postings_fact
    LEFT JOIN 
        company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE 
        job_title_short = 'Data Analyst' AND 
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT NULL
    ORDER BY 
        salary_year_avg DESC
    LIMIT 10
)

SELECT 
    TopPayingJobs.*,
    skills
FROM TopPayingJobs
INNER JOIN skills_job_dim ON TopPayingJobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC;