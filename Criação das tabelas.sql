-- ============================================================
-- BASE AEROPORTO - ORACLE SQL
-- Tabelas para Trabalho 1 de Banco de Dados 2
--
-- Observacao:
-- Oracle não possui o tipo TIME isolado. Por isso, os horários
-- previstos foram modelados como VARCHAR2(5), no formato HH:MI.
--
-- Convenção adotada em DIA_SEMANA:
-- 1 = segunda-feira
-- 2 = terca-feira
-- 3 = quarta-feira
-- 4 = quinta-feira
-- 5 = sexta-feira
-- 6 = sabado
-- 7 = domingo
-- ============================================================


/* =========================================================
   TIPOS DE AERONAVE
   ========================================================= */

CREATE TABLE AERONAVE_TIPO (
    ID_AERONAVE_TIPO NUMBER(3)    NOT NULL,
    NOME             VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_AERONAVE_TIPO
        PRIMARY KEY (ID_AERONAVE_TIPO)
);


/* =========================================================
   AEROPORTO
   ========================================================= */

CREATE TABLE AEROPORTO (
    ID_AEROPORTO NUMBER(5)    NOT NULL,
    IATA         CHAR(3)      NOT NULL,
    ICAO         CHAR(4)      NOT NULL,
    NOME         VARCHAR2(10) NOT NULL,

    CONSTRAINT PK_AEROPORTO
        PRIMARY KEY (ID_AEROPORTO),

    CONSTRAINT AK_AEROPORTO_ICAO
        UNIQUE (ICAO)
);


/* =========================================================
   DADOS GEOGRAFICOS DOS AEROPORTOS
   ========================================================= */

CREATE TABLE AEROPORTO_GEO (
    ID_AEROPORTO NUMBER(5)     NOT NULL,
    NOME         VARCHAR2(50)  NOT NULL,
    CIDADE       VARCHAR2(50)  NOT NULL,
    PAIS         VARCHAR2(50)  NOT NULL,
    LATITUDE     NUMBER(11,8)  NOT NULL,
    LONGITUDE    NUMBER(11,8)  NOT NULL,

    CONSTRAINT PK_AEROPORTO_GEO
        PRIMARY KEY (ID_AEROPORTO),

    CONSTRAINT FK_AEROPORTO_GEO_AEROPORTO
        FOREIGN KEY (ID_AEROPORTO)
        REFERENCES AEROPORTO (ID_AEROPORTO)
);


/* =========================================================
   COMPANHIAS AEREAS
   ========================================================= */

CREATE TABLE COMPANHIA_AEREA (
    ID_COMPANHIA      NUMBER(5)    NOT NULL,
    IATA              CHAR(2)      NOT NULL,
    NOME_COMPANHIA    VARCHAR2(30) NOT NULL,
    ID_AEROPORTO_BASE NUMBER(5)    NOT NULL,

    CONSTRAINT PK_COMPANHIA_AEREA
        PRIMARY KEY (ID_COMPANHIA),

    CONSTRAINT AK_COMPANHIA_IATA
        UNIQUE (IATA),

    CONSTRAINT FK_COMPANHIA_AEROPORTO
        FOREIGN KEY (ID_AEROPORTO_BASE)
        REFERENCES AEROPORTO (ID_AEROPORTO)
);


/* =========================================================
   AERONAVE
   ========================================================= */

CREATE TABLE AERONAVE (
    ID_AERONAVE      NUMBER(6) NOT NULL,
    ID_COMPANHIA     NUMBER(5) NOT NULL,
    ID_AERONAVE_TIPO NUMBER(3) NOT NULL,
    CAPACIDADE       NUMBER(3) NOT NULL,

    CONSTRAINT PK_AERONAVE
        PRIMARY KEY (ID_AERONAVE),

    CONSTRAINT FK_AERONAVE_COMPANHIA
        FOREIGN KEY (ID_COMPANHIA)
        REFERENCES COMPANHIA_AEREA (ID_COMPANHIA),

    CONSTRAINT FK_AERONAVE_TIPO
        FOREIGN KEY (ID_AERONAVE_TIPO)
        REFERENCES AERONAVE_TIPO (ID_AERONAVE_TIPO)
);


/* =========================================================
   PASSAGEIRO
   ========================================================= */

CREATE TABLE PASSAGEIRO (
    ID_PASSAGEIRO     NUMBER(12)    NOT NULL,
    NUMERO_PASSAPORTE CHAR(9)       NOT NULL,
    NOME              VARCHAR2(100) NOT NULL,
    SOBRENOME         VARCHAR2(100) NOT NULL,

    CONSTRAINT PK_PASSAGEIRO
        PRIMARY KEY (ID_PASSAGEIRO),

    CONSTRAINT AK_PASSAGEIRO_PASSAPORTE
        UNIQUE (NUMERO_PASSAPORTE)
);


/* =========================================================
   DETALHES DO PASSAGEIRO
   ========================================================= */

CREATE TABLE PASSAGEIRO_DETALHES (
    ID_PASSAGEIRO   NUMBER(12)    NOT NULL,
    DATA_NASCIMENTO DATE          NOT NULL,
    SEXO            CHAR(1)       NOT NULL,
    RUA             VARCHAR2(100) NOT NULL,
    CIDADE          VARCHAR2(100) NOT NULL,
    CEP             NUMBER(5)     NOT NULL,
    PAIS            VARCHAR2(50)  NOT NULL,
    EMAIL           VARCHAR2(120),
    TELEFONE        VARCHAR2(30),

    CONSTRAINT PK_PASSAGEIRO_DETALHES
        PRIMARY KEY (ID_PASSAGEIRO),

    CONSTRAINT FK_DET_PASSAGEIRO_PASSAGEIRO
        FOREIGN KEY (ID_PASSAGEIRO)
        REFERENCES PASSAGEIRO (ID_PASSAGEIRO)
);


/* =========================================================
   PROGRAMACAO DOS VOOS
   ========================================================= */

CREATE TABLE VOO_PROGRAMACAO (
    NUMERO_VOO            CHAR(8)     NOT NULL,
    ID_COMPANHIA          NUMBER(5)   NOT NULL,
    ID_AEROPORTO_ORIGEM   NUMBER(5)   NOT NULL,
    ID_AEROPORTO_DESTINO  NUMBER(5)   NOT NULL,
    HORA_PARTIDA_PREVISTA VARCHAR2(5) NOT NULL,
    HORA_CHEGADA_PREVISTA VARCHAR2(5) NOT NULL,

    CONSTRAINT PK_VOO_PROGRAMACAO
        PRIMARY KEY (NUMERO_VOO),

    CONSTRAINT FK_PROG_VOO_COMPANHIA
        FOREIGN KEY (ID_COMPANHIA)
        REFERENCES COMPANHIA_AEREA (ID_COMPANHIA),

    CONSTRAINT FK_PROG_VOO_ORIGEM
        FOREIGN KEY (ID_AEROPORTO_ORIGEM)
        REFERENCES AEROPORTO (ID_AEROPORTO),

    CONSTRAINT FK_PROG_VOO_DESTINO
        FOREIGN KEY (ID_AEROPORTO_DESTINO)
        REFERENCES AEROPORTO (ID_AEROPORTO)
);


/* =========================================================
   DIAS DA PROGRAMACAO
   ========================================================= */

CREATE TABLE VOO_DIAS_PROGRAMACAO (
    NUMERO_VOO CHAR(8)   NOT NULL,
    DIA_SEMANA NUMBER(1) NOT NULL,

    CONSTRAINT PK_VOO_DIAS_PROGRAMACAO
        PRIMARY KEY (NUMERO_VOO, DIA_SEMANA),

    CONSTRAINT FK_DPV_PROGRAMACAO
        FOREIGN KEY (NUMERO_VOO)
        REFERENCES VOO_PROGRAMACAO (NUMERO_VOO),

    CONSTRAINT CK_VOO_DIA_SEMANA
        CHECK (DIA_SEMANA BETWEEN 1 AND 7)
);


/* =========================================================
   VOO
   ========================================================= */

CREATE TABLE VOO (
    ID_VOO        NUMBER(10) NOT NULL,
    NUMERO_VOO    CHAR(8)    NOT NULL,
    ID_AERONAVE   NUMBER(6)  NOT NULL,
    PARTIDA_REAL  TIMESTAMP  NOT NULL,
    CHEGADA_REAL  TIMESTAMP  NOT NULL,

    CONSTRAINT PK_VOO
        PRIMARY KEY (ID_VOO),

    CONSTRAINT FK_PROGRAMACAO_VOO
        FOREIGN KEY (NUMERO_VOO)
        REFERENCES VOO_PROGRAMACAO (NUMERO_VOO),

    CONSTRAINT FK_VOO_AERONAVE
        FOREIGN KEY (ID_AERONAVE)
        REFERENCES AERONAVE (ID_AERONAVE)
);


/* =========================================================
   RESERVA
   ========================================================= */

CREATE TABLE RESERVA (
    ID_RESERVA     NUMBER(20)   NOT NULL,
    ID_PASSAGEIRO  NUMBER(12)   NOT NULL,
    ID_VOO         NUMBER(10)   NOT NULL,
    ASSENTO        CHAR(4)      NOT NULL,
    PRECO          NUMBER(10,2) NOT NULL,

    CONSTRAINT PK_RESERVA
        PRIMARY KEY (ID_RESERVA),

    CONSTRAINT FK_RESERVA_PASSAGEIRO
        FOREIGN KEY (ID_PASSAGEIRO)
        REFERENCES PASSAGEIRO (ID_PASSAGEIRO),

    CONSTRAINT FK_RESERVA_VOO
        FOREIGN KEY (ID_VOO)
        REFERENCES VOO (ID_VOO),

    CONSTRAINT AK_RESERVA_VOO_ASSENTO
        UNIQUE (ID_VOO, ASSENTO)
);
/*==========================
      Minhas alterações
==========================*/
/*Criação da tabela Bagagem*/
CREATE TABLE Bagagem (

    Bagagem_ID NUMBER(10) NOT NULL,
    Bagagem_PESO NUMBER(5,2) NOT NULL,
    Bagagem_TIPO VARCHAR2(20) NOT NULL,
    Bagagem_STATUS VARCHAR2(15) NOT NULL, 
    Id_Reserva NUMBER(20) NOT NULL,

    CONSTRAINT PK_Bagagem
        PRIMARY KEY (Bagagem_ID),

    CONSTRAINT CK_Bagagem_Tipo
        CHECK (Bagagem_TIPO IN ('Bagagem de mão', 'Bagagem despachada', 'Bagagem especial')),

    CONSTRAINT CK_Bagagem_Status
        CHECK (Bagagem_STATUS IN ('Cadastrada', 'Despachada', 'Em trânsito', 'Entregue', 'Extraviada')),

    CONSTRAINT FK_Bagagem_Reserva
        FOREIGN KEY (Id_Reserva)
        REFERENCES RESERVA (Id_Reserva)    
);

/*Criação da tabela Classe*/
CREATE TABLE Classe(

    Classe_ID NUMBER(1) NOT NULL,
    Classe_Nome VARCHAR2(20) NOT NULL,

    CONSTRAINT PK_Classe
        PRIMARY KEY (Classe_Id),

    CONSTRAINT CK_Classe_Id
        CHECK (Classe_Id IN (1,2,3)),
        
    CONSTRAINT CK_Classe_Nome
        CHECK (Classe_Nome IN ('Econômica','Executiva','Primeira Classe'))

);

/*Criação da tabela Tarifa*/
CREATE TABLE Tarifa (

    Tarifa_ID NUMBER(5) NOT NULL,
    Tarifa_Nome VARCHAR2(50) NOT NULL,
    Tarifa_Valor NUMBER(10,2) NOT NULL,
    Tarifa_Possibilidade_Reembolso CHAR(1) NOT NULL,
    Tarifa_Franquia_Bagagem CHAR(1) NOT NULL,

    Classe_ID NUMBER(1) NOT NULL,

    CONSTRAINT PK_Tarifa
        PRIMARY KEY (Tarifa_ID),

    CONSTRAINT CK_Tarifa_Reembolso
        CHECK (Tarifa_Possibilidade_Reembolso IN ('S', 'N')),

    CONSTRAINT CK_Tarifa_Franquia_Bagagem
        CHECK (Tarifa_Franquia_Bagagem IN ('S', 'N')),

    CONSTRAINT FK_Tarifa_Classe
        FOREIGN KEY (Classe_ID)
        REFERENCES Classe (Classe_ID)
);

/*Criação da tabela Assento*/

CREATE TABLE Assento(

    Assento_Numero CHAR(4) NOT NULL,
    Aeronave_ID NUMBER(6) NOT NULL,
    Classe_ID NUMBER(1) NOT NULL,

    CONSTRAINT PK_Assento
        PRIMARY KEY (Assento_Numero, Aeronave_ID),

    CONSTRAINT FK_Assento_Aeronave
        FOREIGN KEY (Aeronave_ID)
        REFERENCES AERONAVE (ID_AERONAVE),

    CONSTRAINT FK_Assento_Classe
        FOREIGN KEY(Classe_ID)
        REFERENCES Classe (Classe_ID)
);
