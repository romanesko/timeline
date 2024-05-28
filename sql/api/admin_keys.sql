create or replace function timeline.admin_keys(params json, _token uuid) returns json language plpgsql stable as
$$
DECLARE
    _response JSON;
    _user timeline.users;
BEGIN
    _user = timeline.get_user(_token);
    perform timeline.check_user_role(_user, 'admin');

    select json_agg(a) into _response from (select id, name, token from timeline.users where role = 'system' )a;

    RETURN coalesce(_response,'[]');
END
$$;

select timeline.admin_keys(
           json_build_object(

           )
           ,timeline.test_token(1))

