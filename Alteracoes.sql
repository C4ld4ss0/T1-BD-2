/* Alterando tebelas já existentes*/

ALTER TABLE RESERVA ADD Tarifa_ID NUMBER(5);
ALTER TABLE RESERVA ADD Assento_Numero CHAR(4);
ALTER TABLE RESERVA ADD ID_AERONAVE NUMBER(6);

ALTER TABLE RESERVA
    ADD CONSTRAINT FK_Reserva_Tarifa
        FOREIGN KEY (Tarifa_ID)
        REFERENCES Tarifa (Tarifa_ID);

ALTER TABLE RESERVA
    ADD CONSTRAINT FK_Reserva_Assento
    FOREIGN KEY (Assento_Numero, ID_AERONAVE)
    REFERENCES Assento (Assento_Numero, Aeronave_ID);

ALTER TABLE RESERVA
ADD CONSTRAINT AK_Reserva_Voo_Assento
	Unique (ID_VOO, Assento_Numero, Aeronave_ID);
