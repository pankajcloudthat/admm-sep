-- Active: 1770636209703@@127.0.0.1@3306@demo
use ecommerce;
select * from users;

delete from users where id = 2;

show tables;


set role TestRole_ReadOnly;

use ecommerce;
select * from users;
