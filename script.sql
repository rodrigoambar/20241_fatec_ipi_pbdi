-- Active: 1714478827335@@127.0.0.1@5432@20241_fatec_ipi_pbdi_selecao@public
-- equação de segundo grau
-- if/elsif/ else
DO $$
	DECLARE
		v1 INT := fn_gera_valor_aleatorio_entre(0,2); 
		v2 INT := fn_gera_valor_aleatorio_entre(0,20);
		v3 INT := fn_gera_valor_aleatorio_entre(0,20);
		delta NUMERIC(10,2) := (v2 ^ 2) - (4 * v1 * v3);
		raizum NUMERIC(10, 2);
		raizdois NUMERIC(10, 2);
	BEGIN
		RAISE NOTICE 'O a equação é %x% + %x + % = 0', v1, U&'\00B2',v2,v3;
		IF v1 = 0 THEN
			RAISE NOTICE 'Não vai rolar a é negativo';
		ELSE
			IF delta > 0 THEN
				raizum := (v2 * -1 + |/delta) / (2 * v1);
				raizdois := (v2 * -1 - |/delta) / (2 * v1);
				RAISE NOTICE 'o valor de delta foi %, e com isso chegamos as raizes % e %', delta, raizum, raizdois;
			ELSIF delta = 0 THEN
				raizum := (v2 * -1 + |/delta) / (2 * v1);
				raizdois := (v2 * -1 - |/delta) / (2 * v1);
				RAISE NOTICE 'o valor de delta foi %, e com isso chegamos as raizes % e %', delta, raizum, raizdois;
			ELSE
				RAISE NOTICE 'sem raiz';
			
			END IF;
		END IF;
	END;
	$$
-- verificar a paridade de um número random
--if/else
-- DO $$
-- 	DECLARE
-- 		valor INT := fn_gera_valor_aleatorio_entre(1, 100);
-- 	BEGIN
-- 		RAISE NOTICE 'O valor escolhido foi % ', valor;
-- 		IF valor % 2 = 0 THEN
-- 			RAISE NOTICE 'O valor % é par', valor;
-- 		ELSE
-- 			RAISE NOTICE 'O valor % é impár', valor;
-- 		END IF;
-- 	END;
-- 	$$
--  DO $$
-- DECLARE
--     valor INT;
-- BEGIN
--     valor := fn_gera_valor_aleatorio_entre(1, 100);
--     RAISE NOTICE 'O valor gerado é %', valor;
-- 	-- reescrever usado not
--     IF valor not between 21 and 100 THEN
--         RAISE NOTICE 'A metade do valor % é %', valor, valor / 2::FLOAT;
--     END IF;
--     END;
-- 	$$
 
--IF: gerar um valor aleatório entre 1 e 100 e exibir a metade dele se ele for menor do que 20
-- DO $$
-- DECLARE
--     valor INT;
-- BEGIN
--     valor := fn_gera_valor_aleatorio_entre(1, 100);
--     RAISE NOTICE 'O valor gerado é %', valor;
-- 	-- reescrever usando o between 
--     IF valor between 1 and 20 THEN
--         RAISE NOTICE 'A metade do valor % é %', valor, valor / 2::FLOAT;
--     END IF;
--     END;
-- 	$$

-- DO $$
-- DECLARE
--     valor INT;
-- BEGIN
--     valor := fn_gera_valor_aleatorio_entre(1, 100);
--     RAISE NOTICE 'O valor gerado é %', valor;
--     IF valor <= 20 THEN
--         RAISE NOTICE 'A metade do valor % é %', valor, valor / 2::FLOAT;
--     END IF;
--     END;
-- 	$$
 
-- CREATE OR REPLACE FUNCTION
--     fn_gera_valor_aleatorio_entre(
--         lim_inferior INT,
--         lim_superior INT
--     ) RETURNS INT AS $$
--     BEGIN
--     -- 13 e 17
--     -- RANDOM () --0 <= RANDOM() < 1
--     -- 13 + RANDOM() * 4
--     RETURN lim_inferior + FLOOR(RANDOM() * (lim_superior - lim_inferior + 1))::INT;
--     END;
--     $$ LANGUAGE plpgsql;