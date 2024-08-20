CREATE TABLE userdata (
id SERIAL PRIMARY KEY,
ip TEXT,
datetime TEXT
);

CREATE TABLE uservisitcount (
id INTEGER,
count INTEGER
);

INSERT INTO userdata (ip, datetime)
VALUES ('192.158.1.38', '2024-07-31 16:20:27');

INSERT INTO uservisitcount (id, count)
VALUES (1, 1);
