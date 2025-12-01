--01 — Test: Successful Booking
SET SERVEROUTPUT ON;

DECLARE
  v_id NUMBER;
BEGIN
  sp_book_appointment(
    1,     -- patient_id
    101,   -- doctor_id
    TO_TIMESTAMP('2025-11-24 11:00','YYYY-MM-DD HH24:MI'),
    TO_TIMESTAMP('2025-11-24 11:30','YYYY-MM-DD HH24:MI'),
    v_id
  );
  DBMS_OUTPUT.PUT_LINE('Test 01 - Booking Success: Appointment ID = ' || v_id);
END;
/

--02 — Test: Overlapping Appointment Should Fail
DECLARE
  v_id NUMBER;
BEGIN
  sp_book_appointment(
    1,
    101,
    TO_TIMESTAMP('2025-11-24 11:15','YYYY-MM-DD HH24:MI'),
    TO_TIMESTAMP('2025-11-24 11:45','YYYY-MM-DD HH24:MI'),
    v_id
  );
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Test 02 - Overlap Error (Expected): ' || SQLERRM);
END;
/

--03 — Test: Wrong Day / Doctor Not Available
DECLARE
  v_id NUMBER;
BEGIN
  sp_book_appointment(
    1,
    101,
    TO_TIMESTAMP('2025-11-25 10:00','YYYY-MM-DD HH24:MI'),
    TO_TIMESTAMP('2025-11-25 10:30','YYYY-MM-DD HH24:MI'),
    v_id
  );
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Test 03 - Doctor Not Available (Expected): ' || SQLERRM);
END;
/

--04 — Test: Invalid Patient
DECLARE
  v_id NUMBER;
BEGIN
  sp_book_appointment(
    999,     -- invalid patient
    101,
    TO_TIMESTAMP('2025-11-24 10:00','YYYY-MM-DD HH24:MI'),
    TO_TIMESTAMP('2025-11-24 10:30','YYYY-MM-DD HH24:MI'),
    v_id
  );
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Test 04 - Invalid Patient (Expected): ' || SQLERRM);
END;
/


--05 — Test: Invalid Doctor
DECLARE
  v_id NUMBER;
BEGIN
  sp_book_appointment(
    1,
    999,    -- invalid doctor
    TO_TIMESTAMP('2025-11-24 10:00','YYYY-MM-DD HH24:MI'),
    TO_TIMESTAMP('2025-11-24 10:30','YYYY-MM-DD HH24:MI'),
    v_id
  );
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Test 05 - Invalid Doctor (Expected): ' || SQLERRM);
END;
/


--06 — Test: End Time Before Start Should Fail
DECLARE
  v_id NUMBER;
BEGIN
  sp_book_appointment(
    1,
    101,
    TO_TIMESTAMP('2025-11-24 14:00','YYYY-MM-DD HH24:MI'),
    TO_TIMESTAMP('2025-11-24 13:00','YYYY-MM-DD HH24:MI'),
    v_id
  );
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Test 06 - Invalid Time Range (Expected): ' || SQLERRM);
END;
/


--07 — Test: Back-to-Back Booking (Allowed)
DECLARE
  v_id NUMBER;
BEGIN
  sp_book_appointment(
    2,
    101,
    TO_TIMESTAMP('2025-11-24 11:30','YYYY-MM-DD HH24:MI'),
    TO_TIMESTAMP('2025-11-24 12:00','YYYY-MM-DD HH24:MI'),
    v_id
  );
  DBMS_OUTPUT.PUT_LINE('Test 07 - Back-to-back Booking Success: ' || v_id);
END;
/


--08 — Test: Cancel Appointment
DECLARE
  v_id NUMBER := 5001; -- replace with a REAL appointment ID in your table
BEGIN
  sp_cancel_appointment(v_id);
  DBMS_OUTPUT.PUT_LINE('Test 08 - Cancellation Success for appointment ' || v_id);
END;
/


--09 — Test: Book After Cancellation (Should Now Succeed)
DECLARE
  v_id NUMBER;
BEGIN
  sp_book_appointment(
    1,
    101,
    TO_TIMESTAMP('2025-11-24 10:00','YYYY-MM-DD HH24:MI'),
    TO_TIMESTAMP('2025-11-24 10:30','YYYY-MM-DD HH24:MI'),
    v_id
  );
  DBMS_OUTPUT.PUT_LINE('Test 09 - Booking After Cancel Success: ' || v_id);
END;
/



--10 — Test: Trigger Validation (Direct Insert Outside Procedure)
INSERT INTO appointments(
  appointment_id, patient_id, doctor_id, slot_start, slot_end, status
)
VALUES (
  seq_appointment_id.NEXTVAL,
  1,
  101,
  TO_TIMESTAMP('2025-11-24 12:00','YYYY-MM-DD HH24:MI'),
  TO_TIMESTAMP('2025-11-24 12:30','YYYY-MM-DD HH24:MI'),
  'BOOKED'
);
COMMIT;

DBMS_OUTPUT.PUT_LINE('Test 10A - Direct Insert Allowed');



--11 — Test: Full Appointment Table Output
SELECT appointment_id, patient_id, doctor_id, slot_start, slot_end, status
FROM appointments
ORDER BY appointment_id;

