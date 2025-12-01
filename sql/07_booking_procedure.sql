CREATE OR REPLACE PROCEDURE sp_book_appointment(
  p_patient_id  IN NUMBER,
  p_doctor_id   IN NUMBER,
  p_slot_start  IN TIMESTAMP,
  p_slot_end    IN TIMESTAMP,
  p_appointment_id OUT NUMBER
) IS
BEGIN
  sp_validate_booking(p_patient_id, p_doctor_id, p_slot_start, p_slot_end);
  sp_validate_doctor_schedule(p_doctor_id, p_slot_start, p_slot_end);
  sp_check_overlap(p_doctor_id, p_slot_start, p_slot_end);

  p_appointment_id := seq_appointment_id.NEXTVAL;

  INSERT INTO appointments VALUES(
    p_appointment_id, p_patient_id, p_doctor_id,
    p_slot_start, p_slot_end, 'BOOKED',
    SYSTIMESTAMP, NULL
  );

  COMMIT;
END;
/
