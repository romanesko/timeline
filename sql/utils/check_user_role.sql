create or replace function timeline.check_user_role(_user timeline.users, _role text) returns void language plpgsql stable as
$$
BEGIN
    if _user is null or _user.id is null then raise exception 'No user provided' using ERRCODE='ER401';  end if;
    if _role is null then raise exception 'No role provided' ;  end if;

    if lower(_user.role) != lower(_role)  then raise exception 'Wrong role for this action' using ERRCODE='ER401';  end if;

END
$$;

select timeline.check_user_role(timeline.get_user(timeline.test_token(1)),'admin');



