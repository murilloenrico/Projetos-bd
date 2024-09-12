create schema biblioteca;
use biblioteca;

create table usuarios(
id_usuario int not null,
nome varchar (45),
sobrenome varchar (45),
data_nascimento date,
cpf int,
constraint id_usuariopk primary key (id_usuario));

insert into usuarios(id_usuario,nome,sobrenome,data_nascimento,cpf)
values ("1","Murillo", "Enrico","21/02/1998","5452454245");

select * from usuarios;


create table livro(
id_livro int not null,
nome varchar (45),
autor varchar (45),
constraint id_livropk primary key (id_livro));

insert into livro(id_livro,nome,autor)
values ("1","Pequeno Principe", "Joelma");


select * from livro;


create table emprestimo(
id_emprestimo int not null,
id_elivro int,
id_eusuario int,
constraint id_emprestimopk primary key (id_emprestimo),
constraint id_elivrofk foreign key (id_elivro) references livro (id_livro),
constraint id_eusuariofk foreign key (id_eusuario) references usuarios (id_usuario));

insert into emprestimo(id_emprestimo,id_elivro,id_eusuario)
values ("1","1","1");

create table multa(
id_multa int not null,
id_musuario int,
valor_multa decimal (10,2),
data_multa date,
constraint id_multapk primary key (id_multa),
constraint id_musuariofk foreign key (id_musuario) references usuarios (id_usuario));

insert into multa(id_multa,id_musuario,valor_multa,data_multa)
values ("1", "1","20","2024/09/30");

create table devolucoes(
id_devolucoes int not null,
id_dlivro int,
id_dusuario int,
data_devolucao date,
data_devolucao_esperada date,
constraint id_devolucoespk primary key (id_devolucoes),
constraint id_dlivrofk foreign key (id_dlivro) references livro (id_livro),
constraint id_dusuariofk foreign key (id_dusuario) references usuarios (id_usuario));

insert into devolucoes(id_devolucoes,id_dlivro,id_dusuario,data_devolucao,data_devolucao_esperada) 
values ("1", "1", "1", "2024/10/09", "2024/10/10");


create table livros_atualizados(
id_livro_atualizado int not null,
id_llivro int,
titulo varchar (100),
autor varchar (300),
data_atualizacao datetime default current_timestamp,
constraint id_livro_atualizadopk primary key (id_livro_atualizado),
constraint id_llivrofk foreign key (id_llivro) references livro (id_livro));

insert into livros_atualizados(id_livro_atualizado,id_llivro,titulo,autor,data_atualizacao)
values ("1", "1", "Pequeno Principe", "Joelma", "2024/10/01");


create table livros_excluido(
id_livro_excluido int primary key,
id_lelivro int,
titulo varchar (110),
autor varchar (110),
dataExclusao datetime default current_timestamp,
constraint id_lelivrofk foreign key (id_lelivro) references livro (id_livro));

Insert into livros_excluido(id_livro_excluido,id_lelivro,titulo,autor,dataExclusao)
values ("1", "1", "Pequeno Principe","Joelma", 2024-09-10);

create table mensagem (
Id_mensagem int primary key,
assunto varchar (45),
corpo varchar (45));

insert into mensagem(id_mensagem,assunto,corpo)
values("1","Data da devolução em breve","Devolução");


DELIMITER 
CREATE TRIGGER Trigger_GerarMulta AFTER INSERT ON devolucoes​
FOR EACH row
begin
declare atraso INT;
declare valor_multa DECIMAL(10, 2);​
SET atraso = DATEDIFF(NEW.data_dvolucao_esperada, NEW.data_devolucao);​
    IF atraso > 0 THEN​
        SET valor_multa = atraso * 2.00;​
        INSERT INTO Multas (id_usuario, valor_multa, data_multa)​
        VALUES (NEW.id_Usuario, valor_multa, NOW());​
    END IF;​
END;
DELIMITER//;






DELIMITER //​
CREATE TRIGGER Trigger_VerificarAtrasos​
BEFORE INSERT ON devolucoes
for each row
begin
    declare atraso INT;​
    set atraso = DATEDIFF(NEW.data_devolucao_esperada, NEW.data_devolucao);​
    if atraso > 0 THEN​
        INSERT INTO Mensagens (id_mensagem, assunto, corpo)​
        VALUES ('Bibliotecário', 'Alerta de Atraso', CONCAT('O livro com ID ', NEW.ID_livro, ' não foi devolvido na data de devolução esperada.'));​
    END IF;​
END;​
DELIMITER //;


DELIMITER //
CREATE TRIGGER Trigger_AtualizarStatusEmprestado​
AFTER INSERT ON emprestimo
FOR EACH ROW​
BEGIN​
    UPDATE livro
    SET StatusLivro = 'Emprestado'​
    WHERE ID = NEW.id_livro;​
END;​
DELIMITER //;



DELIMITER //​
CREATE TRIGGER Trigger_AtualizarTotalExemplares​
AFTER INSERT ON livro
FOR EACH ROW​
BEGIN​
    UPDATE Livros​
    SET TotalExemplares = TotalExemplares + 1​
    WHERE ID = NEW.ID;​
END;​
DELIMITER //;




DELIMITER //​
CREATE TRIGGER Trigger_RegistrarAtualizacaoLivro​
AFTER UPDATE ON livro
FOR EACH ROW​
BEGIN​
    INSERT INTO Livros_Atualizados (id_Livro, titulo, autor, data_atualizacao)​
    VALUES (OLD.id_livro, OLD.Titulo, OLD.Autor, NOW());​
END;​
DELIMITER // ;



DELIMITER //
CREATE TRIGGER Trigger_RegistrarExclusaoLivro​
AFTER DELETE ON livro
FOR each row
BEGIN​
    INSERT INTO Livros_Excluidos (id_Livro, titulo, autor, data_exclusao)​
    VALUES (OLD.id_livro, OLD.titulo, OLD.autor, NOW());​
END;​
DELIMITER // ;

DELIMITER $$

CREATE PROCEDURE buscar_livro(
    IN p_id_livro INT
)
BEGIN
    -- Seleciona informações do livro com base no ID fornecido
    SELECT 
        id_livro AS "ID do Livro",
        nome AS "Nome",
        autor AS "Autor"
    FROM livro
    WHERE id_livro = p_id_livro;
END$$

DELIMITER ;


CALL buscar_livro(2);


DELIMITER $$

CREATE PROCEDURE inserir_livro(
    IN p_id_livro INT,
    IN p_nome VARCHAR(45),
    IN p_autor VARCHAR(45)
)
BEGIN
    -- Verifica se o ID do livro já existe
    IF EXISTS (SELECT 1 FROM livro WHERE id_livro = p_id_livro) THEN
        -- Se o ID já existir, levanta um erro
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O ID do livro já existe.';
    ELSE
        -- Caso contrário, insere o novo livro na tabela
        INSERT INTO livro (id_livro, nome, autor)
        VALUES (p_id_livro, p_nome, p_autor);
    END IF;
END$$

DELIMITER ;

CALL inserir_livro(2, 'Dom Casmurro', 'Machado de Assis');
