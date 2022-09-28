-- schema v1

-- GENERAL ---------------------------------------------------
create table database_version_control (
  id serial primary key,
  version int not null,
  started timestamp default current_timestamp,
  finished timestamp
);

create type table_names_enum as enum (
  -- need to add all table names
  'site_text_translations'
);

-- AUTHENTICATION ---------------------------------------------------

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

-- language skill ---------------------------------------------------
create type language_tables_enum as enum(
  'iso_639_3',
  'uf-languages'
);

create type language_skill_enum as enum (
  '1',
  '2',
  '3',
  '4',
  '5'
);

create table language_skills (
  id bigserial primary key,
  user_id varchar(512) not null, -- prolly will change, not sure how we will reference users yet
  language_table language_tables_enum not null,
  language_id bigint not null,
  skill_level language_skill_enum not null,
  unique (user_id, language_table, language_id)
);

-- site text ---------------------------------------------------
create table app_list (
  id bigserial primary key,
  app_name varchar(128)
);

create table site_text_keys (
  id bigserial primary key,
  app bigint not null references app_list(id),
  language_table language_tables_enum not null,
  language_id bigint not null,
  site_text_key varchar(512) not null,
  description varchar(512)
);

-- site text translation ---------------------------------------------------
create table site_text_translations(
  id bigserial primary key,
  user_id varchar(512) not null, -- prolly will change, not sure how we will reference users yet
  site_text bigint not null references site_text_keys(id),
  language_table language_tables_enum not null,
  language_id bigint not null,
  site_text_translation varchar(512) not null
);

-- voting ---------------------------------------------------
create table votes (
  id bigserial primary key,
  table_name table_names_enum not null,
  row bigint not null,
  up bool not null -- true = up vote, false = down vote, delete record to remove vote from user
);

-- discussion ---------------------------------------------------
create table discussions (
  id bigserial primary key,
  table_name table_names_enum not null,
  row bigint not null
);

create table posts (
  id bigserial primary key,
  discussion bigint references discussions(id),
  user_id varchar(512) not null, -- prolly will change, not sure how we will reference users yet
  quill_text text,
  plain_text text,
  postgres_language regconfig not null default 'simple',
  search_text tsvector generated always as (
  		to_tsvector(
   			postgres_language,
  			plain_text
  		)
  ) stored,
  created_at timestamp default current_timestamp
);

create index posts_search_gin on posts using gin (search_text);

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

create type progress_bible_language_details_unit_type as enum (
  'L', 
  'S',
  'D' 
);

create type progress_bible_language_details_code_status as enum (
  'Active', 
  'Retired'
);

create type progress_bible_language_details_language_status as enum (
  'Living', 
  'Extinct'
);

create table progress_bible_language_details(
  id bigserial primary key,
  unit_code varchar(5)  not null,
  unit_type progress_bible_language_details_unit_type not null,
  unit_name varchar(200) not null,
  unit_full_name varchar(200) not null,
  ethnologue_name varchar(200),
  iso_639_3_code varchar(5),
  is_sign_language bool,
  code_status progress_bible_language_details_code_status not null,
  language_status progress_bible_language_details_language_status not null,
  language_scope varchar(20),
  primary_continent varchar(200),
  primary_country_name varchar(200),
  primary_country_code char(2),
  retirement_explanation varchar(500),
  how_to_fix varchar(500),
  retired_date timestamp,
  show_active_language bool,
  show_retired_language bool,
  show_active_dialect bool,
  show_retired_dialect bool,
  show_sign_language bool
);

create table sil_country_codes(
    id bigserial primary key,
    code char(2) not null,
    name varchar(200) not null,
    area varchar(200) not null
);

create type sil_language_codes_status as enum (
 'L',
 'X'
);

create table sil_language_codes(
    id bigserial primary key,
    code char(3) not null,
    country_code char(2) not null,
    status sil_language_codes_status not null,
    name varchar(200) not null
);

create table sil_language_index(
    id bigserial primary key,
    language_code char(3) not null,
    country_code char(2) not null,
    name_type char(2) not null,
    name varchar(200) not null
);

create table uf_additional_languages(
    id bigserial primary key,
    ietf_tag varchar(200),
    two_letter char(2),
    three_letter char(3),
    common_name varchar(200),
    native_name varchar(200),
    direction char(3),
    comment varchar(500)
);

create table uf_countries_list(
    id bigserial primary key,
    code char(2),
    alpha_3_code char(3),
    name varchar(200),
    region varchar(200),
    wa_region varchar(200),
    population int
);

create table uf_langnames(
    id bigserial primary key,
    code varchar(100),
    name varchar(200)
);

create table uf_languages_with_bible_portions(
    id bigserial primary key,
    language varchar(200),
    media varchar(25),
    published bool default false,
    info varchar(500)
);

create table uf_languages_with_gospel_recording(
    id bigserial primary key,
    language varchar(200),
    media varchar(25),
    published bool default false,
    info varchar(500)
);

create table uf_languages_with_jesus_film(
     id bigserial primary key,
     language varchar(200),
     media varchar(25),
     published bool default false,
     info varchar(500)
 );

create table uf_languages_with_one_story_bible_stories(
    id bigserial primary key,
    language varchar(200),
    media varchar(25),
    published bool default false,
    info varchar(500)
);

create table uf_languages_with_open_bible_stories(
    id bigserial primary key,
    language varchar(200),
    media varchar(25),
    published bool default false,
    info text
);

create table uf_languages_with_radio_broadcast(
    id bigserial primary key,
    language varchar(200),
    media varchar(25),
    published bool default false,
    info text
);

create table uf_languages(
    id bigserial primary key,
    code varchar(50) not null,
    iso_639_3 char(3),
    name varchar(200) not null,
    alternate_name text,
    anglicized_name varchar(200),
    country varchar(200),
    gateway_language varchar(200),
    gw varchar(200)
);

create table uf_networks(
    id bigserial primary key,
    network varchar(200),
    countries text,
    languages text
);

create table gsec_listing_of_people_groups(
    id bigserial primary key,
    peid bigint,
    affinity_bloc varchar(200),
    people_cluster varchar(512),
    continent varchar(200),
    sub_continent varchar(200),
    country varchar(200),
    country_of_origin varchar(200),
    people_group varchar(200),
    global_status_of_evangelical_christianity int,
    evangelical_engagement bool,
    population bigint, -- confirm
    dispersed bool,
    rol char(3),
    language varchar(200),
    religion varchar(200),
    nomadic bool,
    nomadic_type int,
    nomadic_description varchar(200),
    written_scripture bool,
    jesus_film bool,
    radio_broadcast bool,
    gospel_recording bool,
    audio_scripture bool,
    gospel_films bool,
    the_hope bool,
    resources int, -- 25
    physical_exertion varchar(25), -- can be enum
    freedom_index varchar(25), -- can be enum
    government_restrictions_index text, -- can be enum some rows have detailed text
    social_hostilities_index varchar(25), -- can be enum
    threat_level varchar(250),
    rop1 char(5),
    rop2 varchar(10),
    rop3 int,
    people_name varchar(200),
    genc char(3),
    fips char(2),
    fips_of_origin char(2),
    latitude varchar(50),
    longitude varchar(50),
    imb_affinity_group varchar(200),
    not_engaged_anywhere varchar(5),
    spi int,
    strategic_priority_index varchar(200),
    population_layer varchar(50)
);

--2022-08_GSEC_Listing_of_Unengaged_Unreached_People_Groups
create table gsec_listing_of_unengaged_unreached_people_groups(
    id bigserial primary key,
    peid bigint,
    affinity_bloc varchar(200),
    people_cluster varchar(200),
    continent varchar(200),
    sub_continent varchar(200),
    country varchar(200),
    country_of_origin varchar(200),
    people_group varchar(200),
    global_status_of_evangelical_christianity int,
    evangelical_engagement bool,
    population bigint,
    dispersed bool,
    rol char(3),
    language varchar(200),
    religion varchar(200),
    nomadic bool,
    nomadic_type int,
    nomadic_description varchar(200),
    published_scripture bool,
    jesus_film bool,
    radio_broadcast bool,
    gospel_recording bool,
    audio_scripture bool,
    gospel_films bool,
    the_hope bool,
    resources int,
    physical_exertion varchar(25),
    freedom_index varchar(25),
    government_restrictions_index text,
    social_hostilities_index varchar(25),
    threat_level varchar(250),
    rop1 char(5),
    rop2 varchar(10),
    rop3 int,
    rop_people_name varchar(200),
    genc char(3),
    fips  char(2),
    fips_of_origin char(2),
    latitude varchar(50),
    longitude varchar(50),
    imb_affinity_group varchar(200),
    not_engaged_anywhere varchar(5),
    spi int,
    strategic_priority_index varchar(200),
    ror varchar(10),
    diaspora  bool
);

create table gsec_listing_of_unreached_people_groups(
    id bigserial primary key,
    peid bigint,
    affinity_bloc varchar(200),
    people_cluster varchar(200),
    continent varchar(200),
    sub_continent varchar(200),
    country varchar(200),
    country_of_origin varchar(200),
    people_group varchar(200),
    global_status_of_evangelical_christianity int,
    evangelical_engagement bool,
    population bigint,
    dispersed bool,
    rol char(3),
    language varchar(200),
    religion varchar(200),
    nomadic bool,
    nomadic_type int,
    nomadic_description varchar(200),
    published_scripture bool,
    jesus_film bool,
    radio_broadcast bool,
    gospel_recording bool,
    audio_scripture bool,
    gospel_films bool,
    the_hope bool,
    resources int,
    physical_exertion varchar(25),
    freedom_index varchar(25),
    government_restrictions_index text,
    social_hostilities_index varchar(25),
    threat_level varchar(250),
    rop1 char(5),
    rop2 varchar(10),
    rop3 int,
    rop_people_name varchar(200),
    genc char(3),
    fips char(2),
    fips_of_origin char(2),
    latitude varchar(50),
    longitude varchar(50),
    imb_affinity_group varchar(200),
    not_engaged_anywhere char(5),
    spi int,
    strategic_priority_index varchar(200)
);

create table gsec_listing_of_uupg_100k_additions(
    id bigserial primary key,
    peid bigint,
    affinity_bloc varchar(200),
    people_cluster varchar(200),
    country varchar(200),
    people_group varchar(200),
    global_status_of__evangelical_christianity int,
    language varchar(200),
    religion varchar(200),
    population bigint,
    addition_date timestamp,
    addition_reasons text
);

create table gsec_listing_of_uupg_100k_removals(
    id bigserial primary key,
    peid bigint,
    affinity_bloc varchar(200),
    people_cluster varchar(200),
    country varchar(200),
    people_group varchar(200),
    global_status_of_evangelical_christianity int,
    language varchar(200),
    religion varchar(200),
    population bigint,
    addition_date timestamp,
    addition_reasons text
);

create table gsec_listing_of_uupg_100k(
    id bigserial primary key,
    peid bigint,
    affinity_bloc varchar(200),
    people_cluster varchar(200),
    continent varchar(200),
    sub_continent varchar(200),
    country varchar(200),
    country_of_origin varchar(200),
    people_group varchar(200),
    global_status_of_evangelical_christianity int,
    rol char(3),
    language varchar(200),
    religion varchar(200),
    nomadic bool,
    nomadic_type int,
    nomadic_description varchar(200),
    population bigint,
    dispersed bool,
    published_scripture bool,
    jesus_film bool,
    radio_broadcast bool,
    gospel_recording bool,
    audio_scripture bool,
    gospel_films bool,
    the_hope bool,
    resources int,
    physical_exertion varchar(25),
    freedom_index varchar(25),
    government_restrictions_index text,
    social_hostilities_index varchar(25),
    threat_level varchar(250),
    rop1 char(5),
    rop2 varchar(10),
    rop3 int,
    people_name varchar(200),
    genc char(3),
    fips char(2),
    fips_of_origin char(2),
    latitude varchar(50),
    longitude varchar(50),
    addition bool,
    addition_date timestamp,
    addition_reasons text,
    imb_affinity_group varchar(200),
    not_engaged_anywhere varchar(50),
    spi int,
    strategic_priority_index varchar(200)
);

create table people_groups_data_only(
    id bigserial primary key,
    peid bigint,
    affinity_bloc varchar(200),
    people_cluster varchar(512),
    continent varchar(200),
    sub_continent varchar(200),
    country varchar(200),
    country_of_origin varchar(200),
    people_group varchar(200),
    global_status_of_evangelical_christianity int,
    evangelical_engagement bool,
    population bigint,
    dispersed bool,
    rol char(3),
    language varchar(200),
    religion varchar(200),
    nomadic bool,
    nomadic_type int,
    nomadic_description varchar(200),
    written_scripture bool,
    jesus_film bool,
    radio_broadcast bool,
    gospel_recording bool,
    audio_scripture bool,
    gospel_films bool,
    the_hope bool,
    resources int,
    physical_exertion varchar(25),
    freedom_index varchar(25),
    government_restrictions_index text,
    social_hostilities_index varchar(25),
    threat_level varchar(250),
    rop1 char(5),
    rop2 varchar(10),
    rop3 int,
    people_name varchar(200),
    genc char(3),
    fips char(2),
    fips_of_origin char(2),
    latitude varchar(50),
    longitude varchar(50),
    imb_affinity_group varchar(200),
    not_engaged_anywhere varchar(5),
    spi int,
    strategic_priority_index varchar(200),
    population_layer varchar(50)
);

create table rod_dialects(
    id bigserial primary key,
    dialect_code varchar(10),
    language_code char(3),
    country_code char(2),
    dialect_name varchar(200),
    language_name varchar(200),
    location_name varchar(200)
);

create table rod_changelist(
    id bigserial primary key,
    dialect_code varchar(10),
    date timestamp,
    change_type char(3),
    prev_language_code char(3),
    new_language_code char(3),
    explanation text
);

create table rod_alternatenameindex(
    id bigserial primary key,
    dialect_code varchar(10),
    variant_name varchar(500)
);

create table glottolog_language(
    id bigserial primary key,
    glottocode varchar(20),
    name varchar(200),
    top_level_family varchar(200),
    iso_639_3 char(3),
    macro_area varchar(200),
    child_dialects int,
    latitude varchar(50),
    longitude varchar(50)
);

create table glottolog_family(
    id bigserial primary key,
    name varchar(200),
    level varchar(200),
    macro_area varchar(550),
    sub_families int,
    child_languages int,
    top_level_family int
);

-- USQ - Universal Scripture SQL

create table usq_schemas (
  schema_id bigserial primary key,
  name varchar(128) unique not null,
  meta jsonb
);

create table usq_bibles (
  bible_id bigserial primary key,
  language_index varchar(64) not null,
  language_id bigserial not null,
  name varchar(256) not null,
  meta jsonb,
  unique (language_index, language_id, name)
);

create table usq_book_index (
  book_index_id bigserial primary key,
  name varchar(64) not null unique,
  meta jsonb
);

create table usq_books (
  book_id bigserial primary key,
  bible_id bigint not null references usq_bibles(bible_id),
  book_index_id bigint not null references usq_book_index(book_index_id),
  meta jsonb,
  unique (bible_id, book_index_id)
);

create table usq_chapters (
  chapter_id bigserial primary key,
  book_id bigint not null references usq_books(book_id),
  chapter_number int not null,
  meta jsonb,
  unique (book_id, chapter_number)
);

create table usq_verses (
  verse_id bigserial primary key,
  chapter_id bigint not null references usq_chapters(chapter_id),
  verse_number int not null,
  meta jsonb,
  unique (chapter_id, verse_number)
);

create table usq_word_index (
  word_index_id bigserial primary key,
  language_index varchar(64) not null,
  language_id bigserial not null,
  word varchar(64) not null,
  meta jsonb,
  unique (language_index, language_id, word)
);

create table usq_word_references (
  word_ref_id bigserial primary key,
  verse_id bigint not null references usq_verses(verse_id),
  word_index_id bigint not null references usq_word_index(word_index_id),
  word_number int not null,
  meta jsonb
);

-- Alignment References (two_way)

create type usq_alignment_type as enum (
  '>', 
  '<',
  '=' 
);

create table usq_chapter_starts_alignment (
  chapter_starts_alignment_id bigserial primary key,
  chapter_id_1 bigint not null references usq_chapters(chapter_id),
  chapter_id_2 bigint not null references usq_chapters(chapter_id),
  alignment usq_alignment_type not null,
  meta jsonb,
  unique (chapter_id_1, chapter_id_2)
);

create table usq_chapter_stops_alignment (
  chapter_stops_alignment_id bigserial primary key,
  chapter_id_1 bigint not null references usq_chapters(chapter_id),
  chapter_id_2 bigint not null references usq_chapters(chapter_id),
  alignment usq_alignment_type not null,
  meta jsonb,
  unique (chapter_id_1, chapter_id_2)
);

create table usq_verse_starts_alignment (
  verse_starts_alignment_id bigserial primary key,
  verse_id_1 bigint not null references usq_verses(verse_id),
  verse_id_2 bigint not null references usq_verses(verse_id),
  alignment usq_alignment_type not null,
  meta jsonb,
  unique (verse_id_1, verse_id_2)
);

create table usq_verse_stops_alignment (
  verse_stops_alignment_id bigserial primary key,
  verse_id_1 bigint not null references usq_verses(verse_id),
  verse_id_2 bigint not null references usq_verses(verse_id),
  alignment usq_alignment_type not null,
  meta jsonb,
  unique (verse_id_1, verse_id_2)
);

-- Resource References (one-way)

create table usq_word_to_word_references (
  word_word_ref_id bigserial primary key,
  source_word bigint not null references usq_word_references(word_ref_id),
  target_word bigint not null references usq_word_references(word_ref_id),
  meta jsonb
);

create table usq_word_to_verse_references (
  word_verse_ref_id bigserial primary key,
  source_word bigint not null references usq_word_references(word_ref_id),
  target_verse bigint not null references usq_verses(verse_id),
  meta jsonb
);

create table usq_word_to_chapter_references (
  word_chapter_ref_id bigserial primary key,
  source_word bigint not null references usq_word_references(word_ref_id),
  target_chapter bigint not null references usq_chapters(chapter_id),
  meta jsonb
);

create table usq_verse_to_verse_references (
  verse_verse_ref_id bigserial primary key,
  source_verse bigint not null references usq_verses(verse_id),
  target_verse bigint not null references usq_verses(verse_id),
  meta jsonb
);

create table usq_verse_to_chapter_references (
  verse_chapter_ref_id bigserial primary key,
  source_verse bigint not null references usq_verses(verse_id),
  target_chapter bigint not null references usq_chapters(chapter_id),
  meta jsonb
);

create table usq_book_to_chapter_references (
  book_chapter_ref_id bigserial primary key,
  source_book bigint not null references usq_books(book_id),
  target_chapter bigint not null references usq_chapters(chapter_id),
  meta jsonb
);

-- more types of reference tables can be created as needed
