﻿--Felhasználó tábla
CREATE TABLE USERS (
    USER_ID NUMBER PRIMARY KEY,
    USERNAME VARCHAR2(50) NOT NULL UNIQUE,
    PASSWORD VARCHAR2(100) NOT NULL,
    EMAIL VARCHAR2(100) UNIQUE,
    CREATED_AT DATE DEFAULT SYSDATE
);

CREATE SEQUENCE SEQ_USER_ID START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_USERS
BEFORE INSERT ON USERS
FOR EACH ROW
BEGIN
    IF :NEW.USER_ID IS NULL THEN
        :NEW.USER_ID := SEQ_USER_ID.NEXTVAL;
    END IF;
END;
/

--Izomcsoportok tábla
CREATE TABLE MUSCLE_GROUP (
    MUSCLE_GROUP_ID NUMBER PRIMARY KEY,
    MUSCLE_GROUP_NAME VARCHAR2(100) NOT NULL UNIQUE,
    DESCRIPTION VARCHAR2(255)
);

CREATE SEQUENCE SEQ_MUSCLE_GROUP_ID START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_MUSCLE_GROUP
BEFORE INSERT ON MUSCLE_GROUP
FOR EACH ROW
BEGIN
    IF :NEW.MUSCLE_GROUP_ID IS NULL THEN
        :NEW.MUSCLE_GROUP_ID := SEQ_MUSCLE_GROUP_ID.NEXTVAL;
    END IF;
END;
/





--Edzések tábla
CREATE TABLE WORKOUTS (
    WORKOUT_ID NUMBER PRIMARY KEY,
    USER_ID NUMBER REFERENCES USERS(USER_ID),
    MUSCLE_GROUP_ID NUMBER REFERENCES MUSCLE_GROUP(MUSCLE_GROUP_ID),
    WORKOUT_DATE DATE NOT NULL,
    CREATED_AT DATE DEFAULT SYSDATE
);

CREATE SEQUENCE SEQ_WORKOUT_ID START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_WORKOUTS
BEFORE INSERT ON WORKOUTS
FOR EACH ROW
BEGIN
    IF :NEW.WORKOUT_ID IS NULL THEN
        :NEW.WORKOUT_ID := SEQ_WORKOUT_ID.NEXTVAL;
    END IF;
END;
/



--Gyakorlatok tábla
CREATE TABLE EXERCISES (
    EXERCISE_ID NUMBER PRIMARY KEY,
    EXERCISE_NAME VARCHAR2(100) NOT NULL,
    DESCRIPTION VARCHAR2(255)
);

CREATE SEQUENCE SEQ_EXERCISE_ID START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_EXERCISES
BEFORE INSERT ON EXERCISES
FOR EACH ROW
BEGIN
    IF :NEW.EXERCISE_ID IS NULL THEN
        :NEW.EXERCISE_ID := SEQ_EXERCISE_ID.NEXTVAL;
    END IF;
END;
/



--Edzés-Gyakorlat kapcsoló tábla
CREATE TABLE WORKOUT_EXERCISES (
    WORKOUT_EXERCISE_ID NUMBER PRIMARY KEY,
    WORKOUT_ID NUMBER REFERENCES WORKOUTS(WORKOUT_ID),
    EXERCISE_ID NUMBER REFERENCES EXERCISES(EXERCISE_ID),
    CREATED_AT DATE DEFAULT SYSDATE
);

CREATE SEQUENCE SEQ_WORKOUT_EXERCISE_ID START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_WO_EXERCISES
BEFORE INSERT ON WORKOUT_EXERCISES
FOR EACH ROW
BEGIN
    IF :NEW.WORKOUT_EXERCISE_ID IS NULL THEN
        :NEW.WORKOUT_EXERCISE_ID := SEQ_WORKOUT_EXERCISE_ID.NEXTVAL;
    END IF;
END;
/




--Teljesített gyakorlatok tábla
CREATE TABLE WORKOUT_RESULTS (
    RESULT_ID NUMBER PRIMARY KEY,
    WORKOUT_EXERCISE_ID NUMBER REFERENCES WORKOUT_EXERCISES(WORKOUT_EXERCISE_ID),
    WEIGHT_USED NUMBER(5,2), -- Használt súly kg-ban
    REPS NUMBER, -- Ismétlések száma
    PERFORMED_AT DATE DEFAULT SYSDATE
);

CREATE SEQUENCE SEQ_RESULT_ID START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_WO_RESULTS
BEFORE INSERT ON WORKOUT_RESULTS
FOR EACH ROW
BEGIN
    IF :NEW.RESULT_ID IS NULL THEN
        :NEW.RESULT_ID := SEQ_RESULT_ID.NEXTVAL;
    END IF;
END;
/



--Naplózó tábla létrehozása, minden edzés módosítás után az elvégzett műveletek ide kerülnek
CREATE TABLE AUDIT_LOG (
    LOG_ID NUMBER PRIMARY KEY,
    TABLE_NAME VARCHAR2(50),
    ACTION_TYPE VARCHAR2(10),
    USERNAME VARCHAR2(50),
    ACTION_DATE DATE DEFAULT SYSDATE
);

CREATE SEQUENCE SEQ_LOG_ID START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_AUDIT_LOG
BEFORE INSERT ON AUDIT_LOG
FOR EACH ROW
BEGIN
    IF :NEW.LOG_ID IS NULL THEN
        :NEW.LOG_ID := SEQ_LOG_ID.NEXTVAL;
    END IF;
END;
/





/*2. Kapcsolatok és logikai összefüggések
USERS → WORKOUTS: Egy felhasználó több edzést is tervezhet. (1:N kapcsolat)
WORKOUTS → WORKOUT_EXERCISES: Egy edzés több gyakorlatból állhat. (1:N kapcsolat)
EXERCISES → WORKOUT_EXERCISES: Egy gyakorlat több edzéshez is tartozhat. (1:N kapcsolat)
WORKOUT_EXERCISES → WORKOUT_RESULTS: Egy edzés-gyakorlat pároshoz tartozik a teljesítmény adatok rögzítése. (1:N kapcsolat)*/
