-- SISTEMA restaurante
CREATE TABLE tb_cliente(
	cod_cliente SERIAL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL
);

CREATE TABLE pedido(
	cod_pedido SERIAL PRIMARY KEY,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	status VARCHAR DEFAULT 'aberto',
	cod_cliente INT NOT NULL,
	CONSTRAINT fk_cliente FOREIGN KEY (cod_cliente) REFERENCES 
	tb_cliente(cod_cliente)
);
CREATE TABLE tp_tipo_item(
	cod_tipo SERIAL PRIMARY KEY,
	descricao VARCHAR(200) NOT NULL 
);

CREATE TABLE tp_item(
    cod_item SERIAL PRIMARY KEY,
    descricao_item VARCHAR(200) NOT NULL,
    valor NUMERIC(10, 2) NOT NULL,
    cod_tipo INT NOT NULL,
    CONSTRAINT fk_tipo_item FOREIGN KEY (cod_tipo) REFERENCES tp_tipo_item(cod_tipo)
);

CREATE TABLE tp_item_pedido(
    cod_item_pedido SERIAL PRIMARY KEY,
    cod_item INT,
    cod_pedido INT,
    CONSTRAINT fk_item FOREIGN KEY (cod_item) REFERENCES tp_item (cod_item),
    CONSTRAINT fk_pedido FOREIGN KEY (cod_pedido) REFERENCES pedido (cod_pedido)
);

--parâmetros variadic
-- CREATE OR REPLACE PROCEDURE sp_calcula_media(
-- 	VARIADIC valores INT[]
-- ) LANGUAGE plpgsql
-- AS $$
-- DECLARE
-- 	media NUMERIC(10, 2) := 0;
-- 	valor INT;
-- BEGIN
-- 	FOREACH valor IN ARRAY valores LOOP
-- 		media := media + valor;
-- 		END LOOP;
-- 		RAISE NOTICE 'A média é: %', FLOOR(media/ array_length(valores, 1));
-- END;
-- $$
-- CALL sp_calcula_media(1, 2, 4, 5, 6, 8, 10);
--DROP PROCEDURE IF EXISTS sp_acha_maior;
-- CREATE OR REPLACE PROCEDURE sp_acha_maior(
-- 	INOUT valor1 INT,
-- 	IN valor2 INT
-- ) LANGUAGE plpgsql
-- AS $$
-- 	BEGIN
-- 		IF valor2 > valor1 THEN
-- 			valor1 := valor2;
-- 		END IF;
-- 	END;
-- $$
-- -- código cliente: código que executa 
-- DO $$
-- DECLARE
-- 	valor1 INT := 5;
-- BEGIN
-- 	CALL sp_acha_maior(valor1, 10);
-- 	RAISE NOTICE 'O maior é:  %', valor1;
-- END;
-- $$
-- CREATE OR REPLACE PROCEDURE sp_acha_maior(
-- 	OUT resultado INT,
-- 	IN valor1 INT,
-- 	IN valor2 INT
-- ) LANGUAGE plpgsql
-- AS $$
-- BEGIN
-- 	CASE
-- 		WHEN valor1 > valor2 THEN
-- 			resultado := valor1;
-- 		ELSE
-- 			resultado := valor2;
-- 	END CASE;
-- END;
-- $$
-- -- executando
-- DO $$
-- DECLARE
-- 	resultado INT;
-- BEGIN
-- 	CALL sp_acha_maior(resultado, 2, 3);
-- 	RAISE NOTICE 'Maior: %', resultado;
-- END;
-- $$;

-- CREATE OR REPLACE PROCEDURE sp_acha_maior(
-- 	IN valor1 INT,
-- 	IN valor2 INT
-- ) LANGUAGE plpgsql 
-- AS $$
-- BEGIN 
-- 	IF valor1 > valor2 THEN
-- 		RAISE NOTICE '% é o maior', $1;
-- 	ELSE
-- 		RAISE NOTICE '% é o maior', $2;
-- 	END IF;
	
-- END;
-- $$ --- metódo in 

-- CALL sp_acha_maior(2, 3);