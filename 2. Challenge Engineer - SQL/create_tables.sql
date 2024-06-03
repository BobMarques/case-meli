
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