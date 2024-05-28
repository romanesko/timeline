create or replace function timeline.zones(params json, _token uuid) returns json language plpgsql stable as
$$
DECLARE
    _response JSON;
    _user timeline.users;
BEGIN
    _user = timeline.get_user(_token);

    SELECT json_agg(a) INTO _response FROM (

        select * from timeline.zones order by id

    ) as a;
    RETURN coalesce(_response,'[]');
END
$$;

select timeline.zones(json_build_object(),timeline.test_token(1))

