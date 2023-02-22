-- schema.sql
-- can only be run after the bootstrap.sql file is run manually to setup the db

-- GENERAL ------------------------------------------------------------

create schema admin;

CREATE OR REPLACE FUNCTION random_between(low INT ,high INT)
   RETURNS INT AS
$$
BEGIN
   RETURN floor(random()* (high-low + 1) + low);
END;
$$ language 'plpgsql' STRICT;

-- VERSION CONTROL ---------------------------------------------------

CREATE TABLE typeorm_metadata (
  "type" varchar(255) NOT NULL,
  "database" varchar(255) DEFAULT NULL,
  "schema" varchar(255) DEFAULT NULL,
  "table" varchar(255) DEFAULT NULL,
  "name" varchar(255) DEFAULT NULL,
  "value" text
);

-- reference table
create table database_version_control (
  id bigserial primary key,
  version bigint not null,
  completed timestamp default current_timestamp
);

-- Organizations, Roles, Authorization -----------------------------------------------

create table admin.site_admins(
  id bigserial primary key,
  name varchar(64) not null unique
);

create table admin.organizations (
  id bigserial primary key,
  name varchar(128) not null unique
);

create table admin.roles (
  id bigserial primary key,
  organization bigint not null references admin.organizations(id),
  name varchar(64) not null,
  unique (organization, name)
);

-- language skill ---------------------------------------------------
create type admin.language_skill_enum as enum (
  '1',
  '2',
  '3',
  '4',
  '5'
);

create table admin.language_skills (
  id bigserial primary key,
  user_id varchar(512) not null, -- prolly will change, not sure how we will reference users yet
  language_table varchar(64) not null,
  language_id bigint not null,
  skill_level admin.language_skill_enum not null,
  unique (user_id, language_table, language_id)
);

-- site text ---------------------------------------------------
create table admin.app_list (
  id bigserial primary key,
  app_name varchar(128)
);

create table admin.site_text_keys (
  id bigserial primary key,
  app bigint not null references admin.app_list(id),
  language_table varchar(64) not null,
  language_id bigint not null,
  site_text_key varchar(512) not null,
  description varchar(512),
  unique (app, site_text_key)
);

-- site text translation ---------------------------------------------------
create table admin.site_text_translations(
  id bigserial primary key,
  site_text bigint not null references admin.site_text_keys(id),
  language_table varchar(64) not null,
  language_id bigint not null,
  user_id varchar(512) not null, -- prolly will change, not sure how we will reference users yet
  site_text_translation varchar(512) not null,
  description_translation varchar(512) not null,
  unique (site_text, site_text_translation)
);

-- GRAPH ------------------------------------------------------------

create table admin.node_types (
  type_name varchar(32) primary key
);

create table admin.nodes (
  node_id bigserial primary key,
  node_type varchar(32) references node_types(type_name)
);

create table admin.node_property_keys (
  node_property_key_id bigserial primary key,
  node_id bigint references nodes(node_id) not null,
  property_key varchar(64)
);

create index idx_node_property_keys_node_id_key on node_property_keys (node_id);

create table admin.node_property_values (
  node_property_value_id bigserial primary key,
  node_property_key_id bigint references node_property_keys(node_property_key_id) not null,
  property_value jsonb
);

create index idx_node_property_values_key_id on node_property_values (node_property_key_id);

create table admin.relationship_types (
  type_name varchar(32) primary key
);

create table admin.relationships (
  relationship_id bigserial primary key,
  relationship_type varchar(32) references relationship_types(type_name),
  from_node_id bigint references nodes(node_id),
  to_node_id bigint references nodes(node_id)
);

create index idx_relationships_from_node_id on relationships (from_node_id);
create index idx_relationships_to_node_id on relationships (to_node_id);

create table admin.relationship_property_keys (
  relationship_property_key_id bigserial primary key,
  relationship_id bigint references relationships(relationship_id) not null,
  property_key varchar(64)
);

create index idx_relationship_property_keys_relationship_id on relationship_property_keys (relationship_id);

create table admin.relationship_property_values (
  relationship_property_value_id bigserial primary key,
  relationship_property_key_id bigint references relationship_property_keys(relationship_property_key_id) not null,
  property_value jsonb
);

create index idx_relationship_property_values_key_id on relationship_property_values (relationship_property_key_id);

insert into admin.node_types (type_name) values
  ('word'),
  ('addition'),
  ('word-sequence'),
  ('sentence'),
  ('verse'),
  ('paragraph'),
  ('chapter'),
  ('section'),
  ('book'),
  ('bible'),

  ('definition'),
  ('article'),
  ('lexical-entry'),
  ('strongs-entry');

insert into admin.relationship_types (type_name) values
  ('word-sequence-to-word'),
  ('verse-to-word-sequence'),
  ('sentence-to-word-sequence'),
  ('chapter-to-verse'),
  ('book-to-chapter'),
  ('chapter-to-section'),
  ('chapter-to-paragraph'),
  ('bible-to-book'),
  
  ('word-to-article'),

  ('word-to-strongs-entry'),
  ('word-to-addition'),
  ('section-to-paragraph'),
  ('section-to-section'),
  ('article-to-section'),
  ('article-to-paragraph'),
  ('article-to-sentence'),
  ('paragraph-to-sentence'),
  ('paragraph-to-verse'),
  ('verse-to-sentence'),
  ('sentence-to-word');

-- voting ---------------------------------------------------
create table admin.votables(
  table_name varchar(64) not null unique
);

create table admin.elections (
  id bigserial primary key,
  app_id bigint not null, -- todo, references app
  name varchar(128) not null,
  table_name varchar(64) not null references admin.votables(table_name),
  row bigint not null,
  created_by varchar(512), -- placeholder, not sure how to reference users yet
  unique (app_id, name)
);

create table admin.ballot_entries (
  id bigserial primary key,
  election_id bigint not null references admin.elections(id),
  table_name varchar(64) not null references admin.votables(table_name),
  row bigint not null,
  created_by varchar(512) -- placeholder, not sure how to reference users yet
);

create table admin.votes (
  id bigserial primary key,
  user_id varchar(512),
  ballot_entry_id bigint not null references admin.ballot_entries(id),
  up bool not null, -- true = up vote, false = down vote, delete record to remove vote from user
  unique (user_id, ballot_entry_id)
);

-- discussion ---------------------------------------------------
create table admin.discussions (
  id bigserial primary key,
  app bigint not null references admin.app_list(id),
  org bigint not null references admin.organizations(id),
  table_name varchar(64) not null,
  row bigint not null
);

create table admin.posts (
  id bigserial primary key,
  discussion_id bigint references admin.discussions(id),
  user_id bigint not null references admin.users(user_id), 
  -- prolly will change, not sure how we will reference users yet
  quill_text text,
  plain_text text,
  postgres_language regconfig not null default 'simple',
  search_text tsvector generated always as (
  		to_tsvector(
   			postgres_language,
  			plain_text
  		)
  ) stored,
  is_edited bool not null default false,
  reply_id bigint references admin.posts(id),
  created_at timestamp default current_timestamp
);

create index posts_search_gin on admin.posts using gin (search_text);

create table admin.reactions (
  id bigserial primary key,
  user_id bigint not null references admin.users(user_id), 
  -- will change, we use sso to track users
  post_id bigint not null references admin.posts(id),
  content varchar(64) not null,
  unique (user_id, content, post_id)
);

-- file ---------------------------------------------------
create table admin.files (
  id bigserial primary key,
  file_name varchar(256) not null,
  file_size bigint not null,
  file_type varchar(256),
  file_url varchar(256) not null
);

-- relationship_post_file ---------------------------------
create table admin.relationship_post_file (
  id bigserial primary key,
  post_id bigint not null references admin.posts(id),
  file_id bigint not null references admin.files(id)
);

-- NOTIFICATIONS ----------------------------------------------------
create table admin.notifications (
  id bigserial primary key,
  user_id bigint not null references admin.users(user_id),
  table_name varchar(64) not null,
  row bigint not null,
  acknowledged bool not null default false,
  content text,
  created_at timestamp default current_timestamp
);

CREATE MATERIALIZED VIEW strongs_dictionary
AS
SELECT n.node_id
, jsonb_object_agg(npk.property_key, npv.property_value->'value')->>'lemma' AS lemma
, jsonb_object_agg(npk.property_key, npv.property_value->'value')->>'xlit' AS xlit
, jsonb_object_agg(npk.property_key, npv.property_value->'value')->>'pron' AS pron
, jsonb_object_agg(npk.property_key, npv.property_value->'value')->>'derivation' AS derivation
, jsonb_object_agg(npk.property_key, npv.property_value->'value')->>'strongs_def' AS strongs_def
, jsonb_object_agg(npk.property_key, npv.property_value->'value')->>'kjv_def' AS kjv_def
, jsonb_object_agg(npk.property_key, npv.property_value->'value')->>'strongs_id' AS strongs_id
FROM nodes n
LEFT JOIN node_property_keys npk ON
npk.node_id = n.node_id
LEFT JOIN node_property_values npv ON
npv.node_property_key_id = npk.node_property_key_id
WHERE n.node_type = 'strongs-entry'
GROUP BY n.node_id
WITH DATA;

CREATE UNIQUE INDEX idx_strongs_dictionary_strongs_id
  ON strongs_dictionary (strongs_id);