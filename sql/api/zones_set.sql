create or replace function timeline.zones_set(params json, _token uuid) returns json language plpgsql volatile as
$$
DECLARE
    _id int;
    _user timeline.users;
BEGIN
    _user = timeline.get_user(_token);
    _id= optionalInt(params,'id');

    perform timeline.check_user_role(_user, 'admin');

    if _id is null then
        insert into timeline.zones(label,types,tags) values ('','[]','[]') returning  id into _id;
    end if;


    update timeline.zones set
        label = requireText(params,'label'),
        types = requireJsonb(params,'types'),
        tags = requireJsonb(params, 'tags')
    where id =_id;

    RETURN json_build_object('id',_id);
END
$$;

-- select timeline.zones_set('{"id":1,"label":"Ледовая арена","types":[{"id":1,"color":"#3f83f8","label":"Свободное катание"},{"id":2,"color":"#0e9f6e","label":"Тренировка дети"},{"id":3,"color":"#06b6d4","label":"Тренировка взрослые"},{"id":4,"color":"#646464","label":"Технический перерыв"},{"id":5,"color":"#0694a2","label":"Внутренний резерв"}],"tags":[{"id":1,"label":"Иванов И.И."},{"id":2,"label":"Петров П.П."},{"id":3,"label":"Васильева Е.Е."},{"id":4,"label":"Сидорова А.Б"}]}',timeline.test_token(1))