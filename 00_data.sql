-- Felhaszn�l�k
INSERT INTO USERS (USER_ID, USERNAME, PASSWORD, EMAIL) 
VALUES (1, 'user1', 'password123', 'user1@example.com');

-- Edz�s hozz�ad�sa
INSERT INTO WORKOUTS (WORKOUT_ID, USER_ID, WORKOUT_NAME, WORKOUT_DATE) 
VALUES (1, 1, 'Mell-Bicepsz', TO_DATE('2024-12-29', 'YYYY-MM-DD'));

-- Gyakorlatok hozz�ad�sa
INSERT INTO EXERCISES (EXERCISE_ID, EXERCISE_NAME) 
VALUES (1, 'Fekvenyom�s');

-- Edz�shez gyakorlat kapcsol�sa
INSERT INTO WORKOUT_EXERCISES (WORKOUT_EXERCISE_ID, WORKOUT_ID, EXERCISE_ID, ORDER_NUMBER) 
VALUES (1, 1, 1, 1);

-- Teljes�tett gyakorlat r�gz�t�se
INSERT INTO WORKOUT_RESULTS (RESULT_ID, WORKOUT_EXERCISE_ID, WEIGHT_USED, REPS) 
VALUES (1, 1, 80.5, 10);



--TRIGGER TESZTEL�SEK

--hiba�zenet a hib�s email miatt.(TRG_BEFORE_INSERT_USER)--> v�rt eredm�ny: HIBA
INSERT INTO USERS (USER_ID, USERNAME, PASSWORD, EMAIL) 
VALUES (SEQ_USER_ID.NEXTVAL, 'teszt_user', 'jelszo', 'hibasemail');

--edz�s t�rl�s tesztel�s az esetben ha az ID-hoz van m�r rendelve eredm�ny -> v�rt eredm�ny: HIBA
DELETE FROM WORKOUTS WHERE WORKOUT_ID = 1;

