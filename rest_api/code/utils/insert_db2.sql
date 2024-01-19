INSERT INTO users (mail, username, hashed_password, salt, "role")	
	VALUES
	('adri3@mail.com', 'adrian3', '$2b$12$kXFnKdlVre4CvnXgz1WTNezprNX73jcp3HONCJiMxIqn3AV3MmbGW',
			'679f968ddc93eba5a55c2dd70d3d7c015e18596c56371c80368235ba28dd3826', 0), --password: manolo
	('admin@mail.com', 'admin', '$2b$12$1LxCJFESawIveSieSg6jN.OqQTS6qZpgMxEObPTMrdNh.FFeIU7SC',
			'2754c57367d638ebb04ce59b6bc12af855eef671cb005c46ff8cdbbedf09587c', 1); --password: admin


INSERT INTO buildings ("id", gps_latitude, gps_longitude, "name", public, owner)
	VALUES
	(123, 0.57, 0.32, 'U''Bateliere', '0', 'adrian3'),
	(124, 0.88, 0.77, 'Notre Dame', '0', 'admin'),
	(125, 0.93, 0.11, 'AIP', '1', 'admin'),
	(127, 0.15, 0.32, 'Mock Building', '0', 'admin');


INSERT INTO rooms ("id", "floor", "name", building_id)
	VALUES
	(1001, 0, 'French Room', 125),
	(1003, 0, 'Network Room', 125),
	(1007, 3, 'Adrian''s Room', 123),
	(1009, 2, 'Mursalin''s Room', 123),
	(1011, 0, 'Mock Room #1', 127),
	(1013, 0, 'Mock Room #2', 127),
	(1015, 0, 'Mock Room #3', 127);


INSERT INTO measurements ("id", "timestamp", noise_level, temperature,
							humidity, light, air_pressure, room_id, building_id)
	VALUES
	(20005, TIMESTAMP '2017-10-12 21:22:23', 2, 20, 19, 12, 1, 1001, 125),
	(20006, TIMESTAMP '2017-10-12 9:26:18',  9, 24, 22, 64, 1, 1001, 125),
	(20027, TIMESTAMP '2017-10-12 6:13:45',  0, 16, 27, 14, 1, 1007, 123),
	(20028, TIMESTAMP '2017-10-12 20:28:45', 2, 19, 25, 34, 1, 1007, 123),
	(20037, TIMESTAMP '2017-10-12 12:53:05', 8, 26, 28, 40, 1, 1003, 125);