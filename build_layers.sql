CREATE EXTENSION temporal_tables;

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
coalesce(overlay.muppets.spooky, foundation.muppets.spooky) as spooky
from foundation.muppets
left join overlay.muppets on (overlay.muppets.foundation = foundation.muppets.id);



insert into foundation.muppets (name, color, spooky) values ('Kermet', 'grey', false) returning id;
insert into foundation.muppets (name, spooky)        values ('Gonzu', true) returning id;
insert into foundation.muppets (name, color, spooky) values ('Snarfalopogus', 'blue', true) returning id;
insert into foundation.muppets (name, color, spooky) values ('Barker', 'yellow', false) returning id;
insert into foundation.muppets (name, color, spooky) values ('Arminal', 'red', false) returning id;
insert into foundation.muppets (name, color, spooky) values ('French Chef', 'Fork Fork Fork', false) returning id;

select * from muppets;

insert into overlay.muppets (foundation, name)                values (1, 'Kermit the Frog');
insert into overlay.muppets (foundation, color, name)         values (2, 'blue', 'Gonzo the Great');
insert into overlay.muppets (foundation, name, color, spooky) values (3, 'Mr. Snuffalupagus', 'red', false);
insert into overlay.muppets (foundation, name, color)         values (4, 'Beaker', 'pink');
insert into overlay.muppets (foundation, name, spooky)        values (5, 'Animal', true);
insert into overlay.muppets (foundation, name, color)         values (6, 'Swedish Chef', 'Bork, Bork, Bork!');

select * from muppets;

-- insert into overlay.muppets (foundation, color, name) values (2, 'black','Gonzo the Great');  -- should fail
-- delete from foundation.muppets where id = 1; -- show cascade delete

select * from overlay.muppets;

update overlay.muppets set color = 'green' where foundation = 1;

select * from overlay.muppets;
select * from overlay.muppets_history;