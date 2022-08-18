-- schema v1

-- AUTHENTICATION ---------------------------------------------------

create table database_version_control (
  id serial primary key,
  version int not null,
  started timestamp default current_timestamp,
  finished timestamp
);

create table users (
  user_id bigserial primary key,
  active bool not null default true,
  email varchar(255) unique not null,
  is_email_verified bool not null default false,
  password varchar(128) not null,
  created_at timestamp not null default current_timestamp
);

-- make room for manually created service accounts
alter sequence users_user_id_seq restart with 100; 

create table avatars(
  user_id bigint not null references users(user_id),
  avatar varchar(64) unique not null,
  url varchar(128),
  created_at timestamp not null default current_timestamp,
  primary key (user_id, avatar)
);

create table avatars_history(
  avatar_history_id bigserial primary key,
  user_id bigint not null references users(user_id),
  avatar varchar(64) not null,
  url varchar(128),
  created_at timestamp not null,
  changed_at timestamp not null default current_timestamp
);

create type token_type as enum (
  'Confirm',
  'Deny'
);

create table tokens (
  token_id bigserial primary key,
  user_id bigint references users(user_id),
  created_at timestamp not null default current_timestamp,
  token text
);

create index on tokens(token);
create index on tokens(user_id, token);

create table email_tokens(
  token varchar(64) primary key,
  user_id bigint not null references users(user_id),
  type token_type not null,
  created_at timestamp not null default current_timestamp
);

create table reset_tokens(
  token varchar(64) primary key,
  user_id bigint not null references users(user_id),
  created_at timestamp not null default current_timestamp
);

create table websocket_sessions (
  websocket_session_id varchar(64) not null primary key,
  user_id bigint references users(user_id),
  created_at timestamp not null default current_timestamp,
  token text not null -- one to many
);

create index on websocket_sessions (user_id);

create type email_sent_type as enum (
  'Register',
  'PasswordReset'
);

create type email_response_type as enum (
  'Bounce',
  'Complaint',
  'Delivery'
);

create table emails_sent (
  email_sent_id bigserial primary key,
  email varchar(255) not null,
  message_id varchar(64) not null,
  type email_sent_type not null,
  response email_response_type,
  created_at timestamp not null default current_timestamp
);

create index on emails_sent (message_id);

create table emails_blocked (
  email varchar(255) primary key,
  created_at timestamp not null default current_timestamp
);

create table notifications (
  notification_id bigserial primary key,
  user_id bigint not null references users(user_id),
  is_notified bool not null default false,
  text text,
  created_at timestamp not null default current_timestamp
);

create index on notifications (user_id, is_notified);

-- DATASETS ---------------------------------------------------------

create type iso_639_2_entry_type as enum (
  'B', -- Bibliograph
  'T'  -- Terminology
       -- null represents both
);

-- https://www.loc.gov/standards/iso639-2/php/code_list.php
create table iso_639_2 (
  id bigserial primary key,
  iso_639_2 char(3),
  entry_type iso_639_2_entry_type,
  iso_639_1 char(2),
  english_name varchar(128),
  french_name varchar(128),
  german_name varchar(128)
);

-- https://www.loc.gov/standards/iso639-5/id.php
create table iso_639_5 (
  id bigserial primary key,
  identifier char(3) not null,
  english_name varchar(128),
  french_name varchar(128),
  iso_639_2 varchar(128),
  hierarchy varchar(128),
  notes varchar(128)
);

-- SIL TABLES: http://www.iso639-3.sil.org/

-- I(ndividual), M(acrolanguage), S(pecial)
create type iso_639_3_scope_type as enum (
 'I',
 'M',
 'S'
);

-- A(ncient), C(onstructed), E(xtinct), H(istorical), L(iving), S(pecial)
create type iso_639_3_entry_type as enum (
 'A',
 'C',
 'E',
 'H',
 'L',
 'S'
);

create table iso_639_3 (
  id bigserial primary key,
  iso_639_3 char(3) not null, -- The three-letter 639-3 identifier
  part_2b char(3) null, -- Equivalent 639-2 identifier of the bibliographic applications code set, if there is one
  part_2t char(3) null, -- Equivalent 639-2 identifier of the terminology applications code set, if there is one
  part_1 char(2) null, -- Equivalent 639-1 identifier, if there is one    
  scope iso_639_3_scope_type not null, -- I(ndividual), M(acrolanguage), S(pecial)
  entry_type  iso_639_3_entry_type not null, -- A(ncient), C(onstructed), E(xtinct), H(istorical), L(iving), S(pecial)
  ref_name varchar(150) not null, -- Reference language name 
  comment varchar(150) null -- Comment relating to one or more of the columns
);

create table iso_639_3_names (
  id bigserial primary key,
  iso_639_3 char(3) not null, -- three letter 639-3 identifier
  print_name varchar(75) not null, -- one of the names associated with this identifier
  inverted_name varchar(75) not null -- the inverted form of this print_name form
);

-- Active, Retired
create type iso_639_3_status_type as enum (
  'A', 
  'R' 
);

CREATE TABLE iso_639_3_macrolanguages (
  id bigserial primary key,
  m_id char(3) not null, -- the identifier for a macrolanguage
  i_id char(3) not null, -- the identifier for an individual language that is a member of the macrolanguage
  i_status iso_639_3_status_type not null -- indicating the status of the individual code element
);

create type iso_639_3_retirement_reason_options as enum (
  'C', -- Change
  'D', -- Duplicate
  'N', -- Non-existent
  'S', -- Split
  'M' -- Merge
);

create table iso_639_3_retirements (
  id bigserial primary key,
  iso_639_3 char(3) not null, -- three letter 639-3 identifier
  ref_name varchar(150) not null, -- reference name of the language
  ret_reason iso_639_3_retirement_reason_options, -- code for retirement
  change_to char(3), -- in the cases of C, D, and M, the identifier to which all instances of this id should be changed
  ret_remedy varchar(300), -- the instructions for updating an instance of the retired (split) identifier
  effective timestamp not null -- the date the retirement became effective
);