--edz�shez tartoz� �sszes ism�tl�s lek�rdez�se

CREATE OR REPLACE FUNCTION GET_TOTAL_REPS_BY_WORKOUT(W_ID NUMBER) RETURN NUMBER IS
    TOTAL_REPS NUMBER := 0;
BEGIN
    SELECT SUM(R.REPS)
    INTO TOTAL_REPS
    FROM WORKOUT_RESULTS R
    JOIN WORKOUT_EXERCISES WE ON R.WORKOUT_EXERCISE_ID = WE.WORKOUT_EXERCISE_ID
    WHERE WE.WORKOUT_ID = W_ID;
    
    RETURN NVL(TOTAL_REPS, 0);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN -1;
END;


SELECT GET_TOTAL_REPS_BY_WORKOUT(1) FROM DUAL;


