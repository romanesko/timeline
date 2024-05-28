create function public.require(params json, name text) returns void
    language plpgsql as
$$
BEGIN
    if params ->> name is null then raise exception '%: поле пустое', name USING ERRCODE = 'P0001'; end if;
END;
$$;


create function public.requireBigint(params json, key text) returns bigint
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return params ->> key;
END;
$$;


create function public.requireBoolean(params json, key text) returns boolean
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return coalesce((params ->> key)::BOOLEAN, false);
END;
$$;

create function public.requireDate(params json, key text) returns timestamp without time zone
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return (params ->> key)::TIMESTAMP;
END;
$$;

create function public.requireInt(params json, key text) returns integer
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return params ->> key;
END;
$$;

create function public.requireJson(params json, key text) returns json
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return (params ->> key)::json;
END;
$$;


create function public.requireJsonb(params json, key text) returns json
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return (params ->> key)::jsonb;
END;
$$;


create function public.requireJsonb(params jsonb, key text) returns json
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return (params ->> key)::jsonb;
END;
$$;

create function public.requireNumeric(params json, key text) returns numeric
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return (params ->> key)::NUMERIC(10, 2);
END;
$$;

create function public.requireText(params json, key text) returns text
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return trim(params ->> key);
END;
$$;


create function public.requireUUID(params json, key text) returns uuid
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return params ->> key;
END;
$$;

create or replace function public.requireUUIDArray(params json, key text) returns uuid[]
    language plpgsql as
$$
BEGIN
    perform require(params, key);
    return (select array_agg(s.a) from (select json_array_elements_text((params ->> key)::json) a) as s)::uuid[];
END;
$$;

