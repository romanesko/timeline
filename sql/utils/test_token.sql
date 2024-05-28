create or replace function timeline.test_token(_user_id bigint) returns uuid language plpgsql stable as
$$
DECLARE
    _token uuid;
BEGIN
    select token into _token from timeline.users where id = _user_id;
    if _token is null then raise exception 'TEST TOKEN NOT FOUND';  end if;
    RETURN _token;
END
$$;

select timeline.test_token(1)



