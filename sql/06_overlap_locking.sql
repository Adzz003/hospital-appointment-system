CREATE OR REPLACE PROCEDURE sp_check_overlap(
  p_doctor_id  IN NUMBER,
  p_slot_start IN TIMESTAMP,
  p_slot_end   IN TIMESTAMP
) IS
  v_cnt NUMBER;
BEGIN
  BEGIN
    SELECT 1 INTO v_cnt
    FROM doctors
    WHERE doctor_id = p_doctor_id
    FOR UPDATE NOWAIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20031,'Could not obtain lock on doctor.');
  END;

  SELECT COUNT(*) INTO v_cnt
  FROM appointments
  WHERE doctor_id = p_doctor_id
    AND status = 'BOOKED'
    AND p_slot_start < slot_end
    AND p_slot_end   > slot_start;

  IF v_cnt > 0 THEN
    RAISE_APPLICATION_ERROR(-20030, 'Overlap detected.');
  END IF;

END;
/
