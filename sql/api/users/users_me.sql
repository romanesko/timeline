create or replace function timeline.users_me(params json, _token uuid) returns json language plpgsql stable as
$$
DECLARE
    _response JSON;
    _user timeline.users;
BEGIN
    _user = timeline.get_user(_token);

    SELECT to_json(a) INTO _response FROM (
        select id,name,role,token from timeline.users where id = _user.id limit 1
    ) as a;

    if json_is_empty(_response) then raise exception 'Object not found' using errcode = 'ER404';  end if;
    RETURN coalesce(_response,'{}');
END
$$;

select timeline.users_me(null,timeline.test_token(1));

