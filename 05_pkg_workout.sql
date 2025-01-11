CREATE OR REPLACE PACKAGE PKG_WORKOUT AS

    -- Function�k
    FUNCTION GET_TOTAL_REPS_BY_WORKOUT (
        P_WORKOUT_ID IN NUMBER
    ) RETURN NUMBER;

    FUNCTION TOTAL_WEIGHT_BY_USER_WORKOUT (
        P_USER_ID    IN NUMBER,
        P_WORKOUT_ID IN NUMBER
    ) RETURN NUMBER;

    -- Procedure-�k
    PROCEDURE WORKOUT_AND_EXERCISE_COUNT (
        P_USER_ID           IN  NUMBER,
        P_TOTAL_WORKOUTS    OUT NUMBER,
        P_TOTAL_EXERCISES   OUT NUMBER
    );

    PROCEDURE GENERATE_USER_WORKOUT_REPORT (
        P_USER_ID IN NUMBER
    );

END PKG_WORKOUT;
/

CREATE OR REPLACE PACKAGE BODY PKG_WORKOUT AS

    -- 1. GET_TOTAL_REPS_BY_WORKOUT
    FUNCTION GET_TOTAL_REPS_BY_WORKOUT (
        P_WORKOUT_ID IN NUMBER
    ) RETURN NUMBER IS
        V_TOTAL_REPS NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(R.REPS), 0)
        INTO V_TOTAL_REPS
        FROM WORKOUT_RESULTS R
        JOIN WORKOUT_EXERCISES WE ON R.WORKOUT_EXERCISE_ID = WE.WORKOUT_EXERCISE_ID
        WHERE WE.WORKOUT_ID = P_WORKOUT_ID;

        RETURN V_TOTAL_REPS;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(
                -20025,
                'HIBA: Nem siker�lt lek�rdezni az �sszes ism�tl�st.'
            );
    END GET_TOTAL_REPS_BY_WORKOUT;


    -- 2. TOTAL_WEIGHT_BY_USER_WORKOUT
    FUNCTION TOTAL_WEIGHT_BY_USER_WORKOUT (
        P_USER_ID    IN NUMBER,
        P_WORKOUT_ID IN NUMBER
    ) RETURN NUMBER IS
        V_TOTAL_WEIGHT NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(R.REPS * R.WEIGHT_USED), 0)
        INTO V_TOTAL_WEIGHT
        FROM WORKOUT_RESULTS R
        JOIN WORKOUT_EXERCISES WE ON R.WORKOUT_EXERCISE_ID = WE.WORKOUT_EXERCISE_ID
        JOIN WORKOUTS W ON WE.WORKOUT_ID = W.WORKOUT_ID
        WHERE W.USER_ID = P_USER_ID
          AND W.WORKOUT_ID = P_WORKOUT_ID;

        RETURN V_TOTAL_WEIGHT;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(
                -20027,
                'HIBA: Nem siker�lt lek�rdezni az �sszes megemelt s�lyt.'
            );
    END TOTAL_WEIGHT_BY_USER_WORKOUT;


    -- 3. WORKOUT_AND_EXERCISE_COUNT
    PROCEDURE WORKOUT_AND_EXERCISE_COUNT (
        P_USER_ID           IN  NUMBER,
        P_TOTAL_WORKOUTS    OUT NUMBER,
        P_TOTAL_EXERCISES   OUT NUMBER
    ) IS
    BEGIN
        -- Edz�sek sz�ma
        SELECT COUNT(*)
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
            P_TOTAL_WORKOUTS  := 0;
            P_TOTAL_EXERCISES := 0;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(
                -20026,
                'HIBA: Nem siker�lt lek�rdezni az adatokat (WORKOUT_AND_EXERCISE_COUNT).'
            );
    END WORKOUT_AND_EXERCISE_COUNT;


    -- 4. GENERATE_USER_WORKOUT_REPORT
    CREATE OR REPLACE PROCEDURE GENERATE_USER_WORKOUT_REPORT (
    P_USER_ID IN NUMBER
    ) IS
    BEGIN
    
    -- kor�bbi riportok t�rl�se �gy mindig friss lesz az adott ID lek�rdez�se
    DELETE FROM MY_WORKOUT_REPORT
     WHERE USER_ID = P_USER_ID;

    -- lek�rdez�s kurzorral
    FOR WORKOUT_REC IN (
        SELECT 
            W.WORKOUT_ID,
            TO_CHAR(W.WORKOUT_DATE, 'YYYY-MM-DD') AS WORKOUT_DATE,
            M.MUSCLE_GROUP_NAME,
            COUNT(WE.WORKOUT_EXERCISE_ID) AS TOTAL_EXERCISES,
            NVL(SUM(R.REPS), 0) AS TOTAL_REPS,
            NVL(SUM(R.REPS * R.WEIGHT_USED), 0) AS TOTAL_WEIGHT
        FROM WORKOUTS W
        JOIN MUSCLE_GROUP M 
          ON W.MUSCLE_GROUP_ID = M.MUSCLE_GROUP_ID
        LEFT JOIN WORKOUT_EXERCISES WE 
          ON W.WORKOUT_ID = WE.WORKOUT_ID
        LEFT JOIN WORKOUT_RESULTS R 
          ON WE.WORKOUT_EXERCISE_ID = R.WORKOUT_EXERCISE_ID
        WHERE W.USER_ID = P_USER_ID
        GROUP BY W.WORKOUT_ID, W.WORKOUT_DATE, M.MUSCLE_GROUP_NAME
        ORDER BY W.WORKOUT_DATE
    )
    LOOP
        -- sorok besz�r�sa a t�bl�ba
        INSERT INTO MY_WORKOUT_REPORT (
            REPORT_ID,    
            USER_ID,
            WORKOUT_ID,
            WORKOUT_DATE,
            MUSCLE_GROUP_NAME,
            TOTAL_EXERCISES,
            TOTAL_REPS,
            TOTAL_WEIGHT
        )
        VALUES (
            NULL,  -- mivel van trigger r�
            P_USER_ID,
            WORKOUT_REC.WORKOUT_ID,
            WORKOUT_REC.WORKOUT_DATE,
            WORKOUT_REC.MUSCLE_GROUP_NAME,
            WORKOUT_REC.TOTAL_EXERCISES,
            WORKOUT_REC.TOTAL_REPS,
            WORKOUT_REC.TOTAL_WEIGHT
        );
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        
        NULL;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20028,
            'HIBA: Nem siker�lt lek�rdezni az edz�s jelent�st (GENERATE_USER_WORKOUT_REPORT). ' 
            || SQLERRM
        );
END GENERATE_USER_WORKOUT_REPORT;
/


END PKG_WORKOUT;
/

COMMIT;
