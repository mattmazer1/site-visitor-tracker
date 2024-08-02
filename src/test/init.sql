create database = personal_site_user_data;

\c personal_site_user_data

create table userdata (
id SERIAL PRIMARY KEY,
ip TEXT,
datetime TEXT)

create table uservisitcount (
id ??
count INT)