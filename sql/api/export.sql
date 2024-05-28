/*
 const timeline = [
 {
  'date': '2024-05-20',
  'schedule': [
    {
     'startTime': '08:00',
     'endTime': '09:00',
     'isGrouped': true,
     'spotAmount': 4,
     'spotType': 1,
     'spotTypeText': 'Массовое катание',
     'trainer': 5,
     'trainerText': 'Сидоров В.А.',
     'comment': 'Школа 39, учитель Анна +79654123654'
    },
   {
    'startTime': '10:00',
    'endTime': '10:50',
    'isGrouped': false,
    'spotAmount': 1,
    'spotType': 2,
    'spotTypeText': 'Заливка',
    'trainer': null,
    'trainerText': null,
    'comment': 'Залить на отлично нахуй'
   }
  ]
 }
]
 */

create or replace function timeline.export(params json, _token uuid) returns json language plpgsql stable as
$$
DECLARE
    _user timeline.users;
    _zone_id int = 1;
    _types jsonb;
    _tags jsonb;
    _min_date date;
    _max_date date;
    _day_rec record;
    _sc_records jsonb;

    all_items jsonb[];

BEGIN

    if _token is null then
        _token = optionalUUID(params,'token');
    end if;

    _user = timeline.get_user(_token);

    _zone_id = requireInt(params,'zone');
    _min_date = requireDate(params,'from');
    _max_date = requireDate(params,'to');

    SELECT jsonb_object_agg(element->>'id', element) into _types FROM ( SELECT jsonb_array_elements(z.types) AS element FROM timeline.zones z where id = _zone_id) a;
    SELECT jsonb_object_agg(element->>'id', element) into _tags FROM ( SELECT jsonb_array_elements(z.tags) AS element FROM timeline.zones z where id = _zone_id) a;

    raise notice 'tags %', _tags;

    for _day_rec in (select a.date from (select date from timeline.values v where v.zone=_zone_id and v.date >= _min_date and v.date<=_max_date group by date) a order by a.date)  loop

        select json_agg(a) into _sc_records from (
            select time as "startTime",
            time + INTERVAL '1 minutes' * ((value->>'length')::int * 15) as "endTime",
            ((value->>'length')::int)>1 as "isGrouped",
            ((value->>'length')::int) as "spotAmount",
            (value->>'type')::int as "spotType",
            (_types->(value->>'type'))->>'label' as "spotTypeText",
            value->>'comment' as "comment",
            (select jsonb_agg(c) from ( select a.id as trainer, (_tags->(a.id::text))->>'label' as "trainerText" from (select jsonb_array_elements(value->'tags')::int as id) a) c ) as trainers
            from timeline.values v
            where v.zone = _zone_id and date = _day_rec.date and not (value ? 'h') and value->>'type' is not null order by time) a;

        raise notice '%', jsonb_build_object('date', _day_rec.date, 'schedule', _sc_records);
        all_items = all_items || jsonb_build_object('date', _day_rec.date, 'schedule', _sc_records) ;
    end loop;


    RETURN coalesce(to_jsonb(all_items),'[]');
END
$$;

select timeline.export(json_build_object('zone',1,'from', '2024-01-01','to','2024-05-30'),timeline.test_token(2));
select timeline.export('{"from":"2024-05-28","to":"2024-05-28","zone":1}'::json, '90e109c7-207e-4f44-8c32-40694e986327'::uuid);

-- select * from timeline.values v where  not (value ? 'h') order by time