drop schema foundation cascade;
create schema foundation;

drop schema overlay cascade;
create schema overlay;

create table foundation.muppets (
    id serial primary key,
    name character varying,
    color character varying,
    spooky boolean);
    
create table overlay.muppets (
    id serial primary key,
    foundation integer references foundation.muppets(id) on delete cascade,
    name character varying,
    color character varying,
    spooky boolean,
    constraint unique_foundation unique (foundation));
    


drop view if exists muppets;
create view muppets as
select 
foundation.muppets.id,
coalesce(overlay.muppets.name, foundation.muppets.name) as name,
coalesce(overlay.muppets.color, foundation.muppets.color) as color,
coalesce(overlay.muppets.spooky, foundation.muppets.spooky) as spooky
from foundation.muppets
left join overlay.muppets on (overlay.muppets.foundation = foundation.muppets.id);

select * from muppets;


insert into foundation.muppets (name, color, spooky) values ('Kermet', 'grey', false) returning id;
insert into foundation.muppets (name, spooky) values ('Gonzu', true) returning id;
insert into foundation.muppets (name, color, spooky) values ('Snarfalopogus', 'blue', true) returning id;
insert into foundation.muppets (name, color, spooky) values ('Barker', 'yellow', false) returning id;
insert into foundation.muppets (name, color, spooky) values ('Animal', 'red', true) returning id;
insert into foundation.muppets (name, color, spooky) values ('Swedish Chef', 'Bork', false) returning id;


insert into overlay.muppets (foundation, name) values (1, 'Kermit the Frog');
update overlay.muppets set color = 'green' where foundation = 1;

insert into overlay.muppets (foundation, color, name) values (2, 'blue', 'Gonzo the Great');
insert into overlay.muppets (foundation, name, color, spooky) values (3, 'Mr. Snuffalupagus', 'red', false);
insert into overlay.muppets (foundation, name, color, spooky) values (4, 'Beaker', 'pink', false);
-- insert into overlay.muppets (foundation, color, name) values (2, 'black','Gonzo the Great');  -- should fail

--delete from foundation.muppets where id = 1; -- show cascade delete