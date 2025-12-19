--
-- PostgreSQL database dump
--

\restrict 4hZV5ZNC4oqfRFbV6792dOaTk28hD9XpacoCNFFdjhG9jqG3eIZknv8SDgAkAoQ

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA supabase_migrations;


ALTER SCHEMA supabase_migrations OWNER TO postgres;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


ALTER TYPE auth.oauth_authorization_status OWNER TO supabase_auth_admin;

--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


ALTER TYPE auth.oauth_client_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


ALTER TYPE auth.oauth_response_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


ALTER TYPE storage.buckettype OWNER TO supabase_storage_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION storage.add_prefixes(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


ALTER FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION storage.delete_prefix(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION storage.delete_prefix_hierarchy_trigger() OWNER TO supabase_storage_admin;

--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION storage.enforce_bucket_name_length() OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION storage.get_level(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION storage.get_prefix(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION storage.get_prefixes(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: lock_top_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


ALTER FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_insert_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_update_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_level_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_level_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_level_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.prefixes_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.prefixes_insert_trigger() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


ALTER FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


ALTER TABLE auth.oauth_authorizations OWNER TO supabase_auth_admin;

--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE auth.oauth_client_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;

--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


ALTER TABLE auth.oauth_consents OWNER TO supabase_auth_admin;

--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: Groep; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Groep" (
    groep_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    groep_naam text DEFAULT ''::text,
    omschrijving text,
    owner_lid_id bigint,
    invite_code character varying DEFAULT 'NOT NULL'::character varying NOT NULL,
    portefeuille_id bigint,
    instap_nav_pct numeric DEFAULT 0,
    instap_liq_pct numeric DEFAULT 0,
    uitstap_nav_pct numeric DEFAULT 0,
    uitstap_liq_pct numeric DEFAULT 0,
    liq_per_lid boolean DEFAULT false
);


ALTER TABLE public."Groep" OWNER TO postgres;

--
-- Name: Groep_Groepid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Groep" ALTER COLUMN groep_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Groep_Groepid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Kas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Kas" (
    kas_id bigint NOT NULL,
    groep_id bigint NOT NULL,
    date timestamp with time zone DEFAULT now() NOT NULL,
    amount numeric(12,2) NOT NULL,
    type text NOT NULL,
    description text,
    created_by bigint,
    CONSTRAINT "Kas_type_check" CHECK ((type = ANY (ARRAY['in'::text, 'out'::text]))),
    CONSTRAINT kas_amount_positive CHECK ((amount > (0)::numeric))
);


ALTER TABLE public."Kas" OWNER TO postgres;

--
-- Name: Kas_kas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Kas" ALTER COLUMN kas_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Kas_kas_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Leden; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Leden" (
    ledenid bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    "GSM" text,
    voornaam character varying,
    achternaam character varying,
    email text
);


ALTER TABLE public."Leden" OWNER TO postgres;

--
-- Name: Leden_Ledenid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Leden" ALTER COLUMN ledenid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Leden_Ledenid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Liquiditeit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Liquiditeit" (
    id bigint NOT NULL,
    groep_id bigint NOT NULL,
    datum date DEFAULT CURRENT_DATE NOT NULL,
    bedrag numeric NOT NULL,
    omschrijving text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public."Liquiditeit" OWNER TO postgres;

--
-- Name: Liquiditeit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Liquiditeit_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Liquiditeit_id_seq" OWNER TO postgres;

--
-- Name: Liquiditeit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Liquiditeit_id_seq" OWNED BY public."Liquiditeit".id;


--
-- Name: Portefeuille; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Portefeuille" (
    port_id bigint NOT NULL,
    ticker text DEFAULT '0'::text,
    quantity real,
    avg_price real DEFAULT '0'::real,
    groep_id bigint NOT NULL,
    transactiekost double precision
);


ALTER TABLE public."Portefeuille" OWNER TO postgres;

--
-- Name: COLUMN "Portefeuille".quantity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."Portefeuille".quantity IS 'Het huidige aantal effecten. Dit veld kan berekend worden uit Transacties, maar wordt hier bewaard voor performante weergave.';


--
-- Name: COLUMN "Portefeuille".avg_price; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."Portefeuille".avg_price IS 'De gewogen gemiddelde aankoopprijs (WAC). Dit veld is afgeleid en wordt hier bewaard voor prestaties.';


--
-- Name: Portefeuille_Portefeuille id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Portefeuille" ALTER COLUMN port_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Portefeuille_Portefeuille id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Transacties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Transacties" (
    transactie_id bigint NOT NULL,
    datum_tr date NOT NULL,
    type text NOT NULL,
    ticker text NOT NULL,
    aantal numeric NOT NULL,
    koers numeric NOT NULL,
    munt text DEFAULT 'EUR'::text NOT NULL,
    portefeuille_id bigint,
    wisselkoers double precision
);


ALTER TABLE public."Transacties" OWNER TO postgres;

--
-- Name: COLUMN "Transacties".munt; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."Transacties".munt IS 'Valuta van de transactie. De wisselkoers (koers) voor de conversie moet dynamisch worden opgehaald uit de Wisselkoersen-tabel op basis van datum en munt.';


--
-- Name: Transacties_transactie_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Transacties" ALTER COLUMN transactie_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Transacties_transactie_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Wisselkoersen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Wisselkoersen" (
    wk numeric,
    munt text NOT NULL
);


ALTER TABLE public."Wisselkoersen" OWNER TO postgres;

--
-- Name: activa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activa (
    ticker text NOT NULL,
    name text NOT NULL,
    sector text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.activa OWNER TO postgres;

--
-- Name: TABLE activa; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.activa IS 'Genormaliseerde tabel voor effecteninformatie (naam, sector) om redundantie te voorkomen in Portefeuille en Transacties.';


--
-- Name: groep_leden; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groep_leden (
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    groep_id bigint NOT NULL,
    ledenid bigint NOT NULL,
    rol text DEFAULT '"member"'::text
);


ALTER TABLE public.groep_leden OWNER TO postgres;

--
-- Name: groepsaanvragen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groepsaanvragen (
    id bigint NOT NULL,
    groep_id bigint NOT NULL,
    ledenid bigint NOT NULL,
    type text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    processed_by bigint
);


ALTER TABLE public.groepsaanvragen OWNER TO postgres;

--
-- Name: groepsaanvragen_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.groepsaanvragen ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.groepsaanvragen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: kas_saldo_per_groep; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.kas_saldo_per_groep AS
 SELECT groep_id,
    (COALESCE(sum(
        CASE
            WHEN (type = 'in'::text) THEN amount
            ELSE (- amount)
        END), (0)::numeric))::numeric(14,2) AS saldo
   FROM public."Kas"
  GROUP BY groep_id;


ALTER VIEW public.kas_saldo_per_groep OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE storage.buckets_analytics OWNER TO supabase_storage_admin;

--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.buckets_vectors OWNER TO supabase_storage_admin;

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE storage.prefixes OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.vector_indexes OWNER TO supabase_storage_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text,
    created_by text,
    idempotency_key text
);


ALTER TABLE supabase_migrations.schema_migrations OWNER TO postgres;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: Liquiditeit id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Liquiditeit" ALTER COLUMN id SET DEFAULT nextval('public."Liquiditeit_id_seq"'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	79928c65-66d2-4def-bc3c-0cf96bbeb440	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"paarde@blabla","user_id":"9dc62846-efdd-4c68-baa5-50c904c5450b","user_phone":""}}	2025-11-04 15:19:40.749191+00	
00000000-0000-0000-0000-000000000000	eb349789-7a68-4c0f-b674-c566ea556648	{"action":"login","actor_id":"9dc62846-efdd-4c68-baa5-50c904c5450b","actor_username":"paarde@blabla","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 15:19:41.387279+00	
00000000-0000-0000-0000-000000000000	89929d65-766f-44b6-80f5-9c89a77f2cd0	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"john.dhoe@gmail.com","user_id":"14936625-6eba-465b-a427-a15842a82450","user_phone":""}}	2025-11-04 15:22:14.914967+00	
00000000-0000-0000-0000-000000000000	b5ef3c0e-7804-48a9-8a78-9313ee2fb812	{"action":"login","actor_id":"14936625-6eba-465b-a427-a15842a82450","actor_username":"john.dhoe@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 15:22:15.284865+00	
00000000-0000-0000-0000-000000000000	5874b363-9e49-475f-8b90-f93c8cc2181a	{"action":"logout","actor_id":"14936625-6eba-465b-a427-a15842a82450","actor_username":"john.dhoe@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 15:28:29.962478+00	
00000000-0000-0000-0000-000000000000	20a7cde9-9f38-4d6b-b6e2-84d4c98c9c9e	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"blabla@blabla.be","user_id":"533ebd46-0034-482f-af84-456b05189170","user_phone":""}}	2025-11-05 13:11:37.015931+00	
00000000-0000-0000-0000-000000000000	1527a276-4354-4295-bfad-53444020a1e9	{"action":"login","actor_id":"533ebd46-0034-482f-af84-456b05189170","actor_username":"blabla@blabla.be","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 13:11:41.76062+00	
00000000-0000-0000-0000-000000000000	38faeb9f-b35c-48d9-91b9-f58c39cbca32	{"action":"login","actor_id":"533ebd46-0034-482f-af84-456b05189170","actor_username":"blabla@blabla.be","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 13:20:54.337094+00	
00000000-0000-0000-0000-000000000000	a1d4dde9-9e60-4105-9768-a8eb3b24746b	{"action":"login","actor_id":"533ebd46-0034-482f-af84-456b05189170","actor_username":"blabla@blabla.be","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 13:21:44.928201+00	
00000000-0000-0000-0000-000000000000	3a13ca2f-8a15-42df-81ef-f04fefa13155	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"haha@gmail.com","user_id":"f638a8b0-eef3-4dda-a645-552789c26e42","user_phone":""}}	2025-11-05 13:22:28.575787+00	
00000000-0000-0000-0000-000000000000	e9a2b462-a590-4462-b2a8-58f99c47af62	{"action":"login","actor_id":"f638a8b0-eef3-4dda-a645-552789c26e42","actor_username":"haha@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 13:22:29.191864+00	
00000000-0000-0000-0000-000000000000	212a2690-4d53-4705-b5fd-60257b47b192	{"action":"login","actor_id":"533ebd46-0034-482f-af84-456b05189170","actor_username":"blabla@blabla.be","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 13:34:31.734791+00	
00000000-0000-0000-0000-000000000000	e157ba86-0151-41ff-b76e-ccaa116974bd	{"action":"logout","actor_id":"533ebd46-0034-482f-af84-456b05189170","actor_username":"blabla@blabla.be","actor_via_sso":false,"log_type":"account"}	2025-11-05 13:39:07.469861+00	
00000000-0000-0000-0000-000000000000	c10a2a54-3c2e-4de1-8a43-06923832fd9d	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"yippee@gmail.com","user_id":"305f5aff-0765-495a-a3ef-5e51b2314f7e","user_phone":""}}	2025-11-05 13:40:05.414164+00	
00000000-0000-0000-0000-000000000000	aa31d782-3723-4603-ac86-f8f9f78e7694	{"action":"login","actor_id":"305f5aff-0765-495a-a3ef-5e51b2314f7e","actor_username":"yippee@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 13:40:05.764588+00	
00000000-0000-0000-0000-000000000000	0b3ab383-0ba6-40cb-a5ff-aa14fbbf8ce8	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"bast@de.be","user_id":"a1caf0ea-6471-4b59-9506-fec49466242e","user_phone":""}}	2025-11-05 13:45:35.108171+00	
00000000-0000-0000-0000-000000000000	ddcf65dc-4a7a-42a6-b3f0-d371f35ed81f	{"action":"login","actor_id":"a1caf0ea-6471-4b59-9506-fec49466242e","actor_username":"bast@de.be","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 13:45:35.452743+00	
00000000-0000-0000-0000-000000000000	0d208603-f674-44cb-abce-5beccf6537ba	{"action":"user_confirmation_requested","actor_id":"78002993-c430-4d2f-8478-c4b837002fd3","actor_username":"bastien.demeyer@ugent.be","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-11-09 15:53:54.514624+00	
00000000-0000-0000-0000-000000000000	616712c2-ad15-4281-ac5e-7a7a3188c5d3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"blabla@blabla.be","user_id":"533ebd46-0034-482f-af84-456b05189170","user_phone":""}}	2025-11-09 15:54:21.44932+00	
00000000-0000-0000-0000-000000000000	607fe228-73b6-4c28-a35e-e184be1eb3e3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"john.dhoe@gmail.com","user_id":"14936625-6eba-465b-a427-a15842a82450","user_phone":""}}	2025-11-09 15:54:32.595037+00	
00000000-0000-0000-0000-000000000000	cd07f95f-e219-4b9f-8f28-c9bf77d93eb7	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"yippee@gmail.com","user_id":"305f5aff-0765-495a-a3ef-5e51b2314f7e","user_phone":""}}	2025-11-09 15:54:39.703929+00	
00000000-0000-0000-0000-000000000000	4e73a370-7860-4587-bfdd-fddc9caa7435	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"paarde@blabla","user_id":"9dc62846-efdd-4c68-baa5-50c904c5450b","user_phone":""}}	2025-11-09 15:54:44.020041+00	
00000000-0000-0000-0000-000000000000	a8859413-36d7-4548-a323-47bb7b9d8e11	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"bast@de.be","user_id":"a1caf0ea-6471-4b59-9506-fec49466242e","user_phone":""}}	2025-11-09 15:54:47.537859+00	
00000000-0000-0000-0000-000000000000	d2915424-09b2-4cc4-b0e0-743c8b19ab37	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"haha@gmail.com","user_id":"f638a8b0-eef3-4dda-a645-552789c26e42","user_phone":""}}	2025-11-09 15:54:52.372849+00	
00000000-0000-0000-0000-000000000000	7572edd7-7d01-413e-b784-a63e7adeddb8	{"action":"user_signedup","actor_id":"78002993-c430-4d2f-8478-c4b837002fd3","actor_username":"bastien.demeyer@ugent.be","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-09 15:59:24.447547+00	
00000000-0000-0000-0000-000000000000	fe367a22-977a-4c63-b521-dc10d57db0a3	{"action":"login","actor_id":"78002993-c430-4d2f-8478-c4b837002fd3","actor_username":"bastien.demeyer@ugent.be","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-09 15:59:34.683376+00	
00000000-0000-0000-0000-000000000000	f43bf212-58ef-4955-a35f-34ca2cf54aee	{"action":"login","actor_id":"78002993-c430-4d2f-8478-c4b837002fd3","actor_username":"bastien.demeyer@ugent.be","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-09 16:00:27.549042+00	
00000000-0000-0000-0000-000000000000	c631760e-68e0-4c0d-9864-0019b2779ac0	{"action":"login","actor_id":"78002993-c430-4d2f-8478-c4b837002fd3","actor_username":"bastien.demeyer@ugent.be","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-09 16:01:48.403066+00	
00000000-0000-0000-0000-000000000000	366884a0-1426-44e6-ab98-f21c28112ab7	{"action":"user_repeated_signup","actor_id":"78002993-c430-4d2f-8478-c4b837002fd3","actor_username":"bastien.demeyer@ugent.be","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-11-09 16:14:20.529531+00	
00000000-0000-0000-0000-000000000000	4f4e013d-6902-4a43-a68e-96c3c3bd562f	{"action":"user_signedup","actor_id":"67d66902-5ff4-43b1-b60e-c64935084cad","actor_username":"test@test.be","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-09 16:33:41.004804+00	
00000000-0000-0000-0000-000000000000	36678b8e-a8d1-468d-9b72-0b36dfa2c3a7	{"action":"login","actor_id":"67d66902-5ff4-43b1-b60e-c64935084cad","actor_username":"test@test.be","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-09 16:33:41.017646+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
78002993-c430-4d2f-8478-c4b837002fd3	78002993-c430-4d2f-8478-c4b837002fd3	{"sub": "78002993-c430-4d2f-8478-c4b837002fd3", "email": "bastien.demeyer@ugent.be", "email_verified": true, "phone_verified": false}	email	2025-11-09 15:53:54.511266+00	2025-11-09 15:53:54.51134+00	2025-11-09 15:53:54.51134+00	589fbc66-8410-4b5a-b0c0-e80993477ba7
67d66902-5ff4-43b1-b60e-c64935084cad	67d66902-5ff4-43b1-b60e-c64935084cad	{"sub": "67d66902-5ff4-43b1-b60e-c64935084cad", "email": "test@test.be", "email_verified": false, "phone_verified": false}	email	2025-11-09 16:33:40.995186+00	2025-11-09 16:33:40.99587+00	2025-11-09 16:33:40.99587+00	3a0f6210-2b50-49a3-b980-834ee692e2e8
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
75a489f9-4d76-4595-913c-94139451c433	2025-11-09 15:59:24.473757+00	2025-11-09 15:59:24.473757+00	otp	3e71d2a8-3129-4e36-af34-2f7c432e0ec9
ea31d673-809d-4ecf-82db-c8176316193d	2025-11-09 15:59:34.686941+00	2025-11-09 15:59:34.686941+00	password	f0d6c648-03bd-4737-891c-f39ce8f2ad3d
06fa9da1-67eb-41b8-a9d1-c8a5f7462834	2025-11-09 16:00:27.553672+00	2025-11-09 16:00:27.553672+00	password	97227a31-395c-4417-b099-d341e2a0ab00
b2f68fcc-1374-4e42-bd61-2e70f7aaa035	2025-11-09 16:01:48.409273+00	2025-11-09 16:01:48.409273+00	password	367e2cd6-04be-478d-a31f-441f9af63d7e
f31a8adf-17ed-40a9-99b0-05df657538a3	2025-11-09 16:33:41.056137+00	2025-11-09 16:33:41.056137+00	password	31086f7e-f2b7-414b-b231-69da8c3b99a8
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	10	5xkoabdziyv7	78002993-c430-4d2f-8478-c4b837002fd3	f	2025-11-09 15:59:24.46151+00	2025-11-09 15:59:24.46151+00	\N	75a489f9-4d76-4595-913c-94139451c433
00000000-0000-0000-0000-000000000000	11	o6tsqkpjamuw	78002993-c430-4d2f-8478-c4b837002fd3	f	2025-11-09 15:59:34.685461+00	2025-11-09 15:59:34.685461+00	\N	ea31d673-809d-4ecf-82db-c8176316193d
00000000-0000-0000-0000-000000000000	12	6jxpcbskedbr	78002993-c430-4d2f-8478-c4b837002fd3	f	2025-11-09 16:00:27.552378+00	2025-11-09 16:00:27.552378+00	\N	06fa9da1-67eb-41b8-a9d1-c8a5f7462834
00000000-0000-0000-0000-000000000000	13	xd35pnsx5n26	78002993-c430-4d2f-8478-c4b837002fd3	f	2025-11-09 16:01:48.406921+00	2025-11-09 16:01:48.406921+00	\N	b2f68fcc-1374-4e42-bd61-2e70f7aaa035
00000000-0000-0000-0000-000000000000	14	dyktt5d4pe6j	67d66902-5ff4-43b1-b60e-c64935084cad	f	2025-11-09 16:33:41.035221+00	2025-11-09 16:33:41.035221+00	\N	f31a8adf-17ed-40a9-99b0-05df657538a3
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
75a489f9-4d76-4595-913c-94139451c433	78002993-c430-4d2f-8478-c4b837002fd3	2025-11-09 15:59:24.455692+00	2025-11-09 15:59:24.455692+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	178.117.228.174	\N	\N	\N	\N	\N
ea31d673-809d-4ecf-82db-c8176316193d	78002993-c430-4d2f-8478-c4b837002fd3	2025-11-09 15:59:34.684568+00	2025-11-09 15:59:34.684568+00	\N	aal1	\N	\N	python-httpx/0.28.1	178.117.228.174	\N	\N	\N	\N	\N
06fa9da1-67eb-41b8-a9d1-c8a5f7462834	78002993-c430-4d2f-8478-c4b837002fd3	2025-11-09 16:00:27.551416+00	2025-11-09 16:00:27.551416+00	\N	aal1	\N	\N	python-httpx/0.28.1	178.117.228.174	\N	\N	\N	\N	\N
b2f68fcc-1374-4e42-bd61-2e70f7aaa035	78002993-c430-4d2f-8478-c4b837002fd3	2025-11-09 16:01:48.404324+00	2025-11-09 16:01:48.404324+00	\N	aal1	\N	\N	python-httpx/0.28.1	178.117.228.174	\N	\N	\N	\N	\N
f31a8adf-17ed-40a9-99b0-05df657538a3	67d66902-5ff4-43b1-b60e-c64935084cad	2025-11-09 16:33:41.01943+00	2025-11-09 16:33:41.01943+00	\N	aal1	\N	\N	python-httpx/0.28.1	178.117.228.174	\N	\N	\N	\N	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	67d66902-5ff4-43b1-b60e-c64935084cad	authenticated	authenticated	test@test.be	$2a$10$Wx7yfhmc2r7Mm0xu88GG6ejyLWJo4jJlIYBXJk.mOEk0v8jpT0uEa	2025-11-09 16:33:41.009605+00	\N		\N		\N			\N	2025-11-09 16:33:41.01922+00	{"provider": "email", "providers": ["email"]}	{"sub": "67d66902-5ff4-43b1-b60e-c64935084cad", "email": "test@test.be", "email_verified": true, "phone_verified": false}	\N	2025-11-09 16:33:40.965902+00	2025-11-09 16:33:41.055532+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	78002993-c430-4d2f-8478-c4b837002fd3	authenticated	authenticated	bastien.demeyer@ugent.be	$2a$10$ZJHuKCARVaHBxXSz7./HC.K8nlDkruusdaGwz6/BFCsc9I4VidKUK	2025-11-09 15:59:24.449294+00	\N		2025-11-09 15:53:54.515534+00		\N			\N	2025-11-09 16:01:48.404186+00	{"provider": "email", "providers": ["email"]}	{"sub": "78002993-c430-4d2f-8478-c4b837002fd3", "email": "bastien.demeyer@ugent.be", "email_verified": true, "phone_verified": false}	\N	2025-11-09 15:53:54.507133+00	2025-11-09 16:01:48.408547+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: Groep; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Groep" (groep_id, created_at, groep_naam, omschrijving, owner_lid_id, invite_code, portefeuille_id, instap_nav_pct, instap_liq_pct, uitstap_nav_pct, uitstap_liq_pct, liq_per_lid) FROM stdin;
100	2025-12-17 17:22:22.237948+00	RendementTest		30	ZFGWPX	\N	0.0	0.0	0.0	0.0	f
101	2025-12-17 19:53:55.164128+00	RendementTest2		30	BPN638	\N	0.0	0.0	0.0	0.0	f
21	2025-11-26 14:56:35.703605+00	Student group		33	NX45ZY	\N	0.0	0	2.0	0.0	f
56	2025-12-09 18:38:15.295827+00	TESTEN VK		28	MF2BVB	\N	0	0	0	0	f
57	2025-12-09 18:38:21.99417+00	TESTEN VKK		28	7LZDNX	\N	0	0	0	0	f
58	2025-12-09 19:05:26.505131+00	Gerealiseerde winst		28	8ZGJFL	\N	0	0	0	0	f
59	2025-12-10 09:54:05.123772+00	test gerealiseerde wints		28	JGQPSH	\N	0	0	0	0	f
60	2025-12-10 11:48:09.108518+00	testen dividende		28	XBLLWX	\N	0	0	0	0	f
61	2025-12-10 12:15:01.531126+00	WK testen		28	37PAAR	\N	0	0	0	0	f
62	2025-12-10 14:17:05.757961+00	Club Gent		33	35FQD6	\N	0	0	0	0	f
64	2025-12-12 10:49:17.099927+00	Ugentinvestment		28	J3V9ZZ	\N	0	0	0	0	f
65	2025-12-12 10:49:21.91374+00	investopia-2		28	TZLAMH	\N	0	0	0	0	f
98	2025-12-17 13:14:15.527104+00	UGent group	Amerikaanse bedrijven	33	CNNZ3P	\N	2.0	0.0	0.0	1.0	t
48	2025-12-05 22:23:46.140543+00	Club J	technologie	29	NRUZWG	\N	2.0	0	2.0	2.0	t
31	2025-11-26 18:24:42.72155+00	Ugentinvestment		35	GWV48V	\N	0	0	0	0	f
32	2025-11-26 19:28:46.470173+00	test1		35	QBQ4QN	\N	0	0	0	0	f
39	2025-12-03 14:28:00.829345+00	TestTest		32	VMHQPA	\N	2.0	0	2.0	0.0	t
71	2025-12-14 16:05:39.421101+00	test 1		43	SLBDC5	\N	0	0	0	0	f
72	2025-12-14 16:09:52.834605+00	test 2		44	SXZX4J	\N	0	0	0	0	f
40	2025-12-03 19:03:09.899102+00	bl		36	ZP2U55	\N	0	0	0	0	f
73	2025-12-14 16:32:58.172059+00	test 3		45	AJE4MN	\N	0	0	0	0	f
74	2025-12-14 16:40:50.850069+00	test 4		46	ZQCE2H	\N	0	0	0	0	f
75	2025-12-14 16:42:32.144273+00	test 5		48	J5YCKE	\N	0	0	0	0	f
76	2025-12-14 16:44:52.643171+00	help		50	E6FXTQ	\N	0	0	0	0	f
102	2025-12-18 14:33:16.358908+00	InvestClub		32	49HLPS	\N	0.0	0.0	0.0	0.0	f
38	2025-12-01 11:46:10.392628+00	Portfolio1		30	ZCVB2A	\N	0	0	0	0	f
81	2025-12-16 10:06:47.992398+00	test		55	4QYNSM	\N	0	0	0	0	f
51	2025-12-07 11:17:00.331537+00	e		32	DXZ8JR	\N	0	10.0	30.0	0.0	t
90	2025-12-16 16:43:16.39127+00	Ugenttraders		42	4EFJL8	\N	0.0	0.0	0.0	0.0	f
91	2025-12-16 16:59:26.703195+00	Xx		42	TYSP6Q	\N	0	0	0	0	f
92	2025-12-17 06:43:38.930041+00	GrafiekenCheck		30	DUYHQS	\N	0.0	0.0	0.0	0.0	f
93	2025-12-17 06:51:09.798383+00	GrafiekenCheck2		30	U2Y6DL	\N	0.0	0.0	0.0	0.0	f
94	2025-12-17 06:51:27.993803+00	GrafiekenCheck2		30	MJHSPG	\N	0.0	0.0	0.0	0.0	f
95	2025-12-17 07:04:46.315983+00	GrafiekenCheck3		30	EH9RDP	\N	0.0	0.0	0.0	0.0	f
96	2025-12-17 07:30:42.424672+00	GrafiekenCheck4		30	SNSHD4	\N	0.0	0.0	0.0	0.0	f
97	2025-12-17 09:57:25.816925+00	Grafiekencheck 5		30	5Q33UL	\N	0.0	0.0	0.0	0.0	f
99	2025-12-17 14:10:51.029722+00	WPLCheck		30	NTAJHL	\N	0.0	0.0	0.0	0.0	f
103	2025-12-18 14:40:37.683943+00	InvestClub	InvestClub Voorbeeldgroep	65	LUHZG2	\N	2.0	0.0	1.0	0.0	t
\.


--
-- Data for Name: Kas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Kas" (kas_id, groep_id, date, amount, type, description, created_by) FROM stdin;
5	21	2025-11-28 17:36:20.684031+00	50.00	in	storting	33
8	38	2025-12-01 11:50:34.765372+00	150.00	in	Storting	30
9	38	2025-12-01 11:50:55.449431+00	25.00	out	Drankrekening	30
12	38	2025-12-01 13:53:04.728804+00	15.00	out	Pintelieren	30
13	51	2025-12-07 11:40:38.252804+00	10000000.00	in	\N	32
14	51	2025-12-07 12:28:50.612519+00	10000000.00	out	\N	32
15	21	2025-12-09 19:35:19.003353+00	50.00	in	\N	33
16	21	2025-12-10 13:48:53.811944+00	50.00	in	drank	33
17	56	2025-12-13 07:46:20.312993+00	10.00	in	\N	28
18	56	2025-12-13 07:49:54.929193+00	10.00	in	\N	28
19	56	2025-12-13 07:52:21.776413+00	10.00	in	\N	28
20	64	2025-12-13 07:59:49.984373+00	10.00	in	\N	28
21	56	2025-12-13 09:16:08.488383+00	1000.00	in	\N	28
22	56	2025-12-13 09:16:10.664807+00	1000.00	in	\N	28
23	56	2025-12-13 09:16:13.46844+00	1000.00	in	\N	28
24	56	2025-12-13 09:16:13.653343+00	1000.00	in	\N	28
25	56	2025-12-13 09:16:13.943205+00	1000.00	in	\N	28
26	56	2025-12-13 09:16:14.102352+00	1000.00	in	\N	28
27	56	2025-12-13 09:16:14.27621+00	1000.00	in	\N	28
28	56	2025-12-13 09:16:27.258535+00	10000.00	in	\N	28
29	56	2025-12-13 09:16:27.413883+00	10000.00	in	\N	28
30	56	2025-12-13 09:16:27.69563+00	10000.00	in	\N	28
31	56	2025-12-13 09:16:27.869079+00	10000.00	in	\N	28
32	56	2025-12-13 09:16:32.133677+00	10000.00	in	\N	28
33	56	2025-12-13 09:16:32.307454+00	10000.00	in	\N	28
34	56	2025-12-13 09:16:32.465463+00	10000.00	in	\N	28
35	56	2025-12-13 09:18:09.365384+00	500.00	in	\N	28
36	56	2025-12-13 09:18:10.044436+00	500.00	in	\N	28
37	56	2025-12-13 09:18:10.053201+00	500.00	in	\N	28
38	56	2025-12-13 09:18:27.203651+00	500.00	in	\N	28
39	56	2025-12-13 09:18:27.386544+00	500.00	in	\N	28
40	56	2025-12-13 09:18:27.555656+00	500.00	in	\N	28
41	56	2025-12-13 09:18:27.604496+00	500.00	in	\N	28
42	56	2025-12-13 09:18:27.998777+00	500.00	in	\N	28
43	56	2025-12-13 09:18:28.654765+00	500.00	in	\N	28
44	56	2025-12-13 09:18:28.946198+00	500.00	in	\N	28
45	56	2025-12-13 09:18:29.351056+00	500.00	in	\N	28
46	56	2025-12-13 09:18:29.403022+00	500.00	in	\N	28
47	56	2025-12-13 09:18:29.656687+00	500.00	in	\N	28
48	56	2025-12-13 09:20:35.945488+00	5000.00	in	\N	28
49	56	2025-12-13 09:20:37.737657+00	5000.00	in	\N	28
50	56	2025-12-13 09:20:38.262456+00	5000.00	in	\N	28
51	56	2025-12-13 09:20:41.261753+00	5000.00	in	\N	28
52	56	2025-12-13 09:20:41.28409+00	5000.00	in	\N	28
53	56	2025-12-13 09:24:50.697877+00	500.00	in	\N	28
54	56	2025-12-13 09:26:21.911849+00	6000.00	in	\N	28
55	65	2025-12-13 09:28:06.358662+00	1000.00	in	\N	28
56	65	2025-12-13 09:29:34.734512+00	5000.00	in	\N	28
57	65	2025-12-13 09:31:38.542957+00	500.00	in	\N	28
58	56	2025-12-13 09:33:53.876396+00	5000.00	in	\N	28
59	56	2025-12-13 09:34:05.617626+00	5515110.00	in	\N	28
60	65	2025-12-13 09:36:39.769918+00	500.00	out	\N	28
61	65	2025-12-13 09:40:37.080029+00	22.00	in	\N	28
62	56	2025-12-13 09:42:33.369401+00	25.00	in	\N	28
63	56	2025-12-13 09:47:47.458988+00	10.00	in	\N	28
69	90	2025-12-16 16:57:53.377851+00	200.00	in	\N	42
70	90	2025-12-16 17:08:36.210063+00	20.00	out	\N	42
71	90	2025-12-16 17:18:16.681226+00	100.00	out	storintinggg	42
72	90	2025-12-16 17:19:35.510425+00	20.00	out	fe	42
73	90	2025-12-16 17:21:36.987379+00	20.00	in	feest	42
74	90	2025-12-16 17:21:46.745329+00	20.00	out	feest	42
75	90	2025-12-16 17:22:16.164748+00	20.00	in	feest	42
76	90	2025-12-16 17:25:18.663657+00	20.00	in	dfuebgge	42
77	90	2025-12-16 17:26:27.550175+00	10.00	in	yyvy	42
78	90	2025-12-16 17:26:38.532742+00	100.00	out	\N	42
79	98	2025-12-18 11:04:05.111385+00	50.00	in	\N	33
80	98	2025-12-18 11:04:21.489936+00	25.00	in	drankrekening	33
81	98	2025-12-18 11:04:36.596755+00	50.00	out	\N	33
82	98	2025-12-18 11:04:45.015741+00	50.00	in	\N	33
83	39	2025-12-18 11:19:58.794076+00	10000.00	in	\N	32
84	39	2025-12-18 11:22:53.354759+00	10000.00	out	\N	32
85	39	2025-12-18 11:57:13.467361+00	50000.00	in	\N	32
86	98	2025-12-18 14:51:50.355823+00	50.00	out	restaurant	33
87	103	2025-12-18 14:53:05.469902+00	7000.00	in	\N	65
88	98	2025-12-18 16:56:36.883255+00	20.00	out	drankrekening	33
\.


--
-- Data for Name: Leden; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Leden" (ledenid, created_at, "GSM", voornaam, achternaam, email) FROM stdin;
28	2025-11-25 11:02:24.732158+00	45885	bastien	De Meyer	bastien.demeyer@ugent.be
29	2025-11-25 11:14:52.403155+00	45	hoho	hoho	hoho@gmail.com
30	2025-11-25 11:15:10.530264+00	472218230	Joran	Van Bockhaven	joranvanbockhaven@gmail.com
31	2025-11-25 11:15:27.029452+00	111	flo	ghe	flo.gheysen@gmail.com
32	2025-11-25 11:15:43.351831+00	0	Antoon	Hendrickx	antoonhendrickx@gmail.com
33	2025-11-26 14:56:16.968229+00	5445	Florence	gheysen	florence.gheysen@ugent.be
34	2025-11-26 16:21:16.079839+00	0	testvw	testvw	testverwijderen@gmail.com
35	2025-11-26 18:23:18.094531+00	155	test	test	test@test.be
36	2025-12-03 19:01:48.136747+00	1234567890	Test	User	test@example.com
38	2025-12-06 14:28:13.995774+00	2555	fl	eezz	fl@fefe.com
39	2025-12-07 11:46:28.937165+00	0	t	t	test2222@outlook.com
40	2025-12-07 13:19:52.552255+00	497825206	Danny	Van Liedekerke	beursboy@gmail.com
41	2025-12-08 16:41:55.162056+00	123456789	Cyrile	Lambrecht	cyrilelambrecht@gmail.com
42	2025-12-14 07:52:13.577532+00	486444287	Bastien	De Meyer	bastiendemeyer@outlook.be
43	2025-12-14 16:05:22.970921+00	46655588	florence	eezz	hihihih@blabla
44	2025-12-14 16:09:39.830383+00	494663322	hey	hoi	hallo@hey.be
45	2025-12-14 16:32:46.185891+00	5555888	haahhha	hehheh	hahahahahha@hehe.com
46	2025-12-14 16:40:39.411917+00	123456	ha	bla	haa@blaa.com
47	2025-12-14 16:40:39.602703+00	123456	ha	bla	haa@blaa.com
48	2025-12-14 16:42:19.964617+00	469985	f	f	hh@fff.eb
49	2025-12-14 16:42:20.16575+00	469985	f	f	hh@fff.eb
50	2025-12-14 16:44:39.059271+00	0494663322	d	d	bbb@blbbl.com
51	2025-12-14 16:44:39.333832+00	494663322	d	d	bbb@blbbl.com
37	2025-12-05 22:25:23.137098+00	4	j	vl	jvl@gmail.com
52	2025-12-16 09:45:41.260378+00	471881535	Jinte	Van Liedekerke	jinte.vanliedekerke@gmail.com
53	2025-12-16 10:04:51.251804+00	0123	jaj	ss	ahzhh@nddne.com
54	2025-12-16 10:05:21.254439+00	023458	hehe	hoho	hahahahahhah@blalb.com
55	2025-12-16 10:06:30.071141+00	04566998	flo	gh	flo@gh.com
56	2025-12-16 10:08:06.372751+00	471881535	j	vli	jvli@gmail.com
57	2025-12-16 22:36:45.930295+00	0471881535	jj	x	jj@gmail.com
58	2025-12-17 13:18:12.354343+00	0471881535	Jinte	Van Liedekerke	jinte.vanliedekerke@ugent.be
59	2025-12-17 20:04:04.977476+00	0472218230	Joran	Van Bockhaven	joran.vanbockhaven@ugent.be
60	2025-12-17 23:27:42.697942+00	0477098509	Fran	Bogaert	fran.bogaert@gmail.com
61	2025-12-18 08:16:34.226808+00	0474216087	Ijin	Vandewiele	ijinvdw@gmail.com
62	2025-12-18 14:34:31.594315+00	04	Bart	P	Bart@outlook.com
63	2025-12-18 14:35:14.038389+00	04	Johan	V	Johan@outlook.com
64	2025-12-18 14:38:43.451694+00	04	Steven	D	steven@outlook.com
65	2025-12-18 14:39:48.723788+00	04	Bart	C	bart@outlook.com
66	2025-12-18 14:43:44.363872+00	04	Johan	V	johan@outlook.com
\.


--
-- Data for Name: Liquiditeit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Liquiditeit" (id, groep_id, datum, bedrag, omschrijving, created_at) FROM stdin;
1	39	2025-12-09	10.0		2025-12-09 15:27:51.211825+00
2	39	2025-12-09	20.0	Toevoeging	2025-12-09 15:38:58.834506+00
3	39	2025-12-09	-10.0	Bedrag verwijderd	2025-12-09 15:39:05.761806+00
4	39	2025-12-09	30.0	Toevoeging	2025-12-09 15:39:12.835902+00
5	39	2025-12-09	5.0	Toevoeging	2025-12-09 15:42:11.736251+00
6	39	2025-12-09	10.0		2025-12-09 15:44:01.543299+00
7	39	2025-12-09	10.0		2025-12-09 16:25:54.467089+00
8	39	2025-12-09	10.0		2025-12-09 16:27:50.07207+00
9	39	2025-12-09	4.0	Test	2025-12-09 16:28:04.065813+00
10	51	2025-12-09	100.0		2025-12-09 16:28:34.35612+00
12	51	2025-12-09	10.0		2025-12-09 17:23:19.141654+00
14	51	2025-12-09	20.0	Test	2025-12-09 17:25:49.149594+00
15	51	2025-12-09	100.0		2025-12-09 17:38:34.538626+00
16	62	2025-12-11	50000.0		2025-12-11 20:32:11.360459+00
19	48	2025-12-14	10.0		2025-12-14 10:48:43.34099+00
20	48	2025-12-14	10.0		2025-12-14 11:11:34.952872+00
22	98	2025-12-18	500.0		2025-12-18 11:00:27.95937+00
23	90	2025-12-18	10.0		2025-12-18 11:04:57.375861+00
24	48	2025-12-18	10.0		2025-12-18 11:05:55.810067+00
25	39	2025-12-18	100.0		2025-12-18 11:45:54.709388+00
26	39	2025-12-18	11.0		2025-12-18 11:48:51.313742+00
27	103	2025-12-18	5000.0		2025-12-18 14:55:50.303604+00
\.


--
-- Data for Name: Portefeuille; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Portefeuille" (port_id, ticker, quantity, avg_price, groep_id, transactiekost) FROM stdin;
194	AMZN	5	229.60776	62	2.0012007204322595
177	CASH	0	0	57	0
54	CASH	0	0	31	0
195	MRK	10	99.228455	62	4.709418837675396
188	CASH	0	0	61	0
55	CASH	0	0	32	0
190	CASH	0	0	62	0
62	TSLA	0	441.7	21	5
113	LMT	15	457.86	38	15
183	CASH	0	0	59	0
184	IWDA.AS	8	111.3	59	118
199	IWDA.AS	10	100	65	0
115	CASH	0	0	40	0
187	VEUR.MI	0	252.36	60	104.39999999999998
186	CASH	0	0	60	0
218	CASH	0	0	73	0
179	CASH	0	0	58	0
198	CASH	0	0	65	0
219	CASH	0	0	74	0
110	COLR.BR	30	31.4	38	7
162	CASH	0	0	51	0
197	CASH	0	0	64	0
220	CASH	0	0	75	0
164	TEXF.BR	74	33.4	48	16.15000000000009
176	CASH	0	0	56	0
231	CASH	0	0	81	0
221	CASH	0	0	76	0
216	CASH	0	0	71	0
217	CASH	0	0	72	0
181	AD	10	42.35102	38	6.449393756986843
182	VTI	3	289.1306	38	78.51921919339577
222	META	1	554.0947	21	0
58	CASH	177.04407	1	21	0
268	CASH	0	0	99	0
253	VEUR.MI	33	43.28	90	0
275	CASH	20725.041	0	101	0
254	UIMI.AS	4	107.42	90	39.75
269	AAPL	10	234.31982	38	0
292	AAPL	17	229.523	103	0
270	FSLR	3	102.08422	38	0
108	CASH	2350.5474	0	38	0
293	KIM	90	17.393526	103	0
255	AAPL	17	233.69075	48	282.21427963577577
256	CASH	10000	0	92	0
257	CASH	0	0	93	0
258	CASH	10000	0	94	0
260	AAPL	50	161.70456	95	9.512032721392563
252	IWDA.AS	78	2.8023076	90	0
251	CASH	325.96	0	90	0
261	MSFT	20	361.42285	95	9.511128019783147
259	CASH	4667.3315	0	95	0
263	AAPL	45	161.79689	96	0
262	CASH	12894.535	0	96	0
264	AAPL	10	150	56	0
265	CASH	0	0	97	0
191	AMZN	5	227.92	21	0
294	PODD	28	249.98723	103	0
266	AAPL	4	234.18898	21	0
290	CASH	3432.5576	0	103	0
286	SLB	20	30.527842	98	0
285	MSFT	5	483.9563	98	5.311153422186774
157	NVDA	30	145.55518	48	0
287	MRK	15	68.23028	98	0
279	MSFT	15	405.41553	48	305.00681198910064
273	ASML	5	553.19147	100	12
272	AAPL	80	58.389816	100	13.738779996336325
280	COLR.BR	10	31.5	48	0
274	MSFT	40	173.3893	100	16.42635517430188
271	CASH	90823.1	0	100	0
276	AAPL	100	157.2618	101	23.12673450508788
170	5E1.F	7	34.35	48	0
150	CASH	8857.76	0	48	0
277	MSFT	25	389.42975	101	20
288	AAPL	10	231.8267	39	0
278	LMT	10	445.1017	101	48.84222368050947
114	CASH	17681.732	0	39	0
282	AMZN	6	188.63597	98	0
289	CASH	0	0	102	0
283	NKE	10	66.28658	98	3.1281533804238375
284	AAPL	4	231.76741	98	0
281	TSLA	5	490.55112	98	2.1543086172345602
291	MSFT	10	410.0452	103	0
267	CASH	1679.5201	0	98	0
\.


--
-- Data for Name: Transacties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Transacties" (transactie_id, datum_tr, type, ticker, aantal, koers, munt, portefeuille_id, wisselkoers) FROM stdin;
2	2025-11-30	BUY	VEUR.MI	10.0	44.63	EUR	\N	\N
3	2025-11-30	BUY	IWDA.AS	10.0	111.5	EUR	\N	\N
4	2025-11-30	SELL	AAPL	3.0	278.85	EUR	\N	\N
6	2025-11-30	BUY	NVDA	2.0	177.0	EUR	\N	\N
9	2025-11-30	BUY	AAPL	5.0	278.85	EUR	\N	\N
7	2025-11-30	BUY	MSFT	2.0	492.01	EUR	\N	\N
8	2025-11-30	FEE	MSFT	1.0	5.0	EUR	\N	\N
10	2025-11-30	SELL	TSLA	2.0	430.17	EUR	\N	\N
12	2025-11-30	BUY	IWDA.AS	1.0	111.4	EUR	\N	\N
18	2025-11-30	BUY	COLR.VI	5.0	33.06	EUR	\N	\N
19	2025-11-30	FEE	COLR.VI	1.0	5.0	EUR	\N	\N
33	2025-12-01	BUY	COLR.BR	10.0	33.4	EUR	110	\N
34	2025-12-01	FEE	COLR.BR	1.0	5.0	EUR	110	\N
39	2025-12-01	BUY	LMT	20.0	457.86	EUR	113	\N
40	2025-12-01	FEE	LMT	1.0	5.0	EUR	113	\N
45	2025-12-03	SELL	TSLA	1.0	428.65	EUR	62	\N
46	2025-12-03	BUY	TSLA	5.0	441.7	USD	62	\N
55	2025-12-04	BUY	COLR.VI	2.0	10.0	EUR	\N	\N
56	2025-12-04	BUY	COLR.VI	2.0	10.0	EUR	\N	\N
57	2025-12-04	FEE	COLR.VI	1.0	55.0	EUR	\N	\N
58	2025-12-04	SELL	COLR.VI	4.0	10.0	EUR	\N	\N
53	2025-12-04	BUY	AAPL	10.0	10.0	USD	\N	\N
54	2025-12-04	SELL	AAPL	10.0	500.0	EUR	\N	\N
59	2025-12-04	BUY	AAPL	1.0	281.58	USD	\N	\N
60	2025-12-04	FEE	AAPL	1.0	100.0	USD	\N	\N
61	2025-12-04	BUY	AAPL	1.0	281.58	EUR	\N	\N
62	2025-12-04	BUY	AAPL	1.0	281.58	EUR	\N	\N
63	2025-12-04	FEE	AAPL	1.0	100.0	EUR	\N	\N
64	2025-12-04	SELL	AAPL	1.0	281.58	EUR	\N	\N
65	2025-12-04	FEE	AAPL	1.0	100.0	EUR	\N	\N
66	2025-12-04	SELL	IWDA.AS	10.0	111.18	EUR	\N	\N
67	2025-12-04	FEE	IWDA.AS	1.0	10.0	EUR	\N	\N
73	2025-12-04	BUY	SJ4A.F	74.0	33.4	EUR	\N	\N
74	2025-12-04	FEE	SJ4A.F	1.0	16.15000000000009	EUR	\N	\N
76	2025-12-04	BUY	AAPL	2.0	280.47	USD	\N	\N
68	2025-12-04	BUY	IWDA.AS	78.0	100.26	EUR	\N	\N
69	2025-12-04	FEE	IWDA.AS	1.0	47.0	EUR	\N	\N
70	2025-12-04	SELL	IWDA.AS	78.0	111.27	EUR	\N	\N
75	2025-12-04	BUY	IWDA.AS	20.0	111.26	EUR	\N	\N
71	2025-12-04	BUY	COLR.VI	5.0	33.22	EUR	\N	\N
72	2025-12-04	FEE	COLR.VI	1.0	20.0	EUR	\N	\N
87	2025-12-04	BUY	META	10.0	10.0	USD	\N	\N
90	2025-12-04	BUY	VEUR.MI	2.0	50.0	EUR	\N	\N
91	2005-01-03	BUY	VEUR.MI	5.0	20.0	EUR	\N	\N
92	2025-12-04	BUY	AAPL	5.0	10.0	USD	\N	\N
88	2025-12-04	SELL	NVDA	2.0	20.0	EUR	\N	\N
89	2025-12-04	FEE	NVDA	1.0	2.0	EUR	\N	\N
93	5222-03-02	BUY	NVDA	5.0	2.0	USD	\N	\N
94	5222-03-02	FEE	NVDA	1.0	2.0	USD	\N	\N
47	2025-12-04	BUY	AAPL	10.0	10.0	USD	\N	\N
48	2025-12-04	BUY	AAPL	2.0	284.15	USD	\N	\N
35	2025-12-01	BUY	VEUR.MI	1.0	44.47	EUR	\N	\N
36	2025-12-01	FEE	VEUR.MI	1.0	5.0	EUR	\N	\N
37	2025-12-01	BUY	ORCL	2.0	201.95	EUR	\N	\N
38	2025-12-01	FEE	ORCL	1.0	5.0	EUR	\N	\N
23	2025-11-30	BUY	COLR.VI	10.0	33.06	EUR	\N	\N
24	2025-11-30	FEE	COLR.VI	1.0	5.0	EUR	\N	\N
11	2025-11-30	BUY	NVDA	2.0	177.0	EUR	\N	\N
13	2025-11-30	BUY	NVDA	2.0	177.0	EUR	\N	\N
16	2025-11-30	SELL	NVDA	2.0	177.0	EUR	\N	\N
17	2025-11-30	FEE	NVDA	1.0	1.0	EUR	\N	\N
22	2025-11-30	SELL	NVDA	2.0	177.0	EUR	\N	\N
26	2025-11-30	BUY	NVDA	2.0	177.0	EUR	\N	\N
27	2025-11-30	SELL	NVDA	2.0	177.0	EUR	\N	\N
41	2025-12-01	BUY	NVDA	1.0	179.33	USD	\N	\N
42	2025-12-01	BUY	NVDA	1.0	178.97	USD	\N	\N
25	2025-11-30	BUY	IWDA.AS	2.0	111.4	EUR	\N	\N
28	2025-11-30	BUY	IWDA.AS	1.0	111.4	EUR	\N	\N
43	2025-12-03	BUY	IWDA.AS	2.0	110.53	EUR	\N	\N
49	2025-12-04	BUY	META	10.0	10.0	USD	\N	\N
44	2025-12-03	SELL	AAPL	1.0	277.55	EUR	\N	\N
52	2025-12-04	BUY	AAPL	1.0	281.7	USD	\N	\N
29	2025-12-01	BUY	AAPL	20.0	278.85	EUR	\N	\N
30	2025-12-01	FEE	AAPL	1.0	25.0	EUR	\N	\N
31	2025-12-01	BUY	AAPL	10.0	278.85	EUR	\N	\N
32	2025-12-01	FEE	AAPL	1.0	15.0	EUR	\N	\N
50	2025-12-04	FEE	META	1.0	55.0	USD	\N	\N
51	2025-12-04	SELL	META	5.0	665.98	EUR	\N	\N
115	2025-12-05	BUY	AAPL	1.0	20.0	USD	\N	\N
114	2025-12-05	BUY	SNT.WA	5.0	270.4	PLN	\N	\N
105	2025-12-04	BUY	AAPL	5.0	20.0	USD	\N	\N
106	2025-12-04	BUY	AAPL	5.0	280.3	USD	\N	\N
109	2025-12-05	SELL	AAPL	10.0	280.22	EUR	\N	\N
110	2025-12-05	FEE	AAPL	1.0	2.0	EUR	\N	\N
111	2025-12-05	BUY	AAPL	5.0	279.39	USD	\N	\N
112	2025-12-05	FEE	AAPL	1.0	3.050000000000182	USD	\N	\N
107	2025-12-05	BUY	NVDA	5.0	183.38	USD	\N	\N
108	2025-12-05	SELL	NVDA	5.0	183.91	EUR	\N	\N
113	2025-12-05	BUY	NVDA	1.0	10.0	USD	\N	\N
97	2005-01-03	BUY	VEUR.MI	5.0	44.86	EUR	\N	\N
98	2005-01-03	FEE	VEUR.MI	1.0	24.30000000000001	EUR	\N	\N
95	2025-12-04	BUY	AAPL	5.0	30.0	USD	\N	\N
96	2025-12-04	FEE	AAPL	1.0	50.0	USD	\N	\N
99	2025-12-04	BUY	AAPL	2.0	280.05	USD	\N	\N
100	2025-12-04	FEE	AAPL	1.0	0.10000000000002274	USD	\N	\N
101	2025-12-04	BUY	AAPL	2.0	278.96	USD	\N	\N
102	2025-12-04	FEE	AAPL	1.0	42.08000000000004	USD	\N	\N
103	2025-12-04	BUY	AAPL	5.0	280.09	USD	\N	\N
104	2025-12-04	FEE	AAPL	1.0	0.00000000000022737367544323206	USD	\N	\N
147	2025-12-06	BUY	NVDA	30.0	182.41	USD	157	\N
148	2025-12-06	FEE	NVDA	1.0	206.69999999999982	USD	157	\N
166	2025-12-07	SELL	LMT	5.0	500.0	EUR	113	\N
167	2025-12-07	FEE	LMT	1.0	10.0	EUR	113	\N
168	2025-12-07	BUY	COLR.BR	20.0	30.4	EUR	110	\N
169	2025-12-07	FEE	COLR.BR	1.0	2.0	EUR	110	\N
170	2025-06-28	BUY	TEXF.BR	74.0	33.4	EUR	164	\N
171	2025-06-28	FEE	TEXF.BR	1.0	16.15000000000009	EUR	164	\N
182	2025-12-08	BUY	5E1.F	10.0	34.35	EUR	170	\N
183	2025-12-08	FEE	5E1.F	1.0	6.5	EUR	170	\N
132	2025-03-05	BUY	SNT.WA	46.0	221.0	PLN	\N	\N
133	2025-03-05	FEE	SNT.WA	1.0	66.70999999999913	PLN	\N	\N
127	2025-12-06	BUY	AAPL	1.0	278.78	USD	\N	\N
128	2025-12-06	BUY	AAPL	1.0	278.78	USD	\N	\N
123	2025-12-05	BUY	SNT.WA	2.0	273.0	PLN	\N	\N
124	2025-12-05	FEE	SNT.WA	1.0	54.0	PLN	\N	\N
125	2025-12-05	BUY	SNT.WA	2.0	273.0	PLN	\N	\N
126	2025-12-05	FEE	SNT.WA	1.0	54.0	PLN	\N	\N
117	2025-12-05	BUY	NVDA	2.0	10.0	USD	\N	\N
118	2025-12-05	BUY	NVDA	1.0	10.0	USD	\N	\N
116	2025-12-05	BUY	AAPL	1.0	20.0	USD	\N	\N
119	2025-12-05	BUY	AAPL	20.0	10.0	USD	\N	\N
120	2025-12-05	BUY	AAPL	2.0	20.0	USD	\N	\N
149	2025-12-07	BUY	AAPL	1.0	278.78	USD	\N	\N
150	2025-12-07	FEE	AAPL	1.0	21.220000000000027	USD	\N	\N
121	2025-12-05	BUY	IWDA.AS	2.0	111.69	EUR	\N	\N
122	2025-12-05	FEE	IWDA.AS	1.0	76.62	EUR	\N	\N
151	2025-12-07	SELL	IWDA.AS	1.0	111.69	EUR	\N	\N
152	2025-12-07	FEE	IWDA.AS	1.0	2.0	EUR	\N	\N
157	2025-12-07	BUY	IWDA.AS	1.0	100.0	EUR	\N	\N
158	2025-12-07	BUY	IWDA.AS	1.0	100.0	EUR	\N	\N
159	2025-12-07	FEE	IWDA.AS	1.0	20.0	EUR	\N	\N
153	2025-12-07	BUY	COLR.VI	1.0	33.5	EUR	\N	\N
154	2025-12-07	FEE	COLR.VI	1.0	1.5	EUR	\N	\N
160	2025-12-07	BUY	COLR.VI	1.0	33.5	EUR	\N	\N
161	2025-12-07	FEE	COLR.VI	1.0	1.5	EUR	\N	\N
172	2025-12-08	BUY	MSF.DE	1.0	400.0	EUR	\N	\N
173	2025-12-08	FEE	MSF.DE	1.0	5.0	EUR	\N	\N
155	2025-12-07	BUY	AAPL	2.0	278.78	USD	\N	\N
156	2025-12-07	FEE	AAPL	1.0	42.440000000000055	USD	\N	\N
174	2025-12-08	SELL	AAPL	2.0	300.0	USD	\N	\N
175	2025-08-02	BUY	EVO.ST	25.0	600.0	SEK	\N	\N
176	2025-12-08	SELL	EVO.ST	23.0	770.0	SEK	\N	\N
177	2025-12-08	FEE	EVO.ST	1.0	219.0	SEK	\N	\N
178	2025-12-08	BUY	EVO.ST	23.0	600.0	SEK	\N	\N
179	2025-12-08	SELL	EVO.ST	23.0	770.0	SEK	\N	\N
143	2025-12-02	BUY	AAPL	30.0	1.0	EUR	\N	\N
144	2025-12-02	FEE	AAPL	1.0	493.4	EUR	\N	\N
145	2025-12-04	BUY	AAPL	20.0	278.78	USD	\N	\N
146	2025-12-04	FEE	AAPL	1.0	764.4000000000005	USD	\N	\N
162	2025-12-07	BUY	AAPL	10.0	278.78	USD	\N	\N
163	2025-12-07	FEE	AAPL	1.0	7212.200000000001	USD	\N	\N
164	2025-12-07	BUY	AAPL	5.0	278.78	USD	\N	\N
165	2025-12-07	FEE	AAPL	1.0	0.00000000000022737367544323206	USD	\N	\N
184	2025-12-09	BUY	IWDA.AS	10.0	100.0	EUR	\N	\N
185	2025-12-09	SELL	IWDA.AS	10.0	111.64	EUR	\N	\N
186	2025-12-09	FEE	IWDA.AS	1.0	6.400000000000091	EUR	\N	\N
189	2025-12-09	BUY	IWDA.AS	100.0	20.0	EUR	\N	\N
190	2025-12-09	BUY	IWDA.AS	50.0	10.0	EUR	\N	\N
187	2025-12-09	BUY	AAPL	10.0	278.2	USD	\N	\N
188	2025-12-09	FEE	AAPL	1.0	18.0	USD	\N	\N
191	2025-12-09	BUY	AAPL	10.0	278.5	USD	\N	\N
192	2025-12-09	FEE	AAPL	1.0	115.0	USD	\N	\N
129	2025-12-06	FEE	AAPL	1.0	1.2200000000000273	USD	\N	\N
130	2025-12-06	BUY	AAPL	5.0	278.78	USD	\N	\N
131	2025-12-06	FEE	AAPL	1.0	0.00000000000022737367544323206	USD	\N	\N
134	2025-12-06	BUY	AAPL	6.0	278.78	USD	\N	\N
135	2025-12-06	FEE	AAPL	1.0	327.32000000000016	USD	\N	\N
136	2025-12-06	BUY	TRAIN-B.ST	1.0	20.4	SEK	\N	\N
137	2025-12-06	FEE	TRAIN-B.ST	1.0	0.6000000000000014	SEK	\N	\N
138	2025-12-06	BUY	TRAIN-B.ST	1.0	20.4	SEK	\N	\N
139	2025-12-06	BUY	TRAIN-B.ST	1.0	20.4	SEK	\N	\N
140	2025-12-06	FEE	TRAIN-B.ST	1.0	29.6	SEK	\N	\N
141	2025-12-06	BUY	005930.KS	1.0	108400.0	KRW	\N	\N
142	2025-12-06	FEE	005930.KS	1.0	200.0	KRW	\N	\N
180	2025-12-08	BUY	IWDA.AS	5.0	111.67	EUR	\N	\N
181	2025-12-08	FEE	IWDA.AS	1.0	21.649999999999977	EUR	\N	\N
193	2025-12-09	BUY	AAPL	100.0	300.0	USD	\N	\N
194	2025-12-09	SELL	AAPL	100.0	300.0	USD	\N	\N
195	2025-12-09	BUY	AAPL	10.0	10.0	USD	\N	\N
196	2025-12-09	FEE	AAPL	1.0	6197.99	USD	\N	\N
197	2025-12-09	BUY	AAPL	1.0	10.0	USD	\N	\N
198	2025-12-09	FEE	AAPL	1.0	1.0	USD	\N	\N
209	2025-12-10	BUY	AD	10.0	49.25	USD	181	\N
210	2025-12-10	FEE	AD	1.0	7.5	USD	181	\N
211	2025-12-10	BUY	VTI	3.0	336.23	USD	182	\N
212	2025-12-10	FEE	VTI	1.0	91.30999999999995	USD	182	\N
213	2025-12-10	BUY	IWDA.AS	10.0	100.0	EUR	184	\N
214	2025-12-10	SELL	IWDA.AS	10.0	111.3	EUR	184	\N
215	2025-12-10	BUY	IWDA.AS	10.0	111.3	EUR	184	\N
216	2025-12-10	FEE	IWDA.AS	1.0	113.0	EUR	184	\N
217	2025-12-10	SELL	IWDA.AS	2.0	200.0	EUR	184	\N
218	2025-12-10	FEE	IWDA.AS	1.0	5.0	EUR	184	\N
226	2025-12-10	DIVIDEND	IWDA.AS	5.0	100.0	EUR	184	\N
227	2025-12-10	BUY	VEUR.MI	100.0	44.71	EUR	187	\N
228	2025-12-10	DIVIDEND	VEUR.MI	20.0	10.0	EUR	187	\N
229	2025-12-10	DIVIDEND	VEUR.MI	200.0	10.0	EUR	187	\N
230	2025-12-10	DIVIDEND	VEUR.MI	1000.0	10.0	EUR	187	\N
231	2025-12-10	DIVIDEND	VEUR.MI	10.0	200.0	EUR	187	\N
232	2025-12-10	DIVIDEND	VEUR.MI	200.0	10.0	EUR	187	\N
233	2025-12-10	SELL	VEUR.MI	100.0	46.0	EUR	187	\N
234	2025-12-10	BUY	VEUR.MI	10.0	460.0	EUR	187	\N
235	2025-12-10	FEE	VEUR.MI	1.0	100.0	EUR	187	\N
236	2025-12-10	BUY	VEUR.MI	10.0	44.72	EUR	187	\N
237	2025-12-10	SELL	VEUR.MI	20.0	44.72	EUR	187	\N
238	2025-12-10	FEE	VEUR.MI	1.0	4.399999999999977	EUR	187	\N
244	2025-12-10	BUY	AMZN	10.0	227.92	USD	191	\N
245	2025-12-10	FEE	AMZN	1.0	0.8000000000001819	USD	191	\N
246	2025-12-10	SELL	TSLA	5.0	445.17	EUR	62	\N
249	2025-12-11	BUY	AMZN	5.0	229.47	USD	194	\N
250	2025-12-11	FEE	AMZN	1.0	2.0	USD	194	\N
251	2025-12-11	BUY	MRK	10.0	99.03	USD	195	\N
252	2025-12-11	FEE	MRK	1.0	4.7000000000000455	USD	195	\N
257	2025-12-12	BUY	IWDA.AS	10.0	100.0	EUR	199	\N
305	2025-12-13	DIVIDEND	CASH	1	500.0	EUR	176	\N
306	2025-12-13	DIVIDEND	CASH	1	6000.0	EUR	176	\N
307	2025-12-13	DIVIDEND	CASH	1	1000.0	EUR	198	\N
308	2025-12-13	DIVIDEND	CASH	1	5000.0	EUR	198	\N
309	2025-12-13	DIVIDEND	CASH	1	500.0	EUR	198	\N
310	2025-12-13	TRANSFER	CASH	1	5000.0	EUR	176	\N
247	2025-12-10	SELL	AAPL	3.0	278.15	EUR	\N	\N
199	2025-12-09	BUY	AAPL	100.0	10.0	USD	\N	\N
311	2025-12-13	TRANSFER	CASH	1	5515110.0	EUR	176	\N
312	2025-12-13	TRANSFER	CASH	1	-500.0	EUR	198	\N
313	2025-12-13	TRANSFER	CASH	1	22.0	EUR	198	\N
314	2025-12-13	TRANSFER	CASH	1	25.0	EUR	176	\N
315	2025-12-13	TRANSFER	CASH	1	40.0	EUR	176	\N
359	2025-12-15	BUY	META	1.0	651.56	USD	222	\N
253	2025-12-12	BUY	COLRUYT	1.0	53.72	EUR	\N	\N
254	2025-12-12	FEE	COLRUYT	1.0	6.280000000000001	EUR	\N	\N
360	2025-12-16	TRANSFER	CASH	1	10000.0	EUR	\N	\N
361	2025-12-16	BUY	AAPL	10.0	274.11	USD	\N	\N
362	2025-12-16	FEE	AAPL	1.0	58.899999999999636	USD	\N	\N
363	2025-12-16	SELL	AAPL	1.0	290.0	EUR	\N	\N
364	2025-12-16	SELL	AAPL	1.0	290.0	EUR	\N	\N
365	2025-12-16	FEE	AAPL	1.0	45.0	EUR	\N	\N
367	2025-12-16	BUY	TSLA	1.0	475.31	USD	\N	\N
368	2025-12-16	FEE	TSLA	1.0	24.689999999999998	USD	\N	\N
366	2025-12-16	TRANSFER	CASH	1	10000.0	EUR	\N	\N
370	2025-12-16	BUY	AAPL	10.0	150.0	USD	\N	\N
369	2025-12-16	TRANSFER	CASH	1	10000.0	EUR	\N	\N
358	2025-12-15	SELL	AAPL	3.0	278.78	EUR	\N	\N
200	2025-12-09	SELL	AAPL	100.0	20.0	USD	\N	\N
201	2025-12-09	BUY	AAPL	10.0	100.0	USD	\N	\N
320	2025-12-14	BUY	IWDA.AS	10.0	110.29	EUR	\N	\N
321	2025-12-14	FEE	IWDA.AS	1.0	17.09999999999991	EUR	\N	\N
318	2025-12-14	TRANSFER	CASH	1	1000.0	EUR	\N	\N
319	2025-12-14	TRANSFER	CASH	1	1000.0	EUR	\N	\N
328	2025-12-14	TRANSFER	CASH	1	200.0	EUR	\N	\N
329	2025-12-14	BUY	AAPL.BA	10.0	21040.0	ARS	\N	\N
330	2025-12-14	BUY	AAPL.BA	1.0	10.0	ARS	\N	\N
323	2025-12-14	BUY	IWDA.AS	8.0	110.29	EUR	\N	\N
324	2025-12-14	FEE	IWDA.AS	1.0	17.67999999999995	EUR	\N	\N
325	2025-12-14	SELL	IWDA.AS	2.0	120.0	EUR	\N	\N
326	2025-12-14	FEE	IWDA.AS	1.0	20.0	EUR	\N	\N
322	2025-12-14	TRANSFER	CASH	1	1000.0	EUR	\N	\N
332	2025-12-14	BUY	IWDA.AS	10.0	110.29	EUR	\N	\N
333	2025-12-14	FEE	IWDA.AS	1.0	97.09999999999991	EUR	\N	\N
331	2025-12-14	TRANSFER	CASH	1	10000.0	EUR	\N	\N
336	2025-01-10	BUY	MSFT	5.0	478.53	USD	\N	\N
337	2025-01-10	FEE	MSFT	1.0	7.350000000000364	USD	\N	\N
338	2025-12-11	DIVIDEND	MSFT	5.0	0.5320039999999999	USD	\N	\N
339	2022-12-22	BUY	MIPS.ST	75.0	361.0	SEK	\N	\N
340	2022-12-22	FEE	MIPS.ST	1.0	260.22999999999956	SEK	\N	\N
341	2024-05-15	DIVIDEND	MIPS.ST	75.0	2.88132232	SEK	\N	\N
342	2025-10-03	SELL	MIPS.ST	75.0	344.8	SEK	\N	\N
343	2025-10-03	FEE	MIPS.ST	1.0	256.3600000000006	SEK	\N	\N
351	2025-12-14	BUY	UIMI.AS	4.0	107.42	EUR	\N	\N
352	2025-12-14	FEE	UIMI.AS	1.0	4.509999999999991	EUR	\N	\N
354	2025-12-14	DIVIDEND	UIMI.AS	4.0	0.9575	EUR	\N	\N
347	2025-12-14	BUY	IWDA.AS	78.0	100.26	EUR	\N	\N
348	2025-12-14	FEE	IWDA.AS	1.0	47.3799999999992	EUR	\N	\N
349	2025-12-14	BUY	VEUR.MI	33.0	43.28	EUR	\N	\N
350	2025-12-14	FEE	VEUR.MI	1.0	6.150000000000091	EUR	\N	\N
353	2025-12-14	DIVIDEND	VEUR.MI	15.0	0.16066666666666668	EUR	\N	\N
344	2025-12-14	TRANSFER	CASH	1	326.96	EUR	\N	\N
345	2025-12-14	TRANSFER	CASH	1	-326.96	EUR	\N	\N
346	2025-12-14	TRANSFER	CASH	1	10871.98	EUR	\N	\N
355	2025-12-14	TRANSFER	CASH	1	-815.04	EUR	\N	\N
380	2025-12-16	BUY	IWDA.AS	10.0	100.0	EUR	\N	\N
377	2025-12-16	TRANSFER	CASH	1	100000.0	EUR	\N	\N
378	2025-12-16	TRANSFER	CASH	1	100000.0	EUR	\N	\N
379	2025-12-16	TRANSFER	CASH	1	100000.0	EUR	\N	\N
400	2025-12-16	TRANSFER	CASH	1.0	11000.0	EUR	\N	1
397	2025-12-16	TRANSFER	CASH	1.0	1000.0	EUR	\N	1
393	2025-12-16	BUY	IWDA.AS	1.0	100.0	EUR	\N	\N
394	2025-12-16	SELL	IWDA.AS	1.0	110.11	EUR	\N	\N
391	2025-12-16	TRANSFER	CASH	1.0	100.0	EUR	\N	\N
392	2025-12-16	TRANSFER	CASH	1.0	1000.0	EUR	\N	\N
384	2025-12-16	BUY	IWDA.AS	1.0	110.18	EUR	\N	\N
385	2025-12-16	FEE	IWDA.AS	1.0	1.8199999999999932	EUR	\N	\N
386	2025-12-16	BUY	IWDA.AS	1.0	100.0	EUR	\N	\N
381	2025-12-16	TRANSFER	CASH	1.0	1000.0	EUR	\N	\N
382	2025-12-16	TRANSFER	CASH	1.0	2222.0	EUR	\N	\N
383	2025-12-16	TRANSFER	CASH	1.0	2.0	EUR	\N	\N
387	2025-12-16	TRANSFER	CASH	1.0	50.0	EUR	\N	\N
388	2025-12-16	TRANSFER	CASH	1.0	200.0	EUR	\N	\N
371	2025-12-16	TRANSFER	CASH	1	10000.0	EUR	\N	\N
202	2025-12-09	FEE	AAPL	1.0	720.0	USD	\N	\N
203	2025-12-09	BUY	AAPL	1.0	1.0	USD	\N	\N
204	2025-12-09	FEE	AAPL	1.0	1.0	USD	\N	\N
270	2025-12-13	DIVIDEND	AAPL	3.0	1.5	USD	\N	\N
205	2025-12-09	BUY	AAPL	100.0	10.0	USD	\N	\N
206	2025-12-09	SELL	AAPL	100.0	20.0	USD	\N	\N
207	2025-12-09	BUY	AAPL	100.0	10.0	USD	\N	\N
208	2025-12-09	FEE	AAPL	1.0	859.8499999999999	USD	\N	\N
219	2025-12-10	BUY	AAPL	10.0	100.0	USD	\N	\N
220	2025-12-10	SELL	AAPL	2.0	200.0	USD	\N	\N
221	2025-12-10	DIVIDEND	AAPL	141.0	0.16	USD	\N	\N
222	2025-12-10	DIVIDEND	AAPL	500.0	1.652525	USD	\N	\N
223	2025-12-10	DIVIDEND	AAPL	200.0	1.65858	USD	\N	\N
224	2025-12-10	DIVIDEND	AAPL	500.0	1.87992	USD	\N	\N
225	2025-12-10	DIVIDEND	AAPL	200.0	1.055	USD	\N	\N
239	2025-12-10	BUY	AAPL	10.0	277.18	USD	\N	\N
240	2025-12-10	FEE	AAPL	1.0	28.199999999999818	USD	\N	\N
241	2025-12-10	DIVIDEND	AAPL	10.0	1.5	USD	\N	\N
242	2025-12-10	DIVIDEND	AAPL	10.0	1.4000400000000002	USD	\N	\N
243	2025-12-10	DIVIDEND	AAPL	10.0	5000000.0	USD	\N	\N
248	2025-12-11	BUY	AAPL	10.0	275.96	USD	\N	\N
255	2025-12-12	BUY	AAPL	5.0	100.0	USD	\N	\N
256	2025-12-12	FEE	AAPL	1.0	10.0	USD	\N	\N
316	2025-12-13	PAYOUT	AAPL	2.0	278.28	USD	\N	\N
356	2025-12-15	BUY	AAPL	1.0	278.28	USD	\N	\N
357	2025-12-15	FEE	AAPL	1.0	21.720000000000027	USD	\N	\N
327	2025-12-14	BUY	AAPL	1	100.0	USD	\N	\N
334	2025-12-14	BUY	AAPL	1.0	278.28	USD	\N	\N
335	2025-12-14	FEE	AAPL	1.0	21.720000000000027	USD	\N	\N
372	2025-12-16	BUY	AAPL	10.0	150.0	USD	\N	\N
373	2025-12-16	FEE	AAPL	1.0	5.0	USD	\N	\N
374	2025-02-01	BUY	AAPL	5.0	160.0	USD	\N	\N
375	2025-12-16	DIVIDEND	AAPL	15.0	0.49998666666666663	USD	\N	\N
376	2025-12-16	SELL	AAPL	5.0	175.0	USD	\N	\N
389	2025-12-16	BUY	AAPL	1.0	200.0	USD	\N	\N
390	2025-12-16	SELL	AAPL	1.0	274.11	USD	\N	\N
395	2025-12-16	BUY	AAPL	1.0	200.0	USD	\N	\N
396	2025-12-16	BUY	AAPL	1.0	274.11	USD	\N	\N
398	2025-12-16	BUY	AAPL	1.0	274.11	USD	\N	1.1781
399	2025-12-16	SELL	AAPL	1.0	274.11	USD	\N	0.9137
401	2025-12-16	BUY	AAPL	1.0	274.11	USD	\N	1.178
409	2025-12-16	BUY	IWDA.AS	1.0	20.0	EUR	\N	1
410	2025-12-16	DIVIDEND	IWDA.AS	1.0	1.0	EUR	\N	1
412	2025-12-16	PAYOUT	IWDA.AS	1.0	109.87	EUR	\N	1
408	2025-12-16	TRANSFER	CASH	1.0	20.99	EUR	\N	1
411	2025-12-16	TRANSFER	CASH	1.0	10.0	EUR	\N	1
413	2025-12-16	TRANSFER	CASH	1.0	10.0	EUR	\N	1
414	2025-12-16	TRANSFER	CASH	1.0	2000.0	EUR	\N	1
415	2025-12-16	TRANSFER	CASH	1.0	2000.0	EUR	\N	1
407	2025-12-16	TRANSFER	CASH	1.0	326.96	EUR	\N	1
416	2025-12-16	TRANSFER	CASH	1.0	2.03	EUR	\N	1
405	2025-12-16	BUY	AAPL	1.0	274.11	USD	\N	1.1779
406	2025-12-16	BUY	IWDA.AS	1.0	109.99	EUR	\N	1
402	2025-12-16	TRANSFER	CASH	1.0	1000.0	EUR	\N	1
403	2025-12-16	TRANSFER	CASH	1.0	1000.0	EUR	\N	1
404	2025-12-16	TRANSFER	CASH	1.0	2000.0	EUR	\N	1
417	2025-12-16	TRANSFER	CASH	1.0	11000.0	EUR	251	1
418	2025-12-16	BUY	IWDA.AS	78.0	100.26	EUR	252	1
419	2025-12-16	FEE	IWDA.AS	1.0	29.159999999998945	EUR	252	1
420	2025-12-16	BUY	VEUR.MI	33.0	43.28	EUR	253	1
421	2025-12-16	BUY	UIMI.AS	4.0	107.42	EUR	254	1
422	2025-12-16	FEE	UIMI.AS	1.0	39.75	EUR	254	1
423	2025-12-16	DIVIDEND	UIMI.AS	4.0	1.97	EUR	254	1
424	2025-12-16	TRANSFER	CASH	1.0	-933.81	EUR	251	1
425	2025-12-16	TRANSFER	CASH	1.0	-20.0	EUR	251	1
426	2025-12-16	TRANSFER	CASH	1.0	20.0	EUR	251	1
427	2025-12-16	TRANSFER	CASH	1.0	20000.0	EUR	150	1
428	2025-12-16	BUY	AAPL	17.0	274.61	USD	255	1.1751
429	2025-12-16	FEE	AAPL	1.0	331.6300000000001	USD	255	1.1751
430	2025-12-17	TRANSFER	CASH	1.0	10000.0	EUR	256	1
431	2025-12-17	TRANSFER	CASH	1.0	10000.0	EUR	258	1
432	2024-11-01	TRANSFER	CASH	1.0	10000.0	EUR	259	1
433	2024-11-05	BUY	AAPL	50.0	170.0	USD	260	1.0513
434	2024-11-05	FEE	AAPL	1.0	10.0	USD	260	1.0513
435	2024-11-01	TRANSFER	CASH	1.0	10000.0	EUR	259	1
436	2024-11-10	BUY	MSFT	20.0	380.0	USD	261	1.0514
437	2024-11-10	FEE	MSFT	1.0	10.0	USD	261	1.0514
438	2024-11-01	TRANSFER	CASH	1.0	20000.0	EUR	262	1
439	2024-11-05	BUY	AAPL	50.0	170.0	USD	263	1.0507
440	2025-03-17	SELL	AAPL	5.0	230.61	USD	263	1.1714
441	2025-12-02	BUY	AAPL	10	150	EUR	264	1
442	2025-12-12	SELL	AAPL	5	160	EUR	264	1
443	2025-12-17	SELL	AAPL	1	165	EUR	264	1
444	2025-12-17	SELL	AMZN	5.0	222.56	EUR	191	1
445	2025-12-17	BUY	AAPL	4.0	274.61	USD	266	1.1726
446	2025-12-17	TRANSFER	CASH	1.0	5000.0	EUR	108	1
447	2025-12-17	BUY	AAPL	10.0	274.74	USD	269	1.1725
448	2022-12-17	BUY	FSLR	3.0	120.0	USD	270	1.1755
449	2025-12-17	SELL	IWDA.AS	2.0	109.29	EUR	252	1
450	2025-12-17	FEE	IWDA.AS	1.0	1.0	EUR	252	1
451	2025-12-17	BUY	IWDA.AS	2.0	109.29	EUR	252	1
452	2024-01-15	TRANSFER	CASH	1.0	10000.0	EUR	271	1
453	2024-01-20	BUY	AAPL	50.0	180.0	USD	272	1.0904
454	2024-01-20	FEE	AAPL	1.0	50.0	USD	272	1.0904
455	2024-01-15	TRANSFER	CASH	1.0	10000.0	EUR	271	1
456	2024-02-01	BUY	ASML	10.0	650.0	USD	273	1.175
457	2024-02-01	FEE	ASML	1.0	15.0	USD	273	1.175
458	2024-01-15	TRANSFER	CASH	1.0	100000.0	EUR	271	1
459	2024-03-10	BUY	MSFT	20.0	400.0	USD	274	1.0912
460	2024-03-10	FEE	MSFT	1.0	20.0	USD	274	1.0912
461	2024-05-15	DIVIDEND	AAPL	50.0	0.23999800000000002	USD	272	1.0909
462	2024-05-20	DIVIDEND	ASML	10.0	5.5	EUR	273	1
463	2024-06-15	SELL	ASML	5.0	720.0	EUR	273	1
464	2024-06-15	FEE	ASML	1.0	12.0	EUR	273	1
465	2024-07-10	BUY	AAPL	30.0	170.0	USD	272	1.0918
466	2024-07-10	FEE	AAPL	1.0	15.0	USD	272	1.0918
467	2025-12-17	BUY	MSFT	20.0	380.0	USD	274	1.0958
468	2025-12-17	FEE	MSFT	1.0	18.0	USD	274	1.0958
469	2024-03-01	TRANSFER	CASH	1.0	50000.0	EUR	275	1
470	2024-03-05	BUY	AAPL	100.0	170.0	USD	276	1.081
471	2024-03-05	FEE	AAPL	1.0	25.0	USD	276	1.081
472	2024-03-15	BUY	MSFT	50.0	420.0	USD	277	1.0785
473	2024-03-15	FEE	MSFT	1.0	30.0	USD	277	1.0785
474	2024-05-15	DIVIDEND	AAPL	100.0	0.24999685	USD	276	1.0799
475	2024-07-01	SELL	MSFT	25.0	450.0	USD	277	1.0746
476	2024-07-01	FEE	MSFT	1.0	20.0	USD	277	1.0746
477	2025-12-17	BUY	LMT	10.0	474.79	USD	278	1.0667
478	2025-12-17	FEE	LMT	1.0	52.099999999999454	USD	278	1.0667
479	2025-12-18	BUY	NVDA	4.0	170.94	USD	157	1.1743
480	2025-12-18	FEE	NVDA	1.0	66.24000000000001	USD	157	1.1743
481	2025-12-18	SELL	NVDA	30.0	170.94	USD	157	1.1745
482	2025-12-18	SELL	NVDA	4.0	170.94	USD	157	1.1745
483	2025-12-17	BUY	NVDA	30.0	170.94	USD	157	1.1744
484	2025-12-17	FEE	NVDA	1.0	271.8000000000002	USD	157	1.1744
485	2025-12-17	SELL	NVDA	30.0	170.94	USD	157	1.1744
486	2025-12-17	BUY	NVDA	30.0	170.94	USD	157	1.1744
487	2025-12-17	BUY	MSFT	15.0	476.12	USD	279	1.1744
488	2025-12-17	FEE	MSFT	1.0	358.1999999999998	USD	279	1.1744
489	2025-12-17	BUY	COLR.BR	10.0	31.5	EUR	280	1
490	2025-12-17	SELL	5E1.F	3.0	34.1	EUR	170	1
491	2025-12-18	TRANSFER	CASH	1.0	10000.0	EUR	267	1
492	2025-12-18	BUY	TSLA	4.0	467.26	USD	281	1.1744
493	2025-12-18	FEE	TSLA	1.0	5.960000000000036	USD	281	1.1744
494	2025-12-18	BUY	AMZN	6.0	221.27	USD	282	1.173
495	2025-12-18	BUY	NKE	10.0	65.69	USD	283	0.991
496	2025-12-18	FEE	NKE	1.0	3.1000000000000227	USD	283	0.991
497	2025-12-18	BUY	AAPL	4.0	271.84	USD	284	1.1729
498	2025-12-18	SELL	TSLA	4.0	467.26	EUR	281	1.1729
499	2025-12-12	BUY	TSLA	5.0	420.0	USD	281	1.1729
500	2025-12-18	BUY	MSFT	4.0	476.12	USD	285	0.9979
501	2025-12-18	FEE	MSFT	1.0	5.519999999999982	USD	285	0.9979
502	2025-12-18	SELL	MSFT	4.0	476.12	EUR	285	1.1727
503	2025-06-01	BUY	SLB	20.0	35.8	USD	286	1.1727
504	2025-07-01	BUY	MRK	15.0	80.0	USD	287	1.1725
505	2025-12-18	TRANSFER	CASH	1.0	10000.0	EUR	114	1
506	2025-12-18	TRANSFER	CASH	1.0	10000.0	EUR	114	1
507	2025-12-18	BUY	AAPL	10.0	271.84	USD	288	1.1726
508	2025-12-18	TRANSFER	CASH	1.0	20000.0	EUR	290	1
509	2025-12-18	BUY	MSFT	10.0	480.86	USD	291	1.1727
510	2025-12-18	BUY	AAPL	17.0	269.46	USD	292	1.174
511	2025-12-18	BUY	KIM	90.0	20.42	USD	293	1.174
512	2025-12-18	BUY	PODD	28.0	293.51	USD	294	1.1741
513	2025-12-18	BUY	MSFT	5.0	482.94	USD	285	0.9979
514	2025-12-18	FEE	MSFT	1.0	5.300000000000182	USD	285	0.9979
515	2025-12-18	SELL	TSLA	5.0	489.18	EUR	281	1
516	2025-12-18	BUY	TSLA	5.0	489.57	USD	281	0.998
517	2025-12-18	FEE	TSLA	1.0	2.150000000000091	USD	281	0.998
\.


--
-- Data for Name: Wisselkoersen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Wisselkoersen" (wk, munt) FROM stdin;
1.0	EUR
1.1731581687927246	USD
4.202070236206055	PLN
1727.9000244140625	KRW
1703.2685546875	ARS
10.88718032836914	SEK
\.


--
-- Data for Name: activa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activa (ticker, name, sector, created_at) FROM stdin;
CASH	Contante Positie	Liquiditeit	2025-12-16 12:05:02.734424+00
5E1.F	ONBEKEND - Vul Naam In	ONBEKEND - Vul Sector In	2025-12-16 12:05:02.734424+00
AAPL.BA	ONBEKEND - Vul Naam In	ONBEKEND - Vul Sector In	2025-12-16 12:05:02.734424+00
AD	ONBEKEND - Vul Naam In	ONBEKEND - Vul Sector In	2025-12-16 12:05:02.734424+00
META	ONBEKEND - Vul Naam In	ONBEKEND - Vul Sector In	2025-12-16 12:05:02.734424+00
MIPS.ST	ONBEKEND - Vul Naam In	ONBEKEND - Vul Sector In	2025-12-16 12:05:02.734424+00
NVDA	ONBEKEND - Vul Naam In	ONBEKEND - Vul Sector In	2025-12-16 12:05:02.734424+00
TEXF.BR	ONBEKEND - Vul Naam In	ONBEKEND - Vul Sector In	2025-12-16 12:05:02.734424+00
VTI	ONBEKEND - Vul Naam In	ONBEKEND - Vul Sector In	2025-12-16 12:05:02.734424+00
AAPL	Apple Inc.	Technology	2025-12-16 14:29:54.373334+00
IWDA.AS	iShares Core MSCI World UCITS ETF USD (Acc)	Onbekend	2025-12-16 12:05:02.734424+00
VEUR.MI	Vanguard FTSE Developed Europe UCITS ETF	Onbekend	2025-12-16 12:05:02.734424+00
UIMI.AS	UBS Core MSCI EM UCITS ETF USD dis	Onbekend	2025-12-16 12:05:02.734424+00
MSFT	Microsoft Corporation	Technology	2025-12-16 12:05:02.734424+00
FSLR	First Solar, Inc.	Technology	2025-12-17 17:00:59.965821+00
ASML	ASML Holding N.V.	Technology	2025-12-17 19:30:04.214905+00
LMT	Lockheed Martin Corporation	Industrials	2025-12-16 12:05:02.734424+00
COLR.BR	Colruyt Group N.V.	Consumer Defensive	2025-12-16 12:05:02.734424+00
TSLA	Tesla, Inc.	Consumer Cyclical	2025-12-16 12:05:02.734424+00
AMZN	Amazon.com, Inc.	Consumer Cyclical	2025-12-16 12:05:02.734424+00
NKE	NIKE, Inc.	Consumer Cyclical	2025-12-18 10:50:05.537251+00
SLB	SLB N.V.	Energy	2025-12-18 11:14:46.739776+00
MRK	Merck & Co., Inc.	Healthcare	2025-12-16 12:05:02.734424+00
KIM	Kimco Realty Corporation	Real Estate	2025-12-18 14:48:45.445209+00
PODD	Insulet Corporation	Healthcare	2025-12-18 14:49:43.675857+00
\.


--
-- Data for Name: groep_leden; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groep_leden (created_at, groep_id, ledenid, rol) FROM stdin;
2025-12-16 16:43:17.079751+00	90	42	host
2025-12-16 21:56:05.95935+00	65	42	member
2025-12-01 11:46:10.637532+00	38	30	host
2025-12-02 08:25:50.268369+00	21	29	member
2025-12-02 08:27:37.0145+00	38	29	member
2025-12-17 06:43:39.989502+00	92	30	host
2025-12-02 08:29:11.867356+00	32	29	member
2025-12-02 08:29:48.234548+00	31	29	member
2025-12-17 06:51:11.117018+00	93	30	host
2025-12-03 14:28:00.936107+00	39	32	host
2025-12-17 06:51:28.840032+00	94	30	host
2025-12-17 07:04:46.633794+00	95	30	host
2025-12-17 07:30:42.70326+00	96	30	host
2025-12-17 09:57:26.115029+00	97	30	host
2025-12-17 13:14:16.003683+00	98	33	host
2025-12-17 14:10:51.57382+00	99	30	host
2025-12-03 19:03:09.992269+00	40	36	host
2025-12-17 17:22:22.586807+00	100	30	host
2025-12-17 19:53:55.507373+00	101	30	host
2025-12-17 20:05:07.502963+00	101	59	member
2025-12-18 08:12:18.194849+00	48	60	host
2025-12-18 08:19:55.162487+00	48	61	host
2025-12-18 11:25:33.506757+00	39	34	member
2025-12-05 22:23:46.377111+00	48	29	host
2025-12-18 14:33:17.85895+00	102	32	host
2025-12-18 14:40:38.715448+00	103	65	host
2025-12-18 14:44:26.036541+00	103	64	member
2025-11-26 14:56:35.79142+00	21	33	host
2025-12-18 14:54:36.980143+00	103	66	member
2025-12-18 16:54:45.866527+00	98	58	member
2025-12-18 10:47:01.247138+00	98	42	host
2025-12-07 11:17:00.495981+00	51	32	host
2025-12-07 13:21:35.040557+00	48	40	host
2025-12-05 22:31:04.063563+00	48	37	member
2025-11-26 18:24:42.795239+00	31	35	host
2025-11-26 19:28:46.545766+00	32	35	host
2025-12-08 16:43:25.695064+00	48	41	host
2025-12-09 18:38:15.441003+00	56	28	host
2025-12-09 18:38:22.037882+00	57	28	host
2025-12-09 19:05:26.715503+00	58	28	host
2025-12-10 09:54:05.229061+00	59	28	host
2025-12-10 11:48:09.179342+00	60	28	host
2025-12-10 12:15:01.613533+00	61	28	host
2025-12-10 14:17:05.879231+00	62	33	host
2025-12-10 14:34:56.364824+00	21	28	member
2025-12-12 10:49:17.157542+00	64	28	host
2025-12-12 10:49:21.966774+00	65	28	host
2025-12-14 16:05:40.093225+00	71	43	host
2025-12-14 16:09:53.449961+00	72	44	host
2025-12-14 16:32:58.677696+00	73	45	host
2025-12-14 16:40:51.290664+00	74	46	host
2025-12-14 16:42:32.656503+00	75	48	host
2025-12-14 16:44:53.257775+00	76	50	host
2025-12-16 09:46:09.096517+00	48	52	member
2025-12-16 09:59:37.682881+00	48	33	member
2025-12-16 09:59:38.879322+00	48	42	member
2025-12-16 10:06:48.606489+00	81	55	host
\.


--
-- Data for Name: groepsaanvragen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groepsaanvragen (id, groep_id, ledenid, type, status, created_at, processed_by) FROM stdin;
44	48	42	leave	pending	2025-12-16 21:34:33.987273	\N
46	65	42	join	approved	2025-12-16 21:55:25.717837	28
47	48	57	join	pending	2025-12-16 22:39:44.894993	\N
50	101	59	join	approved	2025-12-17 20:04:24.061124	30
51	48	60	join	approved	2025-12-17 23:27:53.640513	29
52	48	61	join	approved	2025-12-18 08:16:57.923729	29
48	98	42	join	approved	2025-12-17 13:18:11.500125	33
53	39	34	join	approved	2025-12-18 11:25:03.239278	32
54	103	64	join	approved	2025-12-18 14:42:40.662565	65
49	98	58	join	approved	2025-12-17 13:18:32.155608	33
55	103	66	join	approved	2025-12-18 14:43:57.256569	65
56	98	58	join	approved	2025-12-18 16:08:20.639876	33
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-10-16 21:22:11
20211116045059	2025-10-16 21:22:13
20211116050929	2025-10-16 21:22:15
20211116051442	2025-10-16 21:22:17
20211116212300	2025-10-16 21:22:19
20211116213355	2025-10-16 21:22:21
20211116213934	2025-10-16 21:22:22
20211116214523	2025-10-16 21:22:25
20211122062447	2025-10-16 21:22:26
20211124070109	2025-10-16 21:22:28
20211202204204	2025-10-16 21:22:30
20211202204605	2025-10-16 21:22:31
20211210212804	2025-10-16 21:22:37
20211228014915	2025-10-16 21:22:39
20220107221237	2025-10-16 21:22:40
20220228202821	2025-10-16 21:22:42
20220312004840	2025-10-16 21:22:44
20220603231003	2025-10-16 21:22:46
20220603232444	2025-10-16 21:22:48
20220615214548	2025-10-16 21:22:50
20220712093339	2025-10-16 21:22:52
20220908172859	2025-10-16 21:22:54
20220916233421	2025-10-16 21:22:55
20230119133233	2025-10-16 21:22:57
20230128025114	2025-10-16 21:22:59
20230128025212	2025-10-16 21:23:01
20230227211149	2025-10-16 21:23:03
20230228184745	2025-10-16 21:23:04
20230308225145	2025-10-16 21:23:06
20230328144023	2025-10-16 21:23:08
20231018144023	2025-10-16 21:23:10
20231204144023	2025-10-16 21:23:13
20231204144024	2025-10-16 21:23:14
20231204144025	2025-10-16 21:23:16
20240108234812	2025-10-16 21:23:18
20240109165339	2025-10-16 21:23:19
20240227174441	2025-10-16 21:23:22
20240311171622	2025-10-16 21:23:25
20240321100241	2025-10-16 21:23:28
20240401105812	2025-10-16 21:23:33
20240418121054	2025-10-16 21:23:36
20240523004032	2025-10-16 21:23:42
20240618124746	2025-10-16 21:23:44
20240801235015	2025-10-16 21:23:45
20240805133720	2025-10-16 21:23:47
20240827160934	2025-10-16 21:23:49
20240919163303	2025-10-16 21:23:51
20240919163305	2025-10-16 21:23:53
20241019105805	2025-10-16 21:23:54
20241030150047	2025-10-16 21:24:01
20241108114728	2025-10-16 21:24:03
20241121104152	2025-10-16 21:24:05
20241130184212	2025-10-16 21:24:07
20241220035512	2025-10-16 21:24:09
20241220123912	2025-10-16 21:24:10
20241224161212	2025-10-16 21:24:12
20250107150512	2025-10-16 21:24:14
20250110162412	2025-10-16 21:24:15
20250123174212	2025-10-16 21:24:17
20250128220012	2025-10-16 21:24:19
20250506224012	2025-10-16 21:24:20
20250523164012	2025-10-16 21:24:22
20250714121412	2025-10-16 21:24:24
20250905041441	2025-10-16 21:24:25
20251103001201	2025-11-17 14:02:29
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-10-16 21:22:08.631808
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-10-16 21:22:08.637158
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-10-16 21:22:08.645908
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-10-16 21:22:08.665132
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-10-16 21:22:08.720469
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-10-16 21:22:08.725189
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-10-16 21:22:08.732036
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-10-16 21:22:08.737109
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-10-16 21:22:08.742193
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-10-16 21:22:08.74856
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-10-16 21:22:08.757485
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-10-16 21:22:08.763896
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-10-16 21:22:08.77213
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-10-16 21:22:08.777868
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-10-16 21:22:08.7826
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-10-16 21:22:08.806718
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-10-16 21:22:08.813371
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-10-16 21:22:08.818374
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-10-16 21:22:08.8238
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-10-16 21:22:08.831443
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-10-16 21:22:08.836256
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-10-16 21:22:08.843759
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-10-16 21:22:08.855912
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-10-16 21:22:08.86805
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-10-16 21:22:08.873414
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-10-16 21:22:08.87809
26	objects-prefixes	ef3f7871121cdc47a65308e6702519e853422ae2	2025-10-16 21:22:08.882956
27	search-v2	33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2	2025-10-16 21:22:08.897058
28	object-bucket-name-sorting	ba85ec41b62c6a30a3f136788227ee47f311c436	2025-10-16 21:22:10.408974
29	create-prefixes	a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b	2025-10-16 21:22:10.426235
30	update-object-levels	6c6f6cc9430d570f26284a24cf7b210599032db7	2025-10-16 21:22:10.442197
31	objects-level-index	33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8	2025-10-16 21:22:12.151324
32	backward-compatible-index-on-objects	2d51eeb437a96868b36fcdfb1ddefdf13bef1647	2025-10-16 21:22:12.305904
33	backward-compatible-index-on-prefixes	fe473390e1b8c407434c0e470655945b110507bf	2025-10-16 21:22:12.313769
34	optimize-search-function-v1	82b0e469a00e8ebce495e29bfa70a0797f7ebd2c	2025-10-16 21:22:12.315726
35	add-insert-trigger-prefixes	63bb9fd05deb3dc5e9fa66c83e82b152f0caf589	2025-10-16 21:22:12.325171
36	optimise-existing-functions	81cf92eb0c36612865a18016a38496c530443899	2025-10-16 21:22:12.329829
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2025-10-16 21:22:12.342272
38	iceberg-catalog-flag-on-buckets	19a8bd89d5dfa69af7f222a46c726b7c41e462c5	2025-10-16 21:22:12.347483
39	add-search-v2-sort-support	39cf7d1e6bf515f4b02e41237aba845a7b492853	2025-10-16 21:22:12.361883
40	fix-prefix-race-conditions-optimized	fd02297e1c67df25a9fc110bf8c8a9af7fb06d1f	2025-10-16 21:22:12.367809
41	add-object-level-update-trigger	44c22478bf01744b2129efc480cd2edc9a7d60e9	2025-10-16 21:22:12.376871
42	rollback-prefix-triggers	f2ab4f526ab7f979541082992593938c05ee4b47	2025-10-16 21:22:12.382128
43	fix-object-level	ab837ad8f1c7d00cc0b7310e989a23388ff29fc6	2025-10-16 21:22:12.388997
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2025-11-20 12:57:15.990778
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2025-11-20 12:57:16.033286
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2025-11-20 12:57:16.17842
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2025-11-20 12:57:16.184708
48	iceberg-catalog-ids	2666dff93346e5d04e0a878416be1d5fec345d6f	2025-11-20 12:57:16.190182
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2025-12-19 13:59:25.377526
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
\.


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.prefixes (bucket_id, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--

COPY supabase_migrations.schema_migrations (version, statements, name, created_by, idempotency_key) FROM stdin;
20251105131615	{"CREATE TABLE IF NOT EXISTS kv_store_08a61cf2 ( key TEXT NOT NULL PRIMARY KEY, value JSONB NOT NULL ); ALTER TABLE kv_store_08a61cf2 ENABLE ROW LEVEL SECURITY; CREATE INDEX ON kv_store_08a61cf2 (key text_pattern_ops);"}	create_kv_table_08a61cf2	antoon.hendrickx@ugent.be	2f30d5762a27fa2c3b42f1a30640f6aa
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 14, true);


--
-- Name: Groep_Groepid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Groep_Groepid_seq"', 103, true);


--
-- Name: Kas_kas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Kas_kas_id_seq"', 88, true);


--
-- Name: Leden_Ledenid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Leden_Ledenid_seq"', 66, true);


--
-- Name: Liquiditeit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Liquiditeit_id_seq"', 27, true);


--
-- Name: Portefeuille_Portefeuille id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Portefeuille_Portefeuille id_seq"', 294, true);


--
-- Name: Transacties_transactie_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Transacties_transactie_id_seq"', 517, true);


--
-- Name: groepsaanvragen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groepsaanvragen_id_seq', 56, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: Groep Groep_Groepid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Groep"
    ADD CONSTRAINT "Groep_Groepid_key" UNIQUE (groep_id);


--
-- Name: Groep Groep_Groepid_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Groep"
    ADD CONSTRAINT "Groep_Groepid_key1" UNIQUE (groep_id);


--
-- Name: Groep Groep_invite_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Groep"
    ADD CONSTRAINT "Groep_invite_code_key" UNIQUE (invite_code);


--
-- Name: Groep Groep_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Groep"
    ADD CONSTRAINT "Groep_pkey" PRIMARY KEY (groep_id);


--
-- Name: Kas Kas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kas"
    ADD CONSTRAINT "Kas_pkey" PRIMARY KEY (kas_id);


--
-- Name: Leden Leden_Ledenid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Leden"
    ADD CONSTRAINT "Leden_Ledenid_key" UNIQUE (ledenid);


--
-- Name: Leden Leden_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Leden"
    ADD CONSTRAINT "Leden_pkey" PRIMARY KEY (ledenid);


--
-- Name: Liquiditeit Liquiditeit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Liquiditeit"
    ADD CONSTRAINT "Liquiditeit_pkey" PRIMARY KEY (id);


--
-- Name: Portefeuille Portefeuille_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Portefeuille"
    ADD CONSTRAINT "Portefeuille_pkey" PRIMARY KEY (port_id);


--
-- Name: Transacties Transacties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Transacties"
    ADD CONSTRAINT "Transacties_pkey" PRIMARY KEY (transactie_id);


--
-- Name: Wisselkoersen Wisselkoersen_munt_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Wisselkoersen"
    ADD CONSTRAINT "Wisselkoersen_munt_key" UNIQUE (munt);


--
-- Name: Wisselkoersen Wisselkoersen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Wisselkoersen"
    ADD CONSTRAINT "Wisselkoersen_pkey" PRIMARY KEY (munt);


--
-- Name: activa activa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activa
    ADD CONSTRAINT activa_pkey PRIMARY KEY (ticker);


--
-- Name: groep_leden groep_leden_groep_id_ledenid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groep_leden
    ADD CONSTRAINT groep_leden_groep_id_ledenid_key UNIQUE (groep_id, ledenid);


--
-- Name: groep_leden groep_leden_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groep_leden
    ADD CONSTRAINT groep_leden_pkey PRIMARY KEY (groep_id, ledenid);


--
-- Name: groep_leden groep_leden_unique_member_per_group; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groep_leden
    ADD CONSTRAINT groep_leden_unique_member_per_group UNIQUE (groep_id, ledenid);


--
-- Name: groepsaanvragen groepsaanvragen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groepsaanvragen
    ADD CONSTRAINT groepsaanvragen_pkey PRIMARY KEY (id);


--
-- Name: Portefeuille portefeuille_unique_ticker_per_group; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Portefeuille"
    ADD CONSTRAINT portefeuille_unique_ticker_per_group UNIQUE (groep_id, ticker);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_idempotency_key_key; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_idempotency_key_key UNIQUE (idempotency_key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: kas_groep_id_desc_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX kas_groep_id_desc_idx ON public."Kas" USING btree (groep_id, kas_id DESC);


--
-- Name: unique_pending_request; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_pending_request ON public.groepsaanvragen USING btree (groep_id, ledenid, type) WHERE (status = 'pending'::text);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: Groep Groep_owner_lid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Groep"
    ADD CONSTRAINT "Groep_owner_lid_id_fkey" FOREIGN KEY (owner_lid_id) REFERENCES public."Leden"(ledenid);


--
-- Name: Liquiditeit Liquiditeit_groep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Liquiditeit"
    ADD CONSTRAINT "Liquiditeit_groep_id_fkey" FOREIGN KEY (groep_id) REFERENCES public."Groep"(groep_id) ON DELETE CASCADE;


--
-- Name: Transacties Transacties_portefeuille_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Transacties"
    ADD CONSTRAINT "Transacties_portefeuille_id_fkey" FOREIGN KEY (portefeuille_id) REFERENCES public."Portefeuille"(port_id) ON DELETE SET NULL;


--
-- Name: Portefeuille fk_portefeuille_ticker; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Portefeuille"
    ADD CONSTRAINT fk_portefeuille_ticker FOREIGN KEY (ticker) REFERENCES public.activa(ticker) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: groep_leden groep_leden_groep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groep_leden
    ADD CONSTRAINT groep_leden_groep_id_fkey FOREIGN KEY (groep_id) REFERENCES public."Groep"(groep_id) ON DELETE CASCADE;


--
-- Name: groep_leden groep_leden_ledenid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groep_leden
    ADD CONSTRAINT groep_leden_ledenid_fkey FOREIGN KEY (ledenid) REFERENCES public."Leden"(ledenid);


--
-- Name: groepsaanvragen groepsaanvragen_groep_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groepsaanvragen
    ADD CONSTRAINT groepsaanvragen_groep_fk FOREIGN KEY (groep_id) REFERENCES public."Groep"(groep_id);


--
-- Name: groepsaanvragen groepsaanvragen_leden_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groepsaanvragen
    ADD CONSTRAINT groepsaanvragen_leden_fk FOREIGN KEY (ledenid) REFERENCES public."Leden"(ledenid);


--
-- Name: groepsaanvragen groepsaanvragen_processed_by_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groepsaanvragen
    ADD CONSTRAINT groepsaanvragen_processed_by_fk FOREIGN KEY (processed_by) REFERENCES public."Leden"(ledenid);


--
-- Name: Kas kas_groep_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kas"
    ADD CONSTRAINT kas_groep_fk FOREIGN KEY (groep_id) REFERENCES public."Groep"(groep_id) ON DELETE CASCADE;


--
-- Name: Portefeuille portefeuille_groep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Portefeuille"
    ADD CONSTRAINT portefeuille_groep_id_fkey FOREIGN KEY (groep_id) REFERENCES public."Groep"(groep_id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: Kas kas_delete_allow_server; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY kas_delete_allow_server ON public."Kas" FOR DELETE USING (true);


--
-- Name: Kas kas_update_allow_server; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY kas_update_allow_server ON public."Kas" FOR UPDATE USING (true) WITH CHECK (true);


--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea, text[], text[]) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.crypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.dearmor(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_bytes(integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_uuid() FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text, integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO dashboard_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_key_id(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1mc() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v4() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_nil() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_dns() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_oid() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_url() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_x500() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;


--
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE oauth_authorizations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_authorizations TO postgres;
GRANT ALL ON TABLE auth.oauth_authorizations TO dashboard_user;


--
-- Name: TABLE oauth_client_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_client_states TO postgres;
GRANT ALL ON TABLE auth.oauth_client_states TO dashboard_user;


--
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;


--
-- Name: TABLE oauth_consents; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_consents TO postgres;
GRANT ALL ON TABLE auth.oauth_consents TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements_info FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- Name: TABLE "Groep"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."Groep" TO anon;
GRANT ALL ON TABLE public."Groep" TO authenticated;
GRANT ALL ON TABLE public."Groep" TO service_role;


--
-- Name: SEQUENCE "Groep_Groepid_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."Groep_Groepid_seq" TO anon;
GRANT ALL ON SEQUENCE public."Groep_Groepid_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."Groep_Groepid_seq" TO service_role;


--
-- Name: TABLE "Kas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."Kas" TO anon;
GRANT ALL ON TABLE public."Kas" TO authenticated;
GRANT ALL ON TABLE public."Kas" TO service_role;


--
-- Name: SEQUENCE "Kas_kas_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."Kas_kas_id_seq" TO anon;
GRANT ALL ON SEQUENCE public."Kas_kas_id_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."Kas_kas_id_seq" TO service_role;


--
-- Name: TABLE "Leden"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."Leden" TO anon;
GRANT ALL ON TABLE public."Leden" TO authenticated;
GRANT ALL ON TABLE public."Leden" TO service_role;


--
-- Name: SEQUENCE "Leden_Ledenid_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."Leden_Ledenid_seq" TO anon;
GRANT ALL ON SEQUENCE public."Leden_Ledenid_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."Leden_Ledenid_seq" TO service_role;


--
-- Name: TABLE "Liquiditeit"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."Liquiditeit" TO anon;
GRANT ALL ON TABLE public."Liquiditeit" TO authenticated;
GRANT ALL ON TABLE public."Liquiditeit" TO service_role;


--
-- Name: SEQUENCE "Liquiditeit_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."Liquiditeit_id_seq" TO anon;
GRANT ALL ON SEQUENCE public."Liquiditeit_id_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."Liquiditeit_id_seq" TO service_role;


--
-- Name: TABLE "Portefeuille"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."Portefeuille" TO anon;
GRANT ALL ON TABLE public."Portefeuille" TO authenticated;
GRANT ALL ON TABLE public."Portefeuille" TO service_role;


--
-- Name: SEQUENCE "Portefeuille_Portefeuille id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."Portefeuille_Portefeuille id_seq" TO anon;
GRANT ALL ON SEQUENCE public."Portefeuille_Portefeuille id_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."Portefeuille_Portefeuille id_seq" TO service_role;


--
-- Name: TABLE "Transacties"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."Transacties" TO anon;
GRANT ALL ON TABLE public."Transacties" TO authenticated;
GRANT ALL ON TABLE public."Transacties" TO service_role;


--
-- Name: SEQUENCE "Transacties_transactie_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."Transacties_transactie_id_seq" TO anon;
GRANT ALL ON SEQUENCE public."Transacties_transactie_id_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."Transacties_transactie_id_seq" TO service_role;


--
-- Name: TABLE "Wisselkoersen"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."Wisselkoersen" TO anon;
GRANT ALL ON TABLE public."Wisselkoersen" TO authenticated;
GRANT ALL ON TABLE public."Wisselkoersen" TO service_role;


--
-- Name: TABLE activa; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.activa TO anon;
GRANT ALL ON TABLE public.activa TO authenticated;
GRANT ALL ON TABLE public.activa TO service_role;


--
-- Name: TABLE groep_leden; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.groep_leden TO anon;
GRANT ALL ON TABLE public.groep_leden TO authenticated;
GRANT ALL ON TABLE public.groep_leden TO service_role;


--
-- Name: TABLE groepsaanvragen; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.groepsaanvragen TO anon;
GRANT ALL ON TABLE public.groepsaanvragen TO authenticated;
GRANT ALL ON TABLE public.groepsaanvragen TO service_role;


--
-- Name: SEQUENCE groepsaanvragen_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.groepsaanvragen_id_seq TO anon;
GRANT ALL ON SEQUENCE public.groepsaanvragen_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.groepsaanvragen_id_seq TO service_role;


--
-- Name: TABLE kas_saldo_per_groep; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.kas_saldo_per_groep TO anon;
GRANT ALL ON TABLE public.kas_saldo_per_groep TO authenticated;
GRANT ALL ON TABLE public.kas_saldo_per_groep TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

REVOKE ALL ON TABLE storage.buckets FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.buckets TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres WITH GRANT OPTION;


--
-- Name: TABLE buckets_analytics; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets_analytics TO service_role;
GRANT ALL ON TABLE storage.buckets_analytics TO authenticated;
GRANT ALL ON TABLE storage.buckets_analytics TO anon;


--
-- Name: TABLE buckets_vectors; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.buckets_vectors TO service_role;
GRANT SELECT ON TABLE storage.buckets_vectors TO authenticated;
GRANT SELECT ON TABLE storage.buckets_vectors TO anon;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

REVOKE ALL ON TABLE storage.objects FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.objects TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres WITH GRANT OPTION;


--
-- Name: TABLE prefixes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.prefixes TO service_role;
GRANT ALL ON TABLE storage.prefixes TO authenticated;
GRANT ALL ON TABLE storage.prefixes TO anon;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- Name: TABLE vector_indexes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.vector_indexes TO service_role;
GRANT SELECT ON TABLE storage.vector_indexes TO authenticated;
GRANT SELECT ON TABLE storage.vector_indexes TO anon;


--
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;


--
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

\unrestrict 4hZV5ZNC4oqfRFbV6792dOaTk28hD9XpacoCNFFdjhG9jqG3eIZknv8SDgAkAoQ

