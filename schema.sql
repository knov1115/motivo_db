
CREATE USER MOTIVO_NYILVANTARTO
  IDENTIFIED BY "12345678"
  DEFAULT TABLESPACE users
  QUOTA UNLIMITED ON users;

GRANT CREATE SESSION         TO MOTIVO_NYILVANTARTO;
GRANT CREATE TABLE           TO MOTIVO_NYILVANTARTO;
GRANT CREATE VIEW            TO MOTIVO_NYILVANTARTO;
GRANT CREATE SEQUENCE        TO MOTIVO_NYILVANTARTO;
GRANT CREATE TRIGGER         TO MOTIVO_NYILVANTARTO;
GRANT CREATE PROCEDURE       TO MOTIVO_NYILVANTARTO;
GRANT CREATE TYPE            TO MOTIVO_NYILVANTARTO;


COMMIT;

