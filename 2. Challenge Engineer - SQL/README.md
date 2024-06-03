# <img src="https://companieslogo.com/img/orig/MELI-ec0c0e4f.png?t=1648156112" width="35px" alt="Meli Icon" /> Mercado Livre - Data & Analytics Challenge
Repositório público para respostas do Case Técnico.

## Desafio 2: Engineer (SQL)
Objetivo: Criar as Tabelas. Listar usuários que fazem aniversário hoje e realizaram mais de 1500 vendas em janeiro de 2020, identificar os top 5 vendedores de celulares por mês em 2020, e criar uma tabela para armazenar o preço e estado dos itens no final de cada dia, de forma reprocesável.

Ferramenta Utilizada: SQL.

Passos Realizados:
- Criação de Tabelas (Schema).
- Elaboração do DER.
- Consultas SQL.
- Criação de tabelas temporárias para agrupar as vendas por vendedor e mês.
- Criação de um evento e procedure.

### Criação de Tabelas
```sql
-- Criar tabela de Cliente com dados do comprador/vendedor e checagens para variaveis de SEXO e TIPO_PERFIL
CREATE TABLE CLIENTE (
    ID_CLIENTE INT PRIMARY KEY,
    EMAIL VARCHAR(255) NOT NULL,
    NOME VARCHAR(255) NOT NULL,
    SOBRENOME VARCHAR(255) NOT NULL,
    SEXO CHAR(1),
    ENDERECO VARCHAR(255),
    CEP VARCHAR(9),
    DATA_NASCIMENTO DATE,
    TELEFONE VARCHAR(20),
    TIPO_PERFIL VARCHAR(20),
    DATA_CADASTRO DATE,
    DATA_UPDATE DATE,
    CHECK (SEXO IN ('F', 'M', '-')),
    CHECK (TIPO_PERFIL IN ('COMPRADOR', 'VENDEDOR', 'COMPRADOR E VENDEDOR'))
);

-- Criar tabela de ITEM com checagem de status
CREATE TABLE ITEM (
    ID_ITEM INT PRIMARY KEY,
    SKU_ITEM INT,
    NOME_ITEM VARCHAR(255) NOT NULL,
    DESCR_ITEM TEXT,
    PRECO_ITEM DECIMAL(10, 2) NOT NULL,
    DATA_PUBLICACAO DATE,
    DATA_UPDATE DATE,
    DATA_REMOCAO DATE,
    STATUS_ITEM VARCHAR(10),
    ID_CATEGORIA INT,
    CHECK (STATUS_ITEM IN ('ATIVO', 'PENDENTE', 'BAIXADO', 'REMOVIDO'))
);

-- Criar tabela de Categoria
CREATE TABLE CATEGORIA (
    ID_CATEGORIA INT PRIMARY KEY,
    DESCR_CATEGORIA VARCHAR(255),
    CAMINHO VARCHAR(255) NOT NULL
);

-- Criar tabela de Ordem (sendo cada compra 1 Ordem e cada item 1 Ordem também.)
-- Para relacionar diferentes itens em uma mesma compra vou criar o campo ID_COMPRA que sera igual ao menor ID_ORDEM da compra)
-- ID_COMPRADOR E ID_VENDEDOR são relacionaveis com tabela CLIENTE (campo ID_CLIENTE)
CREATE TABLE ORDEM (
    ID_ORDEM INT PRIMARY KEY,
    ID_COMPRA INT,
    DATA_ORDEM TIMESTAMP NOT NULL,
    STATUS_ORDEM VARCHAR(50),
    ID_COMPRADOR INT,
    ID_VENDEDOR INT,
    ID_ITEM INT,
    QUANTIDADE INT NOT NULL,
    VALOR_TOTAL DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ID_COMPRADOR) REFERENCES CLIENTE(ID_CLIENTE),
    FOREIGN KEY (ID_VENDEDOR) REFERENCES CLIENTE(ID_CLIENTE),
    FOREIGN KEY (ID_ITEM) REFERENCES ITEM(ID_ITEM),
    CHECK (STATUS_ORDEM IN ('COMPLETO', 'PENDENTE', 'CANCELADO'))
);
```
### DER (Diagrama de Entidade e Relacionamento)
![DER](https://github.com/BobMarques/case-meli/blob/main/2.%20Challenge%20Engineer%20-%20SQL/DER_MELI.png)

### Resolução dos Problemas

1. Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500. 
2. Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares. Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas, cantidad de productos vendidos y el monto total transaccionado. 
3. Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día. Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item, vamos a tener únicamente el último estado informado por la PK definida. (Se puede resolver a través de StoredProcedure)

```sql
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
```
