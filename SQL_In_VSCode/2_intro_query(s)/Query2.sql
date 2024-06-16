SELECT
    job_title_short as title,
    job_location as location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS DATE,
    EXTRACT(MONTH FROM job_posted_date) as Month,
    EXTRACT(YEAR FROM job_posted_date) as Year
FROM
    job_postings_fact
LIMIT 5


SELECT
    COUNT(job_id) as job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) as Month
FROM
    job_postings_fact
WHERE
    job_title_short LIKE '%Data Analyst%'
GROUP BY
    month
ORDER BY
    job_posted_count desc

CREATE TABLE Janruary2023Jobs AS
SELECT *
FROM job_postings_fact
WHERE
(EXTRACT(month from job_posted_date) = 1 and
EXTRACT(year from job_posted_date) = 2023)
ORDER BY job_posted_date;


CREATE TABLE Janruary2023Jobs AS
SELECT *
FROM job_postings_fact
WHERE
(EXTRACT(month from job_posted_date) = 1 and
EXTRACT(year from job_posted_date) = 2023)
ORDER BY job_posted_date;


CREATE TABLE February2023Jobs AS
SELECT *
FROM job_postings_fact
WHERE
(EXTRACT(month from job_posted_date) = 2 and
EXTRACT(year from job_posted_date) = 2023)
ORDER BY job_posted_date;


CREATE TABLE March2023Jobs AS
SELECT *
FROM job_postings_fact
WHERE
(EXTRACT(month from job_posted_date) = 3 and
EXTRACT(year from job_posted_date) = 2023)
ORDER BY job_posted_date;




/* 
Label new column as follows based on job_location:
- 'Anywhere' jobs as 'Remote'
- 'New York, NY' jobs as  'Local'
- Otherwise 'Onsite'
*/

SELECT 
	COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM 
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category
ORDER BY    
    number_of_jobs DESC;




WITH remote_job_skills AS (
SELECT
    skill_id,
    count(*) as skill_count
FROM skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact as job_postings
ON job_postings.job_id = skills_to_job.job_id
WHERE job_postings.job_work_from_home = True AND job_title_short LIKE '%Data Analyst%'
GROUP BY skill_id)

SELECT skills.skill_id, skills as skill_name, skill_count
FROM remote_job_skills
INNER JOIN skills_dim as skills ON
remote_job_skills.skill_id = skills.skill_id
ORDER BY skill_count DESC
LIMIT 5


SELECT 
	job_title_short,
	company_id,
	job_location
FROM
	janruary2023jobs

