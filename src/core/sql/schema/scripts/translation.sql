CREATE OR REPLACE FUNCTION load_data() RETURNS void as $$
  DECLARE 
    electionId integer;
    appId integer;
    siteTextId integer;
  BEGIN 
    -- Insert votables tables
    INSERT INTO admin.votables(table_name) VALUES('site_text_translations');
    INSERT INTO admin.votables(table_name) VALUES ('site_text_keys');
    -- Insert language skill
    INSERT INTO admin.language_skills(
        user_id,
        language_table,
        language_id,
        skill_level
      )
    VALUES(
        'user_id',
        'iso_639_6',
        (
          SELECT id
          FROM iso_639_3
          WHERE iso_639_3 = 'eng'
        ),
        '5'
      );

    -- Insert app
    INSERT INTO admin.app_list(app_name)
    VALUES('app_item') RETURNING id INTO appId;

    -- Insert site texts
    INSERT INTO admin.site_text_keys(
        app,
        language_table,
        language_id,
        site_text_key,
        description
      )
    VALUES(
        appId,
        'iso_639_3',
        (
          SELECT id
          FROM iso_639_3
          WHERE iso_639_3 = 'eng'
        ),
        'site_text_key',
        'description'
      );

     SELECT id INTO siteTextId
     FROM admin.site_text_keys
     WHERE site_text_key = 'site_text_key';
     
    -- Insert site text translations
    INSERT INTO admin.site_text_translations(
        site_text,
        language_table,
        language_id,
        user_id,
        site_text_translation,
        description_translation
      )
    VALUES(
        siteTextId,
        'iso_639_3',
        (
          SELECT id
          FROM iso_639_3
          WHERE iso_639_3 = 'eng'
        ),
        'user_id',
        'site text translation 1',
        'description translation 1'
      ),
      (
        siteTextId,
        'iso_639_3',
        (
          SELECT id
          FROM iso_639_3
          WHERE iso_639_3 = 'eng'
        ),
        'user_id',
        'site text translation 2',
        'description translation 2'
      ),
      (
        siteTextId,
        'iso_639_3',
        (
          SELECT id
          FROM iso_639_3
          WHERE iso_639_3 = 'eng'
        ),
        'user_id',
        'site text translation 3',
        'description translation 3'
      ),
      (
        siteTextId,
        'iso_639_3',
        (
          SELECT id
          FROM iso_639_3
          WHERE iso_639_3 = 'eng'
        ),
        'user_id',
        'site text translation 4',
        'description translation 4'
      );

    -- voting
    INSERT INTO admin.elections(app_id, name, created_by, table_name, row)
    VALUES(
        appId,
        (
          SELECT site_text_key
          FROM admin.site_text_keys
          WHERE site_text_key = 'site_text_key'
        ),
        'user_id',
        'site_text_keys',
        (
          SELECT id
          FROM admin.site_text_keys
          WHERE site_text_key = 'site_text_key'
        )
      )
    RETURNING id INTO electionId;


    INSERT INTO admin.ballot_entries(election_id, table_name, row, created_by)
    VALUES(
        electionId,
        'site_text_translations',
        (
          SELECT id
          FROM admin.site_text_translations
          WHERE site_text_translation = 'site text translation 1'
        ),
        'user_id'
      ),
      (
        electionId,
        'site_text_translations',
        (
          SELECT id
          FROM admin.site_text_translations
          WHERE site_text_translation = 'site text translation 2'
        ),
        'user_id'
      ),
      (
        electionId,
        'site_text_translations',
        (
          SELECT id
          FROM admin.site_text_translations
          WHERE site_text_translation = 'site text translation 3'
        ),
        'user_id'
      ),
      (
        electionId,
        'site_text_translations',
        (
          SELECT id
          FROM admin.site_text_translations
          WHERE site_text_translation = 'site text translation 4'
        ),
        'user_id'
      );

    INSERT INTO admin.votes(user_id, ballot_entry_id, up)
    VALUES(
        'showcaseuser@showcase.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 1'
        ),
        true
      ),
      (
        'daniel@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 2'
        ),
        true
      ),
      (
        'daniel@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 1'
        ),
        false
      ),
      (
        'daniel@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 3'
        ),
        false
      ),
      (
        'daniel@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 4'
        ),
        true
      ),
      (
        'michael@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 1'
        ),
        false
      ),
      (
        'michael@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 2'
        ),
        true
      ),
      (
        'michael@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 3'
        ),
        false
      ),
      (
        'svetlana@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 3'
        ),
        false
      ),
      (
        'svetlana@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 2'
        ),
        true
      ),
      (
        'hiroshi@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 2'
        ),
        true
      ),
      (
        'aslam@mail.com', 
        (
          SELECT be.id
          FROM admin.ballot_entries AS be
          JOIN admin.site_text_translations as stt ON stt.id = be.row
          WHERE stt.site_text_translation = 'site text translation 4'
        ),
        true
      );
  END;
  $$ LANGUAGE plpgsql;


SELECT load_data();