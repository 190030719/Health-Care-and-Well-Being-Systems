/* Functions */
CREATE FUNCTION `get_age`(
  `date_of_birth` DATE,
  `current_time` DATETIME
) RETURNS INT(11) UNSIGNED COMMENT 'Age Calculation' DETERMINISTIC NO SQL SQL SECURITY DEFINER RETURN(
  (
    YEAR(CURRENT_TIME) - YEAR(date_of_birth)
  ) -(
    (
      DATE_FORMAT(CURRENT_TIME, '00-%m-%d') < DATE_FORMAT(date_of_birth, '00-%m-%d')
    )
  )
);



/*
To use the get_age function:
SELECT get_age(date_of_birth, NOW()) AS age FROM person WHERE id = 1
To add a insert to a auto increment table:
INSERT INTO disease VALUES(NULL,'desease1','discription1','treatment1');
*/

/* Functions */




CREATE TABLE district(
  district_id int UNSIGNED NOT NULL AUTO_INCREMENT,
  district_name VARCHAR(50) NOT NULL, 
  PRIMARY KEY(district_id),
  UNIQUE (district_name)
);

CREATE TABLE disease(
  disease_id int UNSIGNED NOT NULL AUTO_INCREMENT,
  disease_name VARCHAR(50) NOT NULL,
  description VARCHAR(100) NOT NULL,
  symptoms  VARCHAR(100),
  treatment VARCHAR(100) NOT NULL,
  last_updated DATETIME,
  PRIMARY KEY(disease_id),
  UNIQUE (disease_name)
);


CREATE TABLE users(
  nic VARCHAR(10) NOT NULL,
  NAME VARCHAR(50) NOT NULL,
  pwd VARCHAR(100) NOT NULL,
  dob DATE NOT NULL,
  district_id int UNSIGNED,
  role VARCHAR(20),
  specialization VARCHAR(100),
  last_updated DATETIME,
  PRIMARY KEY(nic),
  FOREIGN KEY(district_id) REFERENCES district(district_id) ON DELETE SET NULL
);





CREATE TABLE med_report(
  report_date DATE NOT NULL,
  patient_nic VARCHAR(10) NOT NULL,
  med_officer_nic VARCHAR(10) NOT NULL,
  disease_id int UNSIGNED NOT NULL,
  comments VARCHAR(500),
  prescriptions VARCHAR(500),
  last_updated DATETIME,
  last_updated_by CHAR(10)
  PRIMARY KEY(
    patient_nic,
    disease_id
  ),
  FOREIGN KEY(patient_nic) REFERENCES users(nic) ON DELETE CASCADE,
  FOREIGN KEY(disease_id) REFERENCES disease(disease_id) ON DELETE CASCADE,
  FOREIGN KEY(med_officer_nic) REFERENCES users(nic) ON DELETE CASCADE
);

CREATE TABLE med_officer_assign(
  med_officer_nic VARCHAR(10) NOT NULL,
  health_officer_nic VARCHAR(10) NOT NULL,
  PRIMARY KEY(
    med_officer_nic
  ),
  FOREIGN KEY(med_officer_nic) REFERENCES users(nic) ON DELETE CASCADE,
  FOREIGN KEY(health_officer_nic) REFERENCES users(nic) ON DELETE CASCADE
);

CREATE TABLE district_disease(
  district_id int UNSIGNED NOT NULL,
  disease_id int UNSIGNED NOT NULL,
  count int DEFAULT 0,
  PRIMARY KEY(
    district_id,
    disease_id
  ),
  FOREIGN KEY(district_id) REFERENCES district(district_id) ON DELETE CASCADE,
  FOREIGN KEY(disease_id) REFERENCES disease(disease_id) ON DELETE CASCADE
);


/* Views */
/*CREATE VIEW patient AS
SELECT nic,NAME,pwd,dob,get_age(dob, NOW()) AS age,district_id,role,last_updated FROM users WHERE role = "patient";*/

CREATE VIEW patient AS
SELECT nic,NAME,pwd,dob,district_id,role,last_updated FROM users WHERE role = "patient";

CREATE VIEW medical_officer AS
SELECT nic,NAME,pwd,dob,district_id,role,specialization,last_updated FROM users WHERE role = "medical_officer";

CREATE VIEW health_officer AS
SELECT nic,NAME,pwd,dob,district_id,role,specialization,last_updated FROM users WHERE role = "health_officer";

/* Views */


/* Triggers */


/* Users triggers */


DELIMITER $$
CREATE TRIGGER before_users_insert 
    BEFORE INSERT ON users
    FOR EACH ROW 
BEGIN
    SET NEW.last_updated = NOW();
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_users_update 
    BEFORE UPDATE ON users
    FOR EACH ROW 
BEGIN
    SET NEW.last_updated = NOW();
END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER before_users_role_insert 
    BEFORE INSERT ON users
    FOR EACH ROW 
BEGIN
    IF (new.role <> "patient" AND new.role <> "medical_officer" AND new.role <> "health_officer")
    THEN SET NEW.role = "standard";
    END IF;
END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER before_users_nic_insert 
    BEFORE INSERT ON users
    FOR EACH ROW 
BEGIN
    IF (length(new.nic) <> 10)
    THEN SET NEW.nic = "invalid";
    END IF;
END$$
DELIMITER ;


/* Users triggers */

/* Diseases Triggers */
DELIMITER $$
CREATE TRIGGER before_disease_insert 
    BEFORE INSERT ON disease
    FOR EACH ROW 
BEGIN
    SET NEW.last_updated = NOW();
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_disease_update 
    BEFORE UPDATE ON disease
    FOR EACH ROW 
BEGIN
    SET NEW.last_updated = NOW();
END$$
DELIMITER ;
/* Diseases Triggers */

/* med_report Triggers */
DELIMITER $$
CREATE TRIGGER before_med_report_insert 
    BEFORE INSERT ON med_report
    FOR EACH ROW 
BEGIN
    SET NEW.last_updated = NOW();
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_med_report_update 
    BEFORE UPDATE ON med_report
    FOR EACH ROW 
BEGIN
    SET NEW.last_updated = NOW();
END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER before_med_report_date_insert 
    BEFORE INSERT ON med_report
    FOR EACH ROW 
BEGIN
    SET NEW.report_date = NOW();
END$$
DELIMITER ;


/* filling the district_disease table */

DELIMITER $$
CREATE TRIGGER after_med_report_patient_insert 
    AFTER INSERT ON med_report
    FOR EACH ROW 
BEGIN
    DECLARE district_id_val int unsigned;
    
    SELECT district_id INTO district_id_val FROM patient WHERE nic = NEW.patient_nic;  

    INSERT INTO district_disease(district_id,disease_id,count) VALUES (district_id_val,NEW.disease_id,1)
    ON DUPLICATE KEY UPDATE count = count+1;
    
END$$
DELIMITER ;


/* med_report Triggers */

/* Triggers*/

/* Indexes */

/* user - name */
CREATE INDEX nameIndex ON users(NAME);

/* disease - disease_name */
CREATE INDEX disease_nameIndex ON disease(disease_name);

/* report - patient_nic */
CREATE INDEX patient_nicIndex ON med_report(patient_nic);

/* district_disease - district_id, disease_id */
CREATE INDEX district_id_disease_idIndex ON district_disease(district_id,disease_id);




/* Indexes */


/* Inserts */

INSERT INTO  district(district_name) VALUES ("Ampara"),("Anuradhapura"),("Badulla"),("Batticaloa"),("Colombo"),
                                            ("Galle"),("Gampaha"),("Hambantota"),("Jaffna"),("Kalutara"),
                                            ("Kandy"),("Kegalle"),("Kilinochchi"),("Kurunegala"),("Mannar"),
                                            ("Matale"),("Matara"),("Monaragala"),("Mullaitivu"),("Nuwara Eliya"),
                                            ("Polonnaruwa"),("Puttalam"),("Ratnapura"),("Trincomalee"),("Vavuniya");



/* Inserts */



