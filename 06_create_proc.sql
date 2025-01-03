--1.megsz�molja, hogy a user h�ny edz�st r�gz�tett �s azonbel�l �sszesen h�ny gyakorlatot hajtott v�gre
CREATE OR REPLACE PROCEDURE WORKOUT_AND_EXERCISE_COUNT (
    P_USER_ID IN NUMBER,
    P_TOTAL_WORKOUTS OUT NUMBER,
    P_TOTAL_EXERCISES OUT NUMBER
) IS
BEGIN
    -- Edz�sek sz�ma
    SELECT COUNT(W.WORKOUT_ID)
    INTO P_TOTAL_WORKOUTS
    FROM WORKOUTS W
    WHERE W.USER_ID = P_USER_ID;

    -- Gyakorlatok sz�ma
    SELECT COUNT(WE.WORKOUT_EXERCISE_ID)
    INTO P_TOTAL_EXERCISES
    FROM WORKOUTS W
    JOIN WORKOUT_EXERCISES WE ON W.WORKOUT_ID = WE.WORKOUT_ID
    WHERE W.USER_ID = P_USER_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        P_TOTAL_WORKOUTS := 0;
        P_TOTAL_EXERCISES := 0;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20026, 'HIBA: Nem siker�lt lek�rdezni az adatokat.');
END;
/




--2. adott felhaszn�l� edz�seir�l r�szletes le�r�st k�sz�t.
CREATE OR REPLACE PROCEDURE GENERATE_USER_WORKOUT_REPORT (
    P_USER_ID IN NUMBER
) IS
BEGIN
    -- Jelent�s lek�rdez�se
    FOR WORKOUT_REC IN (
        SELECT 
            W.WORKOUT_ID,
            TO_CHAR(W.WORKOUT_DATE, 'YYYY-MM-DD') AS WORKOUT_DATE,
            M.MUSCLE_GROUP_NAME,
            COUNT(WE.WORKOUT_EXERCISE_ID) AS TOTAL_EXERCISES,
            NVL(SUM(R.REPS), 0) AS TOTAL_REPS,
            NVL(SUM(R.REPS * R.WEIGHT_USED), 0) AS TOTAL_WEIGHT
        FROM WORKOUTS W
        JOIN MUSCLE_GROUP M ON W.MUSCLE_GROUP_ID = M.MUSCLE_GROUP_ID
        LEFT JOIN WORKOUT_EXERCISES WE ON W.WORKOUT_ID = WE.WORKOUT_ID
        LEFT JOIN WORKOUT_RESULTS R ON WE.WORKOUT_EXERCISE_ID = R.WORKOUT_EXERCISE_ID
        WHERE W.USER_ID = P_USER_ID
        GROUP BY W.WORKOUT_ID, W.WORKOUT_DATE, M.MUSCLE_GROUP_NAME
        ORDER BY W.WORKOUT_DATE
    ) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('-------------------------------');
        DBMS_OUTPUT.PUT_LINE('Edzes ID: ' || WORKOUT_REC.WORKOUT_ID);
        DBMS_OUTPUT.PUT_LINE('Datum: ' || WORKOUT_REC.WORKOUT_DATE);
        DBMS_OUTPUT.PUT_LINE('Izomcsoport: ' || WORKOUT_REC.MUSCLE_GROUP_NAME);
        DBMS_OUTPUT.PUT_LINE('Gyakorlatok szama: ' || WORKOUT_REC.TOTAL_EXERCISES);
        DBMS_OUTPUT.PUT_LINE('Osszes ismetles: ' || WORKOUT_REC.TOTAL_REPS);
        DBMS_OUTPUT.PUT_LINE('Osszes megemelt suly (kg): ' || WORKOUT_REC.TOTAL_WEIGHT);
        DBMS_OUTPUT.PUT_LINE('-------------------------------');
    END LOOP;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nincs edz�s r�gz�tve a felhaszn�l�nak.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20028, 'HIBA: Nem siker�lt lek�rdezni az edz�s jelent�st.');
END;
/





