
--ellenõrzi, hogy az email mezõ tartalmaz-e '@' jelet
CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_USER
BEFORE INSERT ON USERS
FOR EACH ROW
BEGIN
    -- Ellenõrizzük, hogy az EMAIL mezõ tartalmaz-e '@' jelet
    IF :NEW.EMAIL IS NOT NULL AND INSTR(:NEW.EMAIL, '@') = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'HIBA: Érvénytelen email cím!');
    END IF;
END;
/



--új edzés beszúrásakor kiírja az edzés nevét és dátumát
CREATE OR REPLACE TRIGGER TRG_AFTER_INSERT_WORKOUT
AFTER INSERT ON WORKOUTS
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Új edzés létrehozva: Izomcsoport ID - ' || :NEW.MUSCLE_GROUP_ID || 
                         ', Dátum: ' || TO_CHAR(:NEW.WORKOUT_DATE, 'YYYY-MM-DD'));
END;
/



--ellenõrzi, hogy a beszúrott gyakorlat neve üres-e
CREATE OR REPLACE TRIGGER TRG_BEFORE_UPDATE_EXERCISE
BEFORE UPDATE ON EXERCISES
FOR EACH ROW
BEGIN
    -- Ellenõrizzük, hogy az EXERCISE_NAME nem lehet üres
    IF TRIM(:NEW.EXERCISE_NAME) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'HIBA: A gyakorlat neve nem lehet üres!');
    END IF;
END;
/



--nem engedi az edzés törlését ha van hozzá rendelve eredmény
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
        RAISE_APPLICATION_ERROR(-20003, 'HIBA: Az edzés nem törölhetõ, mivel kapcsolódó eredmények vannak!');
    END IF;
END;
/



--workout_result táblába naplozzuk ha egy eredmény frissült.
CREATE OR REPLACE TRIGGER TRG_AFTER_UPDATE_RESULT
AFTER UPDATE ON WORKOUT_RESULTS
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Eredmény frissítve: Súly - ' || :NEW.WEIGHT_USED || 
                         ', Ismétlés - ' || :NEW.REPS || 
                         ', Idõpont: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END;
/


--edzés módosítás esetén naplózás az audit_log táblába.
CREATE OR REPLACE TRIGGER TRG_AUDIT_WORKOUT_UPDATE
AFTER UPDATE ON WORKOUTS
FOR EACH ROW
BEGIN
    INSERT INTO AUDIT_LOG (LOG_ID, TABLE_NAME, ACTION_TYPE, USERNAME, ACTION_DATE)
    VALUES (SEQ_RESULT_ID.NEXTVAL, 'WORKOUTS', 'UPDATE', SYS_CONTEXT('USERENV', 'SESSION_USER'), SYSDATE);
END;
/






