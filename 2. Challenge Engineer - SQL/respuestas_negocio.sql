
--################################### Exercicio 1 #################################################

-- Resposta Exercicio 1. Peguei principais informações dos clientes com aniversario hoje
-- Juntando as tabelas de Cliente com Ordens e contando quantas ordens tiveram em Jan/2020
SELECT  CL.ID_CLIENTE, 
        CL.DATA_NASCIMENTO,
        CL.NOME, 
        CL.SOBRENOME,
        CL.EMAIL,
        COUNT(ORD.ID_ORDEM) AS QUANTIDADE_VENDAS
FROM CLIENTE AS CL
LEFT JOIN ORDEM AS ORD 
ON CL.ID_CLIENTE = ORD.ID_VENDEDOR
WHERE 1 = 1
AND CONCAT(MONTH(CL.DATA_NASCIMENTO), '-',DAY(CL.DATA_NASCIMENTO)) = CONCAT(MONTH(CURDATE()), '-',DAY(CURDATE()))
AND YEAR(ORD.DATA_ORDEM) = 2020
AND MONTH(ORD.DATA_ORDEM) = 1
AND ORD.STATUS_ORDEM = 'COMPLETO'
GROUP BY CL.ID_CLIENTE, CL.DATA_NASCIMENTO, CL.NOME, CL.SOBRENOME
HAVING QUANTIDADE_VENDAS > 1500
;

--################################### Exercicio 2 #################################################


-- Criar uma tabela temporaria para separar vendas de celular
CREATE TABLE VENDAS_CELULARES AS
SELECT  CL.ID_CLIENTE,
        CL.NOME,
        CL.SOBRENOME,
        ORD.DATA_ORDEM,
        ORD.QUANTIDADE,
        ORD.VALOR_TOTAL,
        IT.ID_CATEGORIA,
        IT.NOME_ITEM,
        CAT.DESCR_CATEGORIA
FROM ORDEM AS ORD
LEFT JOIN CLIENTE AS CL ON ORD.ID_VENDEDOR = CL.ID_CLIENTE
LEFT JOIN ITEM AS IT ON ORD.ID_ITEM = IT.ID_ITEM
LEFT JOIN CATEGORIA AS CAT ON IT.ID_CATEGORIA = CAT.ID_CATEGORIA
WHERE 1 = 1
AND CAT.DESCR_CATEGORIA = 'Celulares'
AND ORD.STATUS_ORDEM = 'COMPLETO'
;

-- Criar uma tabela temporaria para agrupar as vendas por vendedor e anomes
CREATE TABLE VENDAS_CEL_AGRUP AS
SELECT  MONTH(VC.DATA_ORDEM) AS MES,
        YEAR(VC.DATA_ORDEM) AS ANO,
        VC.ID_CLIENTE,
        VC.NOME,
        VC.SOBRENOME,
        VC.DESCR_CATEGORIA,
        COUNT(VC.ID_CLIENTE) AS QUANTIDADE_VENDAS,
        SUM(VC.QUANTIDADE) AS QUANTIDADE_PRODUTOS_VENDIDOS,
        SUM(VC.VALOR_TOTAL) AS VALOR_TOTAL_TRANSACIONADO
FROM VENDAS_CELULARES AS VC
WHERE YEAR(VC.DATA_ORDEM) = 2020
GROUP BY MES, ANO, VC.ID_CLIENTE, VC.NOME, VC.SOBRENOME, VC.DESCR_CATEGORIA
ORDER BY MES, ANO, VALOR_TOTAL_TRANSACIONADO
;


-- Separar os top 5 vendedores por mês em 2020
-- Primeiro pegar as variaveis do VENDAS_CEL_AGRUP e criar uma ordenação com ROW_NUMBER() de maior $ de venda por anomes
SELECT  TOP5,
        MES, 
        ANO, 
        ID_CLIENTE, 
        NOME, 
        SOBRENOME, 
        DESCR_CATEGORIA, 
        QUANTIDADE_VENDAS, 
        QUANTIDADE_PRODUTOS_VENDIDOS, 
        VALOR_TOTAL_TRANSACIONADO
FROM 
(
    SELECT  MES, 
            ANO, 
            ID_CLIENTE, 
            NOME, 
            SOBRENOME, 
            DESCR_CATEGORIA, 
            QUANTIDADE_VENDAS, 
            QUANTIDADE_PRODUTOS_VENDIDOS, 
            VALOR_TOTAL_TRANSACIONADO,
            ROW_NUMBER() OVER (PARTITION BY MES, ANO ORDER BY VALOR_TOTAL_TRANSACIONADO DESC) AS TOP5
    FROM VENDAS_CEL_AGRUP
) AS VENDAS_CEL_TOP5
WHERE TOP5 <= 5
ORDER BY ANO, MES, TOP5
;
-- descartas tabelas temporarias
DROP TABLE VENDAS_CELULARES;
DROP TABLE VENDAS_CEL_AGRUP;

--################################### Exercicio 3 #################################################

-- criar formato da tabela ITEM_STATUS_FIM_DIA (necessário apenas para a primeira vez)
CREATE TABLE ITEM_STATUS_FIM_DIA (
    ID_ITEM INT,
    DATA DATE,
    PRECO DECIMAL(10, 2),
    STATUS_ITEM VARCHAR(50),
    PRIMARY KEY (ID_ITEM, DATA)
);

-- criar procedure para todo dia a partir de quando rodar a primeira vez empilhar na tabela
-- ITEM_STATUS_FIM_DIA os valores para os itens no final daquele dia.
DELIMITER //

CREATE PROCEDURE EmpilharItemStatus()
BEGIN
    -- Insere o estado e preço atual dos itens, criando um histórico diário
    INSERT INTO ITEM_STATUS_FIM_DIA (ID_ITEM, DATA, PRECO, STATUS_ITEM)
    SELECT ID_ITEM, CURDATE(), PRECO_ITEM, STATUS_ITEM
    FROM ITEM;
END //

CREATE EVENT EmpilharItemStatusDiariamente
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURDATE() + INTERVAL 1 DAY))
DO
CALL EmpilharItemStatus() //

DELIMITER ;