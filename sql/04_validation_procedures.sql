CREATE OR REPLACE PROCEDURE sp_validate_booking(
  p_patient_id IN NUMBER,
  p_doctor_id  IN NUMBER,
  p_slot_start IN TIMESTAMP,
  p_slot_end   IN TIMESTAMP
) IS
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM patients WHERE patient_id = p_patient_id;
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Patient does not exist');
  END IF;

  SELECT COUNT(*) INTO v_cnt FROM doctors WHERE doctor_id = p_doctor_id;
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Doctor does not exist');
  END IF;

  IF p_slot_end <= p_slot_start THEN
    RAISE_APPLICATION_ERROR(-20003, 'Slot end time must be after start time');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Stage 1 Validation Passed');
END;
/
