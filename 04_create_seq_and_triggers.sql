
--ellen�rzi, hogy az email mez� tartalmaz-e '@' jelet
CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_USER
BEFORE INSERT ON USERS
FOR EACH ROW
BEGIN
    -- Ellen�rizz�k, hogy az EMAIL mez� tartalmaz-e '@' jelet
    IF :NEW.EMAIL IS NOT NULL AND INSTR(:NEW.EMAIL, '@') = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'HIBA: �rv�nytelen email c�m!');
    END IF;
END;
/



--�j edz�s besz�r�sakor ki�rja az edz�s nev�t �s d�tum�t
CREATE OR REPLACE TRIGGER TRG_AFTER_INSERT_WORKOUT
AFTER INSERT ON WORKOUTS
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('�j edz�s l�trehozva: Izomcsoport ID - ' || :NEW.MUSCLE_GROUP_ID || 
                         ', D�tum: ' || TO_CHAR(:NEW.WORKOUT_DATE, 'YYYY-MM-DD'));
END;
/



--ellen�rzi, hogy a besz�rott gyakorlat neve �res-e
CREATE OR REPLACE TRIGGER TRG_BEFORE_UPDATE_EXERCISE
BEFORE UPDATE ON EXERCISES
FOR EACH ROW
BEGIN
    -- Ellen�rizz�k, hogy az EXERCISE_NAME nem lehet �res
    IF TRIM(:NEW.EXERCISE_NAME) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'HIBA: A gyakorlat neve nem lehet �res!');
    END IF;
END;
/



--nem engedi az edz�s t�rl�s�t ha van hozz� rendelve eredm�ny
CREATE OR REPLACE TRIGGER TRG_BEFORE_DELETE_WORKOUT
BEFORE DELETE ON WORKOUTS
FOR EACH ROW
DECLARE
    V_COUNT NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO V_COUNT
    FROM WORKOUT_EXERCISES WE
    JOIN WORKOUT_RESULTS WR ON WE.WORKOUT_EXERCISE_ID = WR.WORKOUT_EXERCISE_ID
    WHERE WE.WORKOUT_ID = :OLD.WORKOUT_ID;

    IF V_COUNT > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'HIBA: Az edz�s nem t�r�lhet�, mivel kapcsol�d� eredm�nyek vannak!');
    END IF;
END;
/



--workout_result t�bl�ba naplozzuk ha egy eredm�ny friss�lt.
CREATE OR REPLACE TRIGGER TRG_AFTER_UPDATE_RESULT
AFTER UPDATE ON WORKOUT_RESULTS
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Eredm�ny friss�tve: S�ly - ' || :NEW.WEIGHT_USED || 
                         ', Ism�tl�s - ' || :NEW.REPS || 
                         ', Id�pont: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END;
/


--edz�s m�dos�t�s eset�n napl�z�s az audit_log t�bl�ba.
CREATE OR REPLACE TRIGGER TRG_AUDIT_WORKOUT_UPDATE
AFTER UPDATE ON WORKOUTS
FOR EACH ROW
BEGIN
    INSERT INTO AUDIT_LOG (LOG_ID, TABLE_NAME, ACTION_TYPE, USERNAME, ACTION_DATE)
    VALUES (SEQ_RESULT_ID.NEXTVAL, 'WORKOUTS', 'UPDATE', SYS_CONTEXT('USERENV', 'SESSION_USER'), SYSDATE);
END;
/






