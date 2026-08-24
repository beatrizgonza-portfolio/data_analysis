-- 1. Standardize column names
ALTER TABLE student_performance
RENAME COLUMN ï»¿Hours_Studied TO Hours_Studied;

-- 2. Data Audit: Check for null values in critical metrics
SELECT COUNT(*) AS total_rows, -- 6607 rows
       SUM(CASE WHEN Attendance IS NULL THEN 1 ELSE 0 END) AS null_attendance_count, -- 0 null_attendance
       SUM(CASE WHEN Exam_Score IS NULL THEN 1 ELSE 0 END) AS null_exam_score_count -- 0 null_exam_score
FROM student_performance;

-- 3. Data Integrity: Detect potential duplicate records
SELECT Hours_Studied, Attendance, Exam_Score, COUNT(*) AS duplicate_count
FROM student_performance
GROUP BY Hours_Studied, Attendance, Exam_Score
HAVING COUNT(*) > 1;

-- 4. Data Quality: Detect outliers or invalid values outside logical ranges
SELECT * FROM student_performance
WHERE Attendance > 100 OR Attendance < 0; -- 0 records out of bounds

-- 5. Business Insight: Identify students at academic risk by low attendance (< 75%) across school types
SELECT School_Type,
       COUNT(*) AS total_students,
       SUM(CASE WHEN Attendance < 75 THEN 1 ELSE 0 END) AS low_attendance_count,
       ROUND(AVG(Exam_Score), 1) AS avg_exam_score
FROM student_performance
GROUP BY School_Type;
/*
Result Output:
School_Type | total_students | low_attendance_count | avg_exam_score
Public      | 4598           | 1686                 | 67.2
Private     | 2009           | 710                  | 67.3
*/

-- 6. Deep Dive: Impact of Low Attendance (< 75%) on Average Exam Performance
SELECT 
    CASE 
        WHEN Attendance < 75 THEN 'At-Risk (<75% Attendance)'
        ELSE 'Regular (>=75% Attendance)'
    END AS attendance_group,
    COUNT(*) AS student_count,
    ROUND(AVG(Exam_Score), 1) AS avg_exam_score
FROM student_performance
GROUP BY attendance_group;
/*
Result Output:
attendance_group 			|	student_count	|	avg_exam_score
Regular (>=75% Attendance)	|	4211			|	68.6
At-Risk (<75% Attendance)	|	2396			|	64.8
*/