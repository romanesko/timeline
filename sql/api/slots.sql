create or replace function timeline.slots (params json, _token uuid) returns json language plpgsql stable as
$$
DECLARE
    _response JSON;
    _zone int;
    _from_date date;
    _to_date date;
BEGIN
    perform timeline.get_user(_token);
    _zone = requireInt(params,'zone');
    _from_date = requireDate(params,'from');
    _to_date = requireDate(params,'to');
    select json_agg(value) into _response from timeline.values where zone=_zone and date>=_from_date and date <=_to_date;
    return coalesce(_response,'[]');
END
$$;

select timeline.slots(json_build_object( 'zone',1,'from', '2024-01-01', 'to','2024-12-31'),timeline.test_token(1))

