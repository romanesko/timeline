create or replace function timeline.users_auth(params json, _token uuid) returns json language plpgsql stable as
$$
DECLARE
    _response JSON;
    _login text;
    _password text;
    _user timeline.users;
BEGIN
--     _user = timeline.get_user(_token);
    _login = requireText(params, 'login');
    _password = requireText(params, 'password');

    select * into _user from timeline.users where login = _login and password = _password;

    if _user.id is null then raise exception 'Wrong credentials' using errcode = 'ER403'; end if;

    RETURN json_build_object('id', _user.id, 'name', _user.name, 'token', _user.token);
END
$$;

select timeline.users_auth(
           json_build_object(
                'login', (select login from timeline.users limit 1)
                ,'password', (select password from timeline.users limit 1)
           )
           ,null);

