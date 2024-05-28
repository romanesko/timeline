CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

create schema timeline;

drop table if exists timeline.users cascade ;
create table timeline.users(
    id serial primary key ,
    name text not null ,
    login text not null unique ,
    password text not null ,
    role text not null ,
    token uuid not null default public.uuid_generate_v4()

);

insert into timeline.users(name, login,  password,role) values ('admin','admin', '1234','admin');
insert into timeline.users(name, login, password, role) values ('main',uuid_generate_v4()::text, uuid_generate_v4()::text,'system');

drop table if exists timeline.zones;
create table timeline.zones(
    id serial primary key ,
    label text not null ,
    types jsonb not null default '[]'::jsonb,
    tags jsonb not null default '[]'::jsonb
);


insert into timeline.zones(label, types, tags) values
('Ледовая арена', '[ { "id": 1, "label": "Свободное катание", "color": "rgb(63, 131, 248)" }, { "id": 2, "label": "Тренировка дети", "color": "rgb(14, 159, 110)" }, { "id": 3, "label": "Тренировка взрослые", "color": "rgb(6, 182, 212)" }, { "id": 4, "label": "Технический перерыв", "color": "rgb(100, 100, 100)" }, { "id": 5, "label": "Внутренний резерв", "color": "rgb(6, 148, 162)" }]', '[]')
-- ('Бассейн: дорожка 1', '[{"id": 6,"label": "Свободное плавание","color": "rgb(63, 131, 248)"},{"id": 7,"label": "Групповая: дети","color": "rgb(14, 159, 110)"},{"id": 8,"label": "Групповая: взрослые","color": "rgb(6, 182, 212)"},{"id": 9,"label": "Персональная: дети","color": "rgb(250, 14, 110)"},{"id": 10,"label": "Персональная: взрослые","color": "rgb(126, 182, 212)"},{"id": 11,"label": "Технический перерыв","color": "rgb(100, 100, 100)"}]', '[{"id": 5, "label": "Пых Т.У."},{"id": 6, "label": "Инвертер Г.А."},{"id": 7, "label": "Дуло Е.В."}]'),
-- ('Бассейн: дорожка 2', '[{"id": 6,"label": "Свободное плавание","color": "rgb(63, 131, 248)"},{"id": 7,"label": "Групповая: дети","color": "rgb(14, 159, 110)"},{"id": 8,"label": "Групповая: взрослые","color": "rgb(6, 182, 212)"},{"id": 9,"label": "Персональная: дети","color": "rgb(250, 14, 110)"},{"id": 10,"label": "Персональная: взрослые","color": "rgb(126, 182, 212)"},{"id": 11,"label": "Технический перерыв","color": "rgb(100, 100, 100)"}]', '[{"id": 5, "label": "Пых Т.У."},{"id": 6, "label": "Инвертер Г.А."},{"id": 7, "label": "Дуло Е.В."}]'),
-- ('Бассейн: дорожка 3', '[{"id": 6,"label": "Свободное плавание","color": "rgb(63, 131, 248)"},{"id": 7,"label": "Групповая: дети","color": "rgb(14, 159, 110)"},{"id": 8,"label": "Групповая: взрослые","color": "rgb(6, 182, 212)"},{"id": 9,"label": "Персональная: дети","color": "rgb(250, 14, 110)"},{"id": 10,"label": "Персональная: взрослые","color": "rgb(126, 182, 212)"},{"id": 11,"label": "Технический перерыв","color": "rgb(100, 100, 100)"}]', '[{"id": 5, "label": "Пых Т.У."},{"id": 6, "label": "Инвертер Г.А."},{"id": 7, "label": "Дуло Е.В."}]');
;

drop table if exists timeline.values;
create table timeline.values(
    zone int not null,
    date date not null,
    time time not null,
    value jsonb not null,
    primary key (zone,date,time)

)