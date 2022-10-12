-- notes.sql 

drop schema public cascade;
create schema public;
set schema 'public';

create role server_user_1 login password 'server_user_1';
grant all on all tables in schema "public" to server_user_1;
grant create on database eil_db_1 to server_user_1;
grant select on information_schema.tables to server_user_1;
grant all on all tables in schema "public" to server_user_1;
grant all on all procedures in schema "public" to server_user_1;
grant all on all sequences in schema "public" to server_user_1;
grant all on all functions in schema "public" to server_user_1;