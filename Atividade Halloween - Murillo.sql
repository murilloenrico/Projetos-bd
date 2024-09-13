create schema halloween;
use halloween;

create table usuarios(
nome varchar (30),
email varchar(50),
idade int);


Delimiter $$
create procedure InsereUsuariosAleatorios()
Begin
Declare i int default 0;
while i < 10000 DO
set @nome := CONCAT('Usuario', i);
set @email := CONCAT('usuario',i,'@hotmail.com');
set @idade := FLOOR(RAND() * 80) + 18;

insert into usuarios (nome,email,idade)
values (@nome,@email,@idade);

set i = i+1;
end while;
end $$

Delimiter $$ 

call InsereUsuariosAleatorios ();

select * from usuarios;