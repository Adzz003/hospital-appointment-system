CREATE OR REPLACE PROCEDURE sp_validate_doctor_schedule(
  p_doctor_id  IN NUMBER,
  p_slot_start IN TIMESTAMP,
  p_slot_end   IN TIMESTAMP
) IS
  v_day VARCHAR2(10);
  v_cnt NUMBER;
  v_start_tm VARCHAR2(5);
  v_end_tm   VARCHAR2(5);
BEGIN
  v_day := UPPER(TO_CHAR(p_slot_start, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH'));
  v_start_tm := TO_CHAR(p_slot_start, 'HH24:MI');
  v_end_tm   := TO_CHAR(p_slot_end,   'HH24:MI');

  SELECT COUNT(*) INTO v_cnt
  FROM doctor_schedule
  WHERE doctor_id = p_doctor_id
    AND UPPER(day_of_week) = v_day
    AND v_start_tm >= slot_start
    AND v_end_tm   <= slot_end;

  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20010, 'Doctor not available at requested time.');
  END IF;

END;
/
