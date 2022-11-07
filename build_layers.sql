CREATE EXTENSION temporal_tables;

drop schema foundation cascade;
create schema foundation;

drop schema overlay cascade;
create schema overlay;

create table foundation.muppets (
    id serial primary key,
    name character varying,
    color character varying,
    spooky boolean,
    age integer);
    
create table overlay.muppets (
    id serial primary key,
    foundation integer references foundation.muppets(id) on delete cascade,
    name character varying,
    color character varying,
    spooky boolean,
    age integer,
    sys_period tstzrange not null,
    constraint unique_foundation unique (foundation));
    
    
create table overlay.muppets_history (like overlay.muppets);


CREATE TRIGGER versioning_trigger
BEFORE INSERT OR UPDATE OR DELETE ON overlay.muppets
FOR EACH ROW EXECUTE PROCEDURE versioning('sys_period',
                                          'overlay.muppets_history',
                                          true);

                                        
drop view if exists muppets;
create view muppets as
select 
foundation.muppets.id,
coalesce(overlay.muppets.name, foundation.muppets.name) as name,
coalesce(overlay.muppets.color, foundation.muppets.color) as color,
coalesce(overlay.muppets.spooky, foundation.muppets.spooky) as spooky,
coalesce(overlay.muppets.age, foundation.muppets.age) as age,
case 
  when coalesce(overlay.muppets.age, foundation.muppets.age) is not null and coalesce(overlay.muppets.age, foundation.muppets.age) < 75
  then 75 - coalesce(overlay.muppets.age, foundation.muppets.age)
  when coalesce(overlay.muppets.age, foundation.muppets.age) is not null and coalesce(overlay.muppets.age, foundation.muppets.age) >= 75
  then 0
  else null 
end as years_life_lost
from foundation.muppets
left join overlay.muppets on (overlay.muppets.foundation = foundation.muppets.id);



insert into foundation.muppets (name, color, spooky, age) values ('Kermet', 'grey', false, 42) returning id;
insert into foundation.muppets (name, spooky, age)        values ('Gonzu', true, 21) returning id;
insert into foundation.muppets (name, color, spooky) values ('Snarfalopogus', 'blue', true) returning id;
insert into foundation.muppets (name, color, spooky, age) values ('Barker', 'yellow', false, 79) returning id;
insert into foundation.muppets (name, color, spooky, age) values ('Arminal', 'red', false, 45) returning id;
insert into foundation.muppets (name, color, spooky, age) values ('French Chef', 'Fork Fork Fork', false, 35) returning id;

select * from muppets;

insert into overlay.muppets (foundation, name)                values (1, 'Kermit the Frog');
insert into overlay.muppets (foundation, color, name, age)         values (2, 'blue', 'Gonzo the Great', 22);
insert into overlay.muppets (foundation, name, color, spooky, age) values (3, 'Mr. Snuffalupagus', 'red', false, 56);
insert into overlay.muppets (foundation, name, color, age)         values (4, 'Beaker', 'pink', 80);
insert into overlay.muppets (foundation, name, spooky, age)        values (5, 'Animal', true, 46);
insert into overlay.muppets (foundation, name, color, age)         values (6, 'Swedish Chef', 'Bork, Bork, Bork!', 36);

select * from muppets;

-- insert into overlay.muppets (foundation, color, name) values (2, 'black','Gonzo the Great');  -- should fail
-- delete from foundation.muppets where id = 1; -- show cascade delete

select * from overlay.muppets;

update overlay.muppets set color = 'green' where foundation = 1;

select * from overlay.muppets;
select * from overlay.muppets_history;
