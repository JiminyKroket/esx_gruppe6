INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_security', 'Gruppe6', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_security', 'Gruppe6', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_security', 'Gruppe6', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('security','Gruppe6')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('security',0,'recruit','Recruit Guard',35,'{}','{}'),
	('security',1,'guard','Security Guard',50,'{}','{}'),
	('security',2,'nightwatch','NightWatch Guard',75,'{}','{}'),
	('security',3,'manager','Guard Manager',10,'{}','{}'),
	('security',4,'boss','CEO',120,'{}','{}')
;