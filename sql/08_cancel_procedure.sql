CREATE OR REPLACE PROCEDURE sp_cancel_appointment(
  p_appointment_id IN NUMBER
) IS
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt
  FROM appointments
  WHERE appointment_id = p_appointment_id;

  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20060, 'Appointment does not exist.');
  END IF;

  UPDATE appointments
  SET status = 'CANCELLED'
  WHERE appointment_id = p_appointment_id;

  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Appointment cancelled successfully.');
END;
/
