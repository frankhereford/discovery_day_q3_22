drop table foundation;
create table foundation (
    id serial primary key,
    name character varying,
    color character varying,
    spooky boolean);
    
drop table overlay;
create table overlay (
    id serial primary key,
    foundation integer,
    name character varying,
    color character varying,
    spooky boolean);
    

insert into foundation (name, color, spooky) values ('Kermit', 'green', false);
select * from foundation;

insert into overlay (foundation, name) values (1, 'Kermit the Frog');


select 
coalesce(overlay.name, foundation.name) as name,
coalesce(overlay.color, foundation.color) as color,
coalesce(overlay.spooky, foundation.spooky) as spooky
from foundation
left join overlay on (overlay.foundation = foundation.id);


truncate overlay;