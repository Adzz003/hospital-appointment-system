INSERT INTO patients VALUES (1, 'Ravi Kumar', '9876543210', 'ravi@example.com', SYSDATE);
INSERT INTO patients VALUES (2, 'Anita Singh', '9876501234', 'anita@example.com', SYSDATE);

INSERT INTO doctors VALUES (101, 'Dr. Suresh Patel', 'General Physician', '9812345678', 'suresh@hospital.com');
INSERT INTO doctors VALUES (102, 'Dr. Neha Verma', 'Dermatologist', '9823456789', 'neha@hospital.com');

INSERT INTO doctor_schedule VALUES (1001, 101, 'MON', '09:00', '12:00', 30);
INSERT INTO doctor_schedule VALUES (1002, 101, 'WED', '14:00', '17:00', 30);
INSERT INTO doctor_schedule VALUES (1003, 102, 'TUE', '10:00', '13:00', 20);
INSERT INTO doctor_schedule VALUES (1004, 102, 'THU', '15:00', '18:00', 20);

COMMIT;
