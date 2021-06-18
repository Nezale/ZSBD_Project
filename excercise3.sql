DECLARE
    NUMER_MAX KOZYRA.DEPARTMENTS.DEPARTMENT_ID%TYPE;
BEGIN
    SELECT MAX(DEPARTMENT_ID)
    INTO NUMER_MAX
    FROM DEPARTMENTS;

    INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME) VALUES (NUMER_MAX + 10, 'NEW DEPARTMENT');
END;
/

DECLARE
    NUMER_MAX KOZYRA.DEPARTMENTS.DEPARTMENT_ID%TYPE;
BEGIN
    SELECT MAX(DEPARTMENT_ID)
    INTO NUMER_MAX
    FROM DEPARTMENTS;

    INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME) VALUES (NUMER_MAX + 10, 'NEW DEPARTMENT');
    UPDATE DEPARTMENTS SET LOCATION_ID = 3000 WHERE DEPARTMENT_ID = NUMER_MAX + 10;
END;
/

CREATE TABLE NOWA
(
    VAL VARCHAR(30)
);
BEGIN
    FOR X IN 1..10
        LOOP
            IF X != 4 AND X != 6 THEN
                INSERT INTO NOWA (VAL) VALUES (X);
            END IF;
        END LOOP;
END;
/

DECLARE
    RESULT COUNTRIES%ROWTYPE;
BEGIN
    SELECT *
    INTO RESULT
    FROM COUNTRIES
    WHERE COUNTRY_ID = 'CA';

    DBMS_OUTPUT.PUT_LINE('NAZWA = ' || RESULT.COUNTRY_NAME || ' REGION_ID = ' || RESULT.REGION_ID);
END;
/

DECLARE
    TYPE DEPARTMENTS_NAMES IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2 (5);
    DEP_NAMES DEPARTMENTS_NAMES;
    DEP_NAME  DEPARTMENTS.DEPARTMENT_NAME%TYPE;
BEGIN
    FOR X IN 1..10
        LOOP
            SELECT DEPARTMENT_NAME INTO DEP_NAME FROM DEPARTMENTS WHERE DEPARTMENT_ID = X * 10;
            DEP_NAMES(X) := DEP_NAME;
        END LOOP;

    FOR X IN 1..10
        LOOP
            DBMS_OUTPUT.PUT_LINE(X * 10 || ' department name is ' || TO_CHAR(DEP_NAMES(X)));
        END LOOP;
END;
/

DECLARE
    TYPE DEPARTMENTS_NAMES IS TABLE OF DEPARTMENTS%ROWTYPE INDEX BY VARCHAR2 (5);
    DEP_NAMES DEPARTMENTS_NAMES;
    DEP_NAME  DEPARTMENTS%ROWTYPE;
BEGIN
    FOR X IN 1..10
        LOOP
            SELECT * INTO DEP_NAME FROM DEPARTMENTS WHERE DEPARTMENT_ID = X * 10;
            DEP_NAMES(X) := DEP_NAME;
        END LOOP;

    FOR X IN 1..10
        LOOP
            DBMS_OUTPUT.PUT_LINE(X * 10 || ' department ' ||
                                 'name is ' || TO_CHAR(DEP_NAMES(X).DEPARTMENT_NAME) || ' ' ||
                                 'with manager_id = ' || TO_CHAR(DEP_NAMES(X).MANAGER_ID) || ' ' ||
                                 'with location_id = ' || TO_CHAR(DEP_NAMES(X).LOCATION_ID));
        END LOOP;
END;
/

DECLARE
    TYPE ROW_TYPE IS RECORD
                     (
                         SALARY    NUMBER,
                         LAST_NAME VARCHAR2(25)
                     );
    ROW_VALUE ROW_TYPE;
    CUR       SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR 'SELECT SALARY, LAST_NAME FROM EMPLOYEES WHERE DEPARTMENT_ID = 50';

    LOOP
        FETCH CUR INTO ROW_VALUE;
        EXIT WHEN CUR%NOTFOUND;

        IF ROW_VALUE.SALARY > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(ROW_VALUE.LAST_NAME || ' - nie dawać podwyżki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(ROW_VALUE.LAST_NAME || ' - dać podwyżke');
        END IF;
    END LOOP;
END;
/

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE EXCERCISE_8(part_of_name VARCHAR2, min_salary NUMBER, max_salary NUMBER)
    IS
    TYPE ROW_TYPE IS RECORD
                     (
                         SALARY     NUMBER,
                         FIRST_NAME VARCHAR2(25),
                         LAST_NAME  VARCHAR2(25)
                     );
    ROW_VALUE ROW_TYPE;
    CUR       SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR 'SELECT SALARY, FIRST_NAME, LAST_NAME FROM EMPLOYEES ' ||
                 'WHERE SALARY > ' || min_salary || ' AND SALARY < ' || max_salary ||
                 'AND (FIRST_NAME LIKE ''%' || LOWER(part_of_name) || '%'' OR FIRST_NAME LIKE ''%' ||
                 UPPER(part_of_name) || '%'')';

    LOOP
        FETCH CUR INTO ROW_VALUE;
        EXIT WHEN CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('SALARY = ' || ROW_VALUE.SALARY || ', ' ||
                             'FIRST_NAME = ' || ROW_VALUE.FIRST_NAME || ', ' ||
                             'LAST_NAME = ' || ROW_VALUE.LAST_NAME);
    END LOOP;
END;
/

BEGIN
    EXCERCISE_8('a', 1000, 5000);
    EXCERCISE_8('u', 5000, 20000);
END;
/

CREATE OR REPLACE PROCEDURE EXCERCISE_9_a(v_job_id VARCHAR2, v_job_title VARCHAR2)
IS
BEGIN
    INSERT INTO JOBS (JOB_ID, JOB_TITLE)
    VALUES (v_job_id, v_job_title);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wrong input');
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
END;
/

BEGIN
    EXCERCISE_9_a('NEW_JOB', 'some title');
END;
/

CREATE OR REPLACE PROCEDURE EXCERCISE_9_b(v_job_id VARCHAR2, v_job_title VARCHAR2)
IS
    NO_JOBS_UPDATED EXCEPTION;
    PRAGMA EXCEPTION_INIT (NO_JOBS_UPDATED, -2001);
BEGIN
    UPDATE JOBS SET JOB_TITLE = v_job_title WHERE JOB_ID = v_job_id;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data were not updated');
    END IF;
EXCEPTION
    WHEN NO_JOBS_UPDATED THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wrong input');
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
END;
/

BEGIN
    EXCERCISE_9_b('AD_PRESxxx', 'President');
END;
/

CREATE OR REPLACE PROCEDURE EXCERCISE_9_c(v_job_id VARCHAR2)
IS
    NO_JOBS_DELETED EXCEPTION;
    PRAGMA EXCEPTION_INIT (NO_JOBS_DELETED, -2001);
BEGIN
    DELETE FROM JOBS WHERE JOB_ID = v_job_id;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No data has been removed');
    END IF;
EXCEPTION
    WHEN NO_JOBS_DELETED THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wrong input');
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
END;
/

BEGIN
    EXCERCISE_9_c('AD_PRESxxx');
END;
/

CREATE OR REPLACE PROCEDURE EXCERCISE_9_d(v_emp_id IN NUMBER, out_salary OUT NUMBER, out_last_name OUT VARCHAR2)
    IS
    TYPE ROW_TYPE IS RECORD
                     (
                         SALARY    NUMBER,
                         LAST_NAME VARCHAR2(25)
                     );
    ROW_RESULT ROW_TYPE;
    CUR        SYS_REFCURSOR;

BEGIN
    OPEN CUR FOR 'SELECT SALARY, LAST_NAME FROM EMPLOYEES WHERE EMPLOYEE_ID = ' || v_emp_id;
    FETCH CUR INTO ROW_RESULT;
    out_salary := ROW_RESULT.SALARY;
    out_last_name := ROW_RESULT.LAST_NAME;
END;
/

DECLARE
    v_out_salary    NUMBER;
    v_out_last_name VARCHAR2(30);
BEGIN
    EXCERCISE_9_d(100, v_out_salary, v_out_last_name);
    DBMS_OUTPUT.PUT_LINE('SALARY = ' || v_out_salary || ', LAST_NAME = ' || v_out_last_name);
END;
/

CREATE OR REPLACE PROCEDURE EXCERCISE_9_e(v_first_name VARCHAR2 DEFAULT 'Jerry',
                                     v_last_name VARCHAR2 DEFAULT 'TheStorm',
                                     v_e_mail VARCHAR2 DEFAULT 'jerry.storm123@gmail.com',
                                     v_phone_number VARCHAR2 DEFAULT '+48 356 135 675',
                                     v_salary NUMBER DEFAULT 15000)
    IS
    SALARY_TOO_HIGH EXCEPTION;
    PRAGMA EXCEPTION_INIT (SALARY_TOO_HIGH, -2001);
    LAST_ID NUMBER;
BEGIN
    IF v_salary > 20000 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Salary too high');
    END IF;

    SELECT MAX(EMPLOYEE_ID) INTO LAST_ID FROM EMPLOYEES;
    INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, SALARY, HIRE_DATE, JOB_ID)
    VALUES (LAST_ID + 1, v_first_name, v_last_name, v_e_mail, v_phone_number, v_salary, CURRENT_DATE, 'AD_PRES');

EXCEPTION
    WHEN SALARY_TOO_HIGH THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wrong input');
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
END;
/

BEGIN
    EXCERCISE_9_e(v_last_name => 'TheStorm');
END;
