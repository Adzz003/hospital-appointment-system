CREATE OR REPLACE TRIGGER trg_prevent_double_booking
FOR INSERT OR UPDATE ON appointments
COMPOUND TRIGGER

  ------------------------------------------------------------------
  -- Local collection: holds all rows inserted/updated in this stmt
  ------------------------------------------------------------------
  TYPE t_row IS RECORD (
    appointment_id appointments.appointment_id%TYPE,
    doctor_id      appointments.doctor_id%TYPE,
    slot_start     appointments.slot_start%TYPE,
    slot_end       appointments.slot_end%TYPE,
    status         appointments.status%TYPE
  );

  TYPE t_tab IS TABLE OF t_row INDEX BY PLS_INTEGER;
  g_rows t_tab;
  g_idx  PLS_INTEGER := 0;

  ------------------------------------------------------------------
  -- BEFORE EACH ROW: collect new/updated appointment rows
  ------------------------------------------------------------------
BEFORE EACH ROW IS
BEGIN
  IF INSERTING OR (UPDATING AND :NEW.status = 'BOOKED') THEN
    g_idx := g_idx + 1;

    g_rows(g_idx).appointment_id := :NEW.appointment_id;
    g_rows(g_idx).doctor_id      := :NEW.doctor_id;
    g_rows(g_idx).slot_start     := :NEW.slot_start;
    g_rows(g_idx).slot_end       := :NEW.slot_end;
    g_rows(g_idx).status         := :NEW.status;
  END IF;
END BEFORE EACH ROW;

  ------------------------------------------------------------------
  -- AFTER STATEMENT: perform validations safely (no mutating error)
  ------------------------------------------------------------------
AFTER STATEMENT IS
  v_day VARCHAR2(10);
  v_cnt NUMBER;
BEGIN
  FOR i IN 1 .. g_idx LOOP

    --------------------------------------------------------------
    -- 1) Validate doctor schedule
    --------------------------------------------------------------
    v_day := UPPER(TO_CHAR(g_rows(i).slot_start,
                           'DY',
                           'NLS_DATE_LANGUAGE=ENGLISH'));

    SELECT COUNT(*) INTO v_cnt
    FROM doctor_schedule ds
    WHERE ds.doctor_id = g_rows(i).doctor_id
      AND UPPER(ds.day_of_week) = v_day
      AND TO_CHAR(g_rows(i).slot_start,'HH24:MI') >= ds.slot_start
      AND TO_CHAR(g_rows(i).slot_end,'HH24:MI')   <= ds.slot_end;

    IF v_cnt = 0 THEN
      RAISE_APPLICATION_ERROR(
        -20050,
        'Trigger: Doctor not available on '||v_day||
        ' for doctor_id='||g_rows(i).doctor_id
      );
    END IF;

    --------------------------------------------------------------
    -- 2) Validate overlap with other appointments
    --------------------------------------------------------------
    SELECT COUNT(*) INTO v_cnt
    FROM appointments a
    WHERE a.doctor_id = g_rows(i).doctor_id
      AND a.status = 'BOOKED'
      AND (g_rows(i).appointment_id IS NULL OR a.appointment_id != g_rows(i).appointment_id)
      AND g_rows(i).slot_start < a.slot_end
      AND g_rows(i).slot_end   > a.slot_start;

    IF v_cnt > 0 THEN
      RAISE_APPLICATION_ERROR(
        -20051,
        'Trigger: Overlap detected for doctor_id='||g_rows(i).doctor_id
      );
    END IF;

  END LOOP;

  -- reset
  g_rows.DELETE;
  g_idx := 0;

END AFTER STATEMENT;

END trg_prevent_double_booking;
/
