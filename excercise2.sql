DROP TABLE countries CASCADE CONSTRAINTS;
DROP TABLE locations CASCADE CONSTRAINTS;
DROP TABLE departments CASCADE CONSTRAINTS;
DROP TABLE job_history CASCADE CONSTRAINTS;
DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE regions CASCADE CONSTRAINTS;
DROP TABLE jobs CASCADE CONSTRAINTS;

CREATE TABLE KOZYRA.regions AS (SELECT * FROM HR.regions);
CREATE TABLE KOZYRA.countries AS (SELECT * FROM HR.countries);
CREATE TABLE KOZYRA.locations AS (SELECT * FROM HR.locations);
CREATE TABLE KOZYRA.employees AS (SELECT * FROM HR.employees);
CREATE TABLE KOZYRA.departments AS (SELECT * FROM HR.departments);
CREATE TABLE KOZYRA.jobs AS (SELECT * FROM HR.jobs);
CREATE TABLE KOZYRA.job_history AS (SELECT * FROM HR.job_history);

ALTER TABLE regions ADD PRIMARY KEY (REGION_ID);
ALTER TABLE countries ADD PRIMARY KEY (COUNTRY_ID);
ALTER TABLE locations ADD PRIMARY KEY (LOCATION_ID);
ALTER TABLE employees ADD PRIMARY KEY (EMPLOYEE_ID);
ALTER TABLE departments ADD PRIMARY KEY (DEPARTMENT_ID);
ALTER TABLE jobs ADD PRIMARY KEY (JOB_ID);
ALTER TABLE job_history ADD PRIMARY KEY (EMPLOYEE_ID, START_DATE);

CREATE VIEW EXCERCISE_1 AS
    SELECT CONCAT(CONCAT(first_name,' ') , salary) AS wynagrodzenie FROM employees
    WHERE department_id IN (20, 50) AND salary BETWEEN 2000 AND 7000 ORDER BY last_name DESC;
    
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE EXCERCISE_2(column_name VARCHAR2)
    IS
    ROW_VALUE VARCHAR2(3000);
    CUR       SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR 'SELECT HIRE_DATE || '' '' ||  LAST_NAME || '' '' || ' || column_name || ' FROM EMPLOYEES ' ||
                 'WHERE MANAGER_ID IS NOT NULL AND HIRE_DATE BETWEEN DATE ''2005-01-01'' AND DATE ''2005-12-31'' ' ||
                 'ORDER BY ' || column_name;
    LOOP
        FETCH CUR INTO ROW_VALUE;
        EXIT WHEN CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(ROW_VALUE);
    END LOOP;
END;
/

BEGIN
    EXCERCISE_2('EMAIL');
END;
/

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE EXCERCISE_3(partOfName VARCHAR2)
    IS
    TYPE ROW_TYPE IS RECORD
                     (
                         NAME         VARCHAR2(60),
                         SALARY       NUMBER,
                         PHONE_NUMBER VARCHAR2(20)
                     );
    ROW_VALUE ROW_TYPE;
    CUR       SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR 'SELECT FIRST_NAME || '' '' || LAST_NAME AS NAME, SALARY, PHONE_NUMBER FROM EMPLOYEES ' ||
                 'WHERE REGEXP_LIKE(LAST_NAME, ''^..a'') AND FIRST_NAME LIKE ''%' || partOfName || '%''' ||
                 'ORDER BY NAME DESC, SALARY ASC';
    LOOP
        FETCH CUR INTO ROW_VALUE;
        EXIT WHEN CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('NAME = ' || ROW_VALUE.NAME ||', ' ||
                             'SALARY = ' || ROW_VALUE.SALARY || ', ' ||
                             'PHONE_NUMBER = ' || ROW_VALUE.PHONE_NUMBER);
    END LOOP;
END;
/

BEGIN
    EXCERCISE_3('al');
END;
/

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE EXCERCISE_4
    IS
    TYPE ROW_TYPE IS RECORD
                     (
                         NAME         VARCHAR2(60),
                         WORKING_MOTHS       NUMBER,
                         ADDITIONAL_SALARY NUMBER
                     );
    ROW_VALUE ROW_TYPE;
    CUR       SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR 'SELECT E.FIRST_NAME || '' '' || E.LAST_NAME AS NAME, ' ||
                 'ROUND(MONTHS_BETWEEN(CURRENT_DATE, JH.START_DATE)) AS WORKING_MOTHS, ' ||
                 '(CASE ' ||
                 'WHEN ROUND(MONTHS_BETWEEN(CURRENT_DATE, JH.START_DATE)) < 150 THEN 0.1 * E.SALARY ' ||
                 'WHEN ROUND(MONTHS_BETWEEN(CURRENT_DATE, JH.START_DATE)) > 200 THEN 0.2 * E.SALARY ' ||
                 'ELSE 0.3 * E.SALARY ' ||
                 'END) AS ADDITIONAL_SALARY FROM EMPLOYEES E ' ||
                 'JOIN JOB_HISTORY JH on E.EMPLOYEE_ID = JH.EMPLOYEE_ID ' ||
                 'ORDER BY WORKING_MOTHS DESC';
    LOOP
        FETCH CUR INTO ROW_VALUE;
        EXIT WHEN CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('NAME = ' || ROW_VALUE.NAME ||', ' ||
                             'WORKING_MOTHS = ' || ROW_VALUE.WORKING_MOTHS || ', ' ||
                             'ADDITIONAL_SALARY = ' || ROW_VALUE.ADDITIONAL_SALARY);
    END LOOP;
END;
/

BEGIN
    EXCERCISE_4();
END;
/

SELECT D.DEPARTMENT_NAME, SUM(E.SALARY) AS SUMMARY, ROUND(AVG(E.SALARY), 0) AS AVERGAE FROM DEPARTMENTS D
    JOIN EMPLOYEES E ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
    GROUP BY D.DEPARTMENT_NAME
    HAVING AVG(E.SALARY) > 5000;
    
SELECT LAST_NAME, D.DEPARTMENT_ID, DEPARTMENT_NAME, JOB_ID FROM DEPARTMENTS D
    JOIN EMPLOYEES E ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
    JOIN LOCATIONS L ON L.LOCATION_ID = D.LOCATION_ID
    WHERE L.CITY = 'Toronto';
    
SELECT E.FIRST_NAME, LAST_NAME FROM EMPLOYEES E
    JOIN JOBS J ON E.JOB_ID = J.JOB_ID
    WHERE E.FIRST_NAME = 'Jennifer'
       OR E.JOB_ID IN (SELECT JOB_ID FROM EMPLOYEES WHERE FIRST_NAME = 'Jennifer');
       
SELECT * FROM DEPARTMENTS
    WHERE DEPARTMENT_ID NOT IN (SELECT DISTINCT DEPARTMENT_ID FROM EMPLOYEES WHERE DEPARTMENT_ID IS NOT NULL);
    
CREATE TABLE KOZYRA.JOB_GRADES AS (SELECT * FROM HR.job_grades);

SELECT E.FIRST_NAME, E.LAST_NAME, E.JOB_ID, D.DEPARTMENT_NAME, E.SALARY, JG.GRADE FROM EMPLOYEES E
        JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
        JOIN JOB_GRADES JG ON E.EMPLOYEE_ID = JG.EMPLOYEE_ID;
        
SELECT FIRST_NAME, LAST_NAME, SALARY FROM EMPLOYEES
    WHERE SALARY > (SELECT AVG(SALARY) FROM EMPLOYEES)
    ORDER BY SALARY DESC;
    
SELECT E.EMPLOYEE_ID, E.FIRST_NAME, E.LAST_NAME FROM EMPLOYEES E
    JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
    WHERE D.DEPARTMENT_ID IN (SELECT DEPARTMENT_ID FROM EMPLOYEES WHERE FIRST_NAME LIKE '%e%');

