--- ativida ap11
-- 1.1 Adicione uma tabela de log ao sistema do restaurante. Ajuste cada procedimento para que ele registre
-- - a data em que a operação aconteceu
-- - o nome do procedimento executado
CREATE TABLE log_operacoes (
    id SERIAL PRIMARY KEY,
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nome_procedimento VARCHAR(255) NOT NULL
);

CREATE OR REPLACE PROCEDURE sp_obter_notas_para_compor_o_troco(
    OUT p_resultado VARCHAR(500),
    IN p_troco INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_notas200 INT := 0;
    v_notas100 INT := 0;
    v_notas50 INT := 0;
    v_notas20 INT := 0;
    v_notas10 INT := 0;
    v_notas5 INT := 0;
    v_notas2 INT := 0;
    v_moedas1 INT := 0;
BEGIN
    v_notas200 := p_troco / 200;
    v_notas100 := (p_troco % 200) / 100;
    v_notas50 := (p_troco % 200 % 100) / 50;
    v_notas20 := (p_troco % 200 % 100 % 50) / 20;
    v_notas10 := (p_troco % 200 % 100 % 50 % 20) / 10;
    v_notas5 := (p_troco % 200 % 100 % 50 % 20 % 10) / 5;
    v_notas2 := (p_troco % 200 % 100 % 50 % 20 % 10 % 5) / 2;
    v_moedas1 := (p_troco % 200 % 100 % 50 % 20 % 10 % 5 % 2) / 1;

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_obter_notas_para_compor_o_troco');
END;
$$;

CREATE OR REPLACE PROCEDURE sp_calcular_troco(
    OUT p_troco INT,
    IN p_valor_pago_cliente INT,
    IN p_valor_total INT
) LANGUAGE plpgsql AS $$
BEGIN
    p_troco := p_valor_pago_cliente - p_valor_total;

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_calcular_troco');
END;
$$;

CREATE OR REPLACE PROCEDURE sp_fechar_pedido(
    IN p_valor_pago_pelo_cliente INT,
    IN p_codigo_pedido INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_valor_total INT;
BEGIN
    CALL sp_calcular_valor_de_um_pedido(p_codigo_pedido, v_valor_total);
    IF p_valor_pago_pelo_cliente < v_valor_total THEN
        RAISE NOTICE 'R$% insuficiente para pagar a conta de RS%', 
        p_valor_pago_pelo_cliente, v_valor_total;
    ELSE
        UPDATE pedido p SET
        data_modificacao = CURRENT_TIMESTAMP,
        status = 'fechado'
        WHERE p.cod_pedido = p_codigo_pedido;
    END IF;

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_fechar_pedido');
END;
$$;

CREATE OR REPLACE PROCEDURE sp_calcular_valor_de_um_pedido(
    IN p_codigo_pedido INT,
    OUT p_valor_total INT
) LANGUAGE plpgsql AS $$
BEGIN 
    SELECT SUM(i.valor) FROM pedido p
    INNER JOIN tp_item_pedido ip ON
    p.cod_pedido = ip.cod_pedido
    INNER JOIN tp_item i ON
    ip.cod_item = i.cod_item
    WHERE p.cod_pedido = p_codigo_pedido
    INTO p_valor_total;

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_calcular_valor_de_um_pedido');
END;
$$;

CREATE OR REPLACE PROCEDURE sp_ad_item_pedido(
    IN cod_item INT,
    IN cod_pedido INT
) LANGUAGE plpgsql AS $$
BEGIN
    -- Insere novo item
    INSERT INTO tp_item_pedido(cod_item, cod_pedido) VALUES (cod_item, cod_pedido);
    -- Atualizando data
    UPDATE pedido p SET data_modificacao = CURRENT_TIMESTAMP
    WHERE p.cod_pedido = cod_pedido;

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_ad_item_pedido');
END;
$$;

CREATE OR REPLACE PROCEDURE sp_criar_pedido(
    OUT cod_pedido INT,
    IN cod_cliente INT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO pedido(cod_cliente) VALUES (cod_cliente);
    -- Obtém o último valor gerado por serial
    SELECT LASTVAL() INTO cod_pedido;

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_criar_pedido');
END;
$$;

CREATE OR REPLACE PROCEDURE sp_cadastrar_cliente(
    IN nome VARCHAR(200),
    IN codigo INT DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN 
    IF codigo IS NULL THEN
        INSERT INTO tb_cliente(nome) VALUES (nome);
    ELSE
        INSERT INTO tb_cliente(codigo, nome) VALUES(codigo, nome);
    END IF;

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_cadastrar_cliente');
END;
$$;

--1.2 Procedimento para contar pedidos de um cliente com RAISE NOTICE
CREATE OR REPLACE PROCEDURE sp_contar_pedidos_cliente(
    IN p_cod_cliente INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_total_pedidos INT;
BEGIN
    SELECT COUNT(*) INTO v_total_pedidos
    FROM pedido
    WHERE cod_cliente = p_cod_cliente;

    RAISE NOTICE 'Total de pedidos do cliente %: %', p_cod_cliente, v_total_pedidos;

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_contar_pedidos_cliente');
END;
$$;

-- 1.3 Procedimento para contar pedidos com variável de saída
CREATE OR REPLACE PROCEDURE sp_contar_pedidos_cliente_out(
    IN p_cod_cliente INT,
    OUT p_total_pedidos INT
) LANGUAGE plpgsql AS $$
BEGIN
    SELECT COUNT(*) INTO p_total_pedidos
    FROM pedido
    WHERE cod_cliente = p_cod_cliente;

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_contar_pedidos_cliente_out');
END;
$$;

-- 1.4 Procedimento com parâmetro INOUT
CREATE OR REPLACE PROCEDURE sp_contar_pedidos_cliente_inout(
    INOUT p_cod_cliente INT
) LANGUAGE plpgsql AS $$
BEGIN
    SELECT COUNT(*) INTO p_cod_cliente
    FROM pedido
    WHERE cod_cliente = p_cod_cliente;

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_contar_pedidos_cliente_inout');
END;
$$;

-- 1.5 Procedimento com parâmetro VARIADIC
CREATE OR REPLACE PROCEDURE sp_cadastrar_clientes_variadic(
    INOUT p_mensagem TEXT,
    VARIADIC p_nomes VARCHAR[]
) LANGUAGE plpgsql AS $$
DECLARE
    v_nome VARCHAR;
BEGIN
    FOREACH v_nome IN ARRAY p_nomes
    LOOP
        INSERT INTO tb_cliente (nome) VALUES (v_nome);
    END LOOP;

    p_mensagem := 'Os clientes: ' || array_to_string(p_nomes, ', ') || ' foram cadastrados';

    -- Registrar log
    INSERT INTO log_operacoes (nome_procedimento) VALUES ('sp_cadastrar_clientes_variadic');
END;
$$;











-- -- CREATE OR REPLACE PROCEDURE sp_obter_notas_para_compor_o_troco(
-- -- 	OUT p_resultado VARCHAR(500),
-- -- 	IN p_troco INT
-- -- ) LANGUAGE plpgsql AS $$
-- -- DECLARE
-- -- 	v_notas200 INT := 0;
-- -- 	v_notas100 INT := 0;
-- -- 	v_notas50 INT := 0;
-- -- 	v_notas20 INT := 0;
-- -- 	v_notas10 INT := 0;
-- -- 	v_notas5 INT := 0;
-- -- 	v_notas2 INT := 0;
-- -- 	v_moedas1 INT := 0;
-- -- BEGIN
-- -- 	v_notas200 := p_troco / 200;
-- -- 	v_notas100 := (p_troco % 200) / 100;
-- -- 	v_notas50 := (p_troco % 200 %100) / 50;
-- -- 	v_notas20 := (p_troco %200 %100 % 50) / 20;
-- -- 	v_notas10 := (p_troco %200 %100 % 50 % 20) / 10;
-- -- 	v_notas5 := (p_troco %200 %100 % 50 % 20 % 10) / 5;
-- -- 	v_notas2 := (p_troco %200 %100 % 50 % 20 % 10 %5) / 2;
-- -- 	v_moedas1 := (p_troco %200 %100 % 50 % 20 % 10 %5 %2) / 1;
-- -- END;
-- -- $$

-- -- DO $$
-- -- DECLARE
-- -- 	v_troco INT;
-- -- 	v_valor_pago_cliente INT := 100;
-- -- 	v_valor_total INT;
-- -- BEGIN
-- -- 	CALL sp_calcular_valor_de_um_pedido(1, v_valor_total);
-- -- 	CALL sp_calcular_troco(
-- -- 		v_troco, 
-- -- 		v_valor_pago_cliente,
-- -- 		v_valor_total);
-- -- 	RAISE NOTICE 'A conta foi de R$% e você pagou R$%. Assim retornando R$%
-- -- 	de troco', v_valor_total, v_valor_pago_cliente, v_troco;
-- -- END;
-- -- $$


-- -- --calcular o troco
-- CREATE OR REPLACE PROCEDURE sp_calcular_troco(
-- 	OUT p_troco INT,
-- 	IN p_valor_pago_cliente INT,
-- 	IN p_valor_total INT
-- ) LANGUAGE plpgsql AS $$
-- BEGIN
-- 	p_troco := p_valor_pago_cliente - p_valor_total;
-- END;
-- $$


-- -- CALL sp_fechar_pedido(19, 1);
-- -- CALL sp_fechar_pedido(18, 1);
-- -- SELECT * FROM pedido;

-- CREATE OR REPLACE PROCEDURE sp_fechar_pedido(
-- 	IN p_valor_pago_pelo_cliente INT,
-- 	IN p_codigo_pedido INT
-- ) LANGUAGE plpgsql
-- AS $$
-- DECLARE
-- 	v_valor_total INT;
-- BEGIN
-- 	CALL sp_calcular_valor_de_um_pedido(
-- 	p_codigo_pedido,
-- 	v_valor_total
-- 	);
-- 	IF p_valor_pago_pelo_cliente < v_valor_total THEN
-- 		RAISE NOTICE 'R$% insuficiente para pagar a conta de RS%', 
-- 		p_valor_pago_pelo_cliente, v_valor_total;
-- 	ELSE
-- 		UPDATE pedido p SET
-- 		data_modificacao = CURRENT_TIMESTAMP,
-- 		status = 'fechado'
-- 		WHERE p.cod_pedido = $2;
-- 	END IF;
-- END;
-- $$

-- -- DO $$
-- -- DECLARE
-- -- 	v_valor_total INT;
-- -- BEGIN
-- -- 	CALL sp_calcular_valor_de_um_pedido(1, v_valor_total);
-- -- 	RAISE NOTICE 'Total do pedido : % R$%', 1, v_valor_total;
-- -- END;
-- -- $$
-- -- -- calculo o valor total de um pedido
-- CREATE OR REPLACE PROCEDURE sp_calcular_valor_de_um_pedido(
-- 	IN p_codigo_pedido INT,
-- 	OUT p_valor_total INT
-- ) LANGUAGE plpgsql
-- AS $$
-- BEGIN 
-- 	SELECT SUM(i.valor) FROM pedido p
-- 	INNER JOIN tp_item_pedido ip ON
-- 	p.cod_pedido = ip.cod_pedido
-- 	INNER JOIN tp_item i ON
-- 	ip.cod_item = i.cod_item
-- 	WHERE p.cod_pedido = $1
-- 	INTO $2;
-- END;
-- $$

-- CREATE OR REPLACE PROCEDURE sp_ad_item_pedido(
-- 	IN cod_item INT,
-- 	IN cod_pedido INT
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
-- 	--insere novo item
-- 	INSERT INTO tp_item_pedido(cod_item, cod_pedido) VALUES ($1, $2);
-- 	---- atualizando data
-- 	UPDATE pedido p SET data_modificacao = CURRENT_TIMESTAMP
-- 	WHERE p.cod_pedido = $2;
-- END;
-- $$

-- -- CALL sp_ad_item_pedido(1,1);
-- -- CALL sp_ad_item_pedido(3, 1);
-- -- SELECT * FROM tp_item_pedido;
-- -- SELECT * FROM pedido;

-- CREATE OR REPLACE PROCEDURE sp_criar_pedido(
-- OUT cod_pedido INT,
-- cod_cliente INT
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
-- 	INSERT INTO pedido(cod_cliente) VALUES (cod_cliente);
-- 	-- obtem o ultimo valor gerado por serial
-- 	SELECT LASTVAL() INTO cod_pedido;
-- END;
-- $$

-- -- DO $$
-- -- DECLARE
-- -- 	-- para guardar o código de pedido gerado
-- -- 	cod_pedido INT;
-- -- 	-- o código do cliente que vai fazer o pedido
-- -- 	cod_cliente INT;
-- -- BEGIN
-- -- 	--pegando o código da pessoa cujo se chama joão da silva
-- -- 	SELECT c.cod_cliente FROM tb_cliente c
-- -- 	WHERE nome LIKE 'João da Silva' INTO cod_cliente;
-- -- 	CALL sp_criar_pedido(cod_pedido, cod_cliente);
-- -- 	RAISE NOTICE 'Código pedido recém criado: %', cod_pedido;
-- -- END;
-- -- $$
	
-- CREATE OR REPLACE PROCEDURE sp_cadastrar_cliente(
-- 	IN nome VARCHAR(200),
-- 	IN codigo INT DEFAULT NULL)
-- 	LANGUAGE plpgsql
-- 	AS $$
-- 	BEGIN 
-- 		IF codigo IS NULL THEN
-- 			INSERT INTO tb_cliente(nome) VALUES (nome);
-- 		ELSE
-- 			INSERT INTO tb_cliente(codigo, nome) VALUES(codigo, nome);
-- 		END IF;
-- 	END;
-- 	$$
-- CALL sp_cadastrar_cliente('João da Silva');
-- CALL sp_cadastrar_cliente('Maria Santos');

-- --SISTEMA restaurante
-- CREATE TABLE tb_cliente(
-- 	cod_cliente SERIAL PRIMARY KEY,
-- 	nome VARCHAR(200) NOT NULL
-- );

-- CREATE TABLE pedido(
-- 	cod_pedido SERIAL PRIMARY KEY,
-- 	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- 	data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- 	status VARCHAR DEFAULT 'aberto',
-- 	cod_cliente INT NOT NULL,
-- 	CONSTRAINT fk_cliente FOREIGN KEY (cod_cliente) REFERENCES 
-- 	tb_cliente(cod_cliente)
-- );
-- CREATE TABLE tp_tipo_item(
-- 	cod_tipo SERIAL PRIMARY KEY,
-- 	descricao VARCHAR(200) NOT NULL 
-- );
-- INSERT INTO tp_tipo_item (descricao) VALUES ('Bebida'), ('Comida');

-- CREATE TABLE tp_item(
--     cod_item SERIAL PRIMARY KEY,
--     descricao_item VARCHAR(200) NOT NULL,
--     valor NUMERIC(10, 2) NOT NULL,
--     cod_tipo INT NOT NULL,
--     CONSTRAINT fk_tipo_item FOREIGN KEY (cod_tipo) REFERENCES tp_tipo_item(cod_tipo)
-- );
-- INSERT INTO tp_item (descricao_item, valor, cod_tipo) VALUES
-- ('Refrigerante', 7, 1), ('Suco', 8, 1), ('Hamburguer', 12, 2), ('Batata frita', 9, 2);

-- CREATE TABLE tp_item_pedido(
--     cod_item_pedido SERIAL PRIMARY KEY,
--     cod_item INT,
--     cod_pedido INT,
--     CONSTRAINT fk_item FOREIGN KEY (cod_item) REFERENCES tp_item (cod_item),
--     CONSTRAINT fk_pedido FOREIGN KEY (cod_pedido) REFERENCES pedido (cod_pedido)
-- );

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