create or replace function timeline.get_user(_token uuid) returns timeline.users language plpgsql stable as
$$
DECLARE
    _user timeline.users;
BEGIN
    if _token is null then raise exception 'No auth token provided' using ERRCODE='ER401';  end if;
    select * into _user from timeline.users where token =_token;
    if _user is null then raise exception 'User not found' using ERRCODE='ER401';  end if;
    RETURN _user;
END
$$;

select timeline.get_user(timeline.test_token(1));



