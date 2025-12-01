CREATE TABLE patients (
  patient_id   NUMBER PRIMARY KEY,
  name         VARCHAR2(150) NOT NULL,
  contact      VARCHAR2(50),
  email        VARCHAR2(150),
  created_at   DATE DEFAULT SYSDATE
);

CREATE TABLE doctors (
  doctor_id    NUMBER PRIMARY KEY,
  name         VARCHAR2(150) NOT NULL,
  speciality   VARCHAR2(100),
  contact      VARCHAR2(50),
  email        VARCHAR2(150)
);

CREATE TABLE doctor_schedule (
  schedule_id  NUMBER PRIMARY KEY,
  doctor_id    NUMBER NOT NULL,
  day_of_week  VARCHAR2(10),
  slot_start   VARCHAR2(5),
  slot_end     VARCHAR2(5),
  slot_duration_minutes NUMBER,
  CONSTRAINT fk_ds_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE appointments (
  appointment_id NUMBER PRIMARY KEY,
  patient_id     NUMBER NOT NULL,
  doctor_id      NUMBER NOT NULL,
  slot_start     TIMESTAMP NOT NULL,
  slot_end       TIMESTAMP NOT NULL,
  status         VARCHAR2(20) DEFAULT 'BOOKED',
  created_at     TIMESTAMP DEFAULT SYSTIMESTAMP,
  notes          VARCHAR2(2000),
  CONSTRAINT fk_appt_patient
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  CONSTRAINT fk_appt_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE visits (
  visit_id       NUMBER PRIMARY KEY,
  appointment_id NUMBER NOT NULL,
  notes          VARCHAR2(4000),
  created_at     TIMESTAMP DEFAULT SYSTIMESTAMP,
  CONSTRAINT fk_visit_appt
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);
