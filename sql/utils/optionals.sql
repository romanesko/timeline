create function public.optionalBoolean(params json, key text) returns boolean
    language plpgsql as
$$
BEGIN
    return coalesce((params ->> key)::BOOLEAN, false);
END;
$$;

create function public.optionalBoolean(params json, key text, _default bool) returns boolean
    language plpgsql as
$$
BEGIN
    return coalesce((params ->> key)::BOOLEAN, _default);
END;
$$;

create or replace function public.optionalDate(params json, key text) returns timestamp without time zone
    language plpgsql as
$$
BEGIN
    if (params->>key)::text = '' then return null; end if;
    return (params ->> key)::TIMESTAMP;
EXCEPTION WHEN OTHERS THEN
    raise exception 'Wrong date format';
END;
$$;

create function public.optionalDate(params json, key text, _default timestamp) returns timestamp without time zone
    language plpgsql as
$$
BEGIN
    return coalesce((params ->> key)::TIMESTAMP, _default);
END;
$$;


create function public.optionalInt(params json, key text) returns integer
    language plpgsql as
$$
BEGIN
    return params ->> key;
END;
$$;

create function public.optionalInt(params json, key text, _default int) returns integer
    language plpgsql as
$$
DECLARE
    _val int;
BEGIN
    _val = params ->> key;
    return coalesce(_val, _default);
END;
$$;

create function public.optionalJson(params json, key text) returns json
    language plpgsql as
$$
BEGIN
    IF (params ->> key = '' or params ->> key = '""') THEN
        return null;
    END IF;
    return (params ->> key)::json;
END;
$$;

create function public.optionalJsonb(params json, key text) returns jsonb
    language plpgsql as
$$
BEGIN
    IF (params ->> key = '' or params ->> key = '""') THEN
        return null;
    END IF;
    return (params ->> key)::jsonb;
END;
$$;

create function public.optionalNumeric(params json, key text) returns numeric
    language plpgsql as
$$
BEGIN
    IF (params ->> key = '' or params ->> key = '""') THEN
        return null;
    END IF;
    return (params ->> key)::NUMERIC(10, 2);
END;
$$;

create or replace function public.optionalText(params json, key text) returns text
    language plpgsql as
$$
BEGIN
    return optionalText(params, key, null);
END;
$$;

create or replace function public.optionalText(params json, key text, _default text) returns text
    language plpgsql as
$$
    -- set null if val is empty ("") otherwise set val or default (if val is null)
DECLARE
    _val text;
BEGIN
    _val = trim(params ->> key);

    if _val = '' then
        return null;
    else
        return coalesce(trim(params ->> key), trim(_default));
    end if;

END;
$$;


create or replace function public.optionalUUID(params json, key text, _default uuid) returns uuid
    language plpgsql as
$$
DECLARE
    _val uuid;
BEGIN
    _val = params ->> key;
    return coalesce(_val, _default);
END;
$$;

create function public.optionalUUID(params json, key text) returns uuid
    language plpgsql as
$$
BEGIN
    return optionalUUID(params, key, null);
END;
$$;

