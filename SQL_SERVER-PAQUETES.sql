/*    1)  CREANDO TODAS LAS TABLAS QUE FUERON CREADAS EN SQL SERVER A ORACLE     */
CREATE TABLE TB_TIPO_DOC_IDENTIDAD(
	ID_TIPO_DOC_IDENTIDAD NUMBER NOT NULL,
	DES_TIPO_DOC_IDENTIDAD VARCHAR2(255) NOT NULL,
	DES_ABREVIATURA VARCHAR2(3) NOT NULL,
	NUM_MIN_DIGITOS NUMBER NOT NULL,
	NUM_MAX_DIGITOS NUMBER NOT NULL,
	FEC_CREACION DATE,
	FEC_MODIFICACION DATE,
	CONSTRAINT PK_TIPO_DOC_IDENTIDAD PRIMARY KEY (ID_TIPO_DOC_IDENTIDAD),
	CONSTRAINT CK_TIPO_DOC_IDENTIDAD_FEC_MODIFICACION CHECK (FEC_MODIFICACION > FEC_CREACION)
);
-- Inserto registros
INSERT INTO TB_TIPO_DOC_IDENTIDAD (ID_TIPO_DOC_IDENTIDAD, DES_TIPO_DOC_IDENTIDAD, DES_ABREVIATURA, NUM_MIN_DIGITOS, NUM_MAX_DIGITOS, FEC_CREACION)
VALUES (1, 'Documento Nacional de Identidad', 'DNI', 8, 8, SYSDATE);
INSERT INTO TB_TIPO_DOC_IDENTIDAD (ID_TIPO_DOC_IDENTIDAD, DES_TIPO_DOC_IDENTIDAD, DES_ABREVIATURA, NUM_MIN_DIGITOS, NUM_MAX_DIGITOS, FEC_CREACION)
VALUES (2, 'Carne Extranjeria', 'CE', 9, 9, SYSDATE);
INSERT INTO TB_TIPO_DOC_IDENTIDAD (ID_TIPO_DOC_IDENTIDAD, DES_TIPO_DOC_IDENTIDAD, DES_ABREVIATURA, NUM_MIN_DIGITOS, NUM_MAX_DIGITOS, FEC_CREACION)
VALUES (3, 'Pasaporte', 'PAS', 8, 12, SYSDATE);
-- SELECT * FROM TB_TIPO_DOC_IDENTIDAD

CREATE TABLE TB_PERSONA (
    ID_PERSONA NUMBER GENERATED ALWAYS AS IDENTITY,
    NOMBRE VARCHAR2(255) NOT NULL,
    APELLIDO_PATERNO VARCHAR2(255) NOT NULL,
    APELLIDO_MATERNO VARCHAR2(255) NOT NULL,
    COD_DOI VARCHAR2(12) NOT NULL,
    DIRECCION VARCHAR(255) NOT NULL,
    FEC_NACIMIENTO DATE,
    FEC_CREACION DATE NOT NULL,
    FEC_MODIFICACION DATE,
    SEXO CHAR(1) NOT NULL,
    NUM_MOVIL NUMERIC(9) NOT NULL,
    EMAIL VARCHAR(255) NOT NULL,
    ID_TIPO_DOC_IDENTIDAD NUMBER NOT NULL,
    CONSTRAINT PK_PERSONA PRIMARY KEY (ID_PERSONA),
    CONSTRAINT FK_PERSONA_TIPO_DOC_IDENTIDAD FOREIGN KEY (ID_TIPO_DOC_IDENTIDAD) REFERENCES TB_TIPO_DOC_IDENTIDAD(ID_TIPO_DOC_IDENTIDAD),
    CONSTRAINT UN_PERSONA_COD_DOI UNIQUE (COD_DOI),
    CONSTRAINT CK_PERSONA_FEC_MODIFICACION CHECK (FEC_MODIFICACION > FEC_CREACION),
    CONSTRAINT CK_PERSONA_TIPO_DOC_IDENTIDAD CHECK (ID_TIPO_DOC_IDENTIDAD > 0),
    CONSTRAINT CK_PERSONA_APELLIDO_PATERNO CHECK (APELLIDO_PATERNO IS NOT NULL)
);
-- INSERTAR DATOS ...
-- Pero antes, se realiza un TIGGER para verificar el tipo de documento de identidad:
CREATE OR REPLACE TRIGGER TR_VERIFICAR_COD_DOI_PERSONA
AFTER INSERT ON TB_PERSONA
FOR EACH ROW
DECLARE
    vMIN_DIGITOS INT;
    vMAX_DIGITOS INT;
BEGIN
    -- Captura los valores de los d�gitos tanto m�ximos como m�nimos seg�n el tipo de documento que viene en la inserci�n.
    SELECT NUM_MIN_DIGITOS, NUM_MAX_DIGITOS INTO vMIN_DIGITOS, vMAX_DIGITOS
    FROM TB_TIPO_DOC_IDENTIDAD
    WHERE ID_TIPO_DOC_IDENTIDAD = :NEW.ID_TIPO_DOC_IDENTIDAD;
    -- Verifica si la longitud del COD_DOI no cumple con el m�nimo o m�ximo de caracteres permitidos para el tipo de documento.
    IF LENGTH(:NEW.COD_DOI) < vMIN_DIGITOS OR LENGTH(:NEW.COD_DOI) > vMAX_DIGITOS THEN
        RAISE_APPLICATION_ERROR(-20000, 'La longitud del COD_DOI debe estar entre ' || vMIN_DIGITOS || ' y ' || vMAX_DIGITOS || ' caracteres.');
    END IF;
END;
-- Creare otro tigger para validar el campo email:
CREATE OR REPLACE TRIGGER TR_VERIFICAR_EMAIL_PERSONA
BEFORE INSERT OR UPDATE ON TB_PERSONA
FOR EACH ROW
DECLARE
  v_email_valido BOOLEAN := TRUE;
BEGIN
  IF :NEW.EMAIL IS NOT NULL THEN
      -- Verificar si el correo tiene el formato correcto
      IF :NEW.EMAIL NOT LIKE '%@%.%%' THEN --Estructura Email
        v_email_valido := FALSE;
      END IF;
    -- Si el correo no es v�lido, lanzar un error
    IF NOT v_email_valido THEN
      RAISE_APPLICATION_ERROR(-20000, 'El correo electr�nico ingresado no es v�lido.');
    END IF;
  END IF;
END;

-- insertaando registros para la tabla TB_PERSONA
INSERT INTO TB_PERSONA (NOMBRE, APELLIDO_PATERNO, APELLIDO_MATERNO, COD_DOI, DIRECCION, FEC_NACIMIENTO, FEC_CREACION, FEC_MODIFICACION, SEXO, NUM_MOVIL, ID_TIPO_DOC_IDENTIDAD, EMAIL)
VALUES ('Peter', 'Parker', 'Chuquimango', '44456789', 'Av. Los �lamos 123', TO_DATE('1990-01-01', 'YYYY-MM-DD'), SYSDATE, TO_DATE('2023-07-01', 'YYYY-MM-DD'), 'M', 997654321, 1, 'ara�ita@everis.nttdata.com');
INSERT INTO TB_PERSONA (NOMBRE, APELLIDO_PATERNO, APELLIDO_MATERNO, COD_DOI, DIRECCION, FEC_NACIMIENTO, FEC_CREACION, FEC_MODIFICACION, SEXO, NUM_MOVIL, ID_TIPO_DOC_IDENTIDAD, EMAIL)
VALUES ('Antony', 'Stark', 'Gutierrez', '657689988', 'Jiroddd nin 564', TO_DATE('2001-02-15', 'YYYY-MM-DD'), SYSDATE, TO_DATE('2023-09-01', 'YYYY-MM-DD'), 'M', 955155432, 2, 'iron-man99@odybank.edu.pe');
INSERT INTO TB_PERSONA (NOMBRE, APELLIDO_PATERNO, APELLIDO_MATERNO, COD_DOI, DIRECCION, FEC_NACIMIENTO, FEC_CREACION, FEC_MODIFICACION, SEXO, NUM_MOVIL, ID_TIPO_DOC_IDENTIDAD, EMAIL)
VALUES ('Juan', 'Tito', 'Alvarez', '78908755', 'Jiroddd nin 564', TO_DATE('2007-02-15', 'YYYY-MM-DD'), SYSDATE, TO_DATE('2023-09-01', 'YYYY-MM-DD'), 'M', 955145452, 3, 'tito2001@hotmail.com');

SELECT * FROM TB_PERSONA

CREATE TABLE TB_CLIENTE(
    ID_CLIENTE NUMBER GENERATED BY DEFAULT AS IDENTITY,
    ID_TIPO_DOC_IDENTIDAD NUMBER,
    NOMBRE VARCHAR2(50),
    FEC_CREACION DATE,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (ID_CLIENTE, FEC_CREACION),
    CONSTRAINT FK_CLIENTE_TIPO_DOCUMENTO FOREIGN KEY (ID_TIPO_DOC_IDENTIDAD) REFERENCES TB_TIPO_DOC_IDENTIDAD(ID_TIPO_DOC_IDENTIDAD)
);

CREATE TABLE TB_PRODUCTO_ESTADO(
    ID_PRODUCTO_ESTADO NUMBER GENERATED BY DEFAULT AS IDENTITY,
    DES_ESTADO VARCHAR2(80) NOT NULL,
    FEC_CREACION DATE NOT NULL,
    FEC_MODIFICACION DATE,
    CONSTRAINT PK_PRODUCTO_ESTADO PRIMARY KEY(ID_PRODUCTO_ESTADO),
    CONSTRAINT CK_PRODUCTO_ESTADO_FEC_MODIFICACION CHECK (FEC_MODIFICACION > FEC_CREACION)
);
INSERT INTO TB_PRODUCTO_ESTADO (DES_ESTADO,FEC_CREACION) VALUES ('ACTIVO',SYSDATE);
INSERT INTO TB_PRODUCTO_ESTADO (DES_ESTADO,FEC_CREACION) VALUES ('INACTIVO',SYSDATE);


CREATE TABLE TB_PRODUCTO
(
	ID_PRODUCTO NUMBER GENERATED BY DEFAULT AS IDENTITY,
	DES_PRODUCTO VARCHAR2(255) NOT NULL,
	ID_PRODUCTO_ESTADO NUMBER NOT NULL,
	IMP_VALOR_NETO NUMBER(8,2) NOT NULL,
	FEC_CREACION DATE NOT NULL,
	FEC_MODIFICACION DATE,
	CONSTRAINT PK_PRODUCTO PRIMARY KEY (ID_PRODUCTO),
	CONSTRAINT FK_PRODUCTO_PRODUCTO_ESTADO FOREIGN KEY (ID_PRODUCTO_ESTADO) REFERENCES TB_PRODUCTO_ESTADO(ID_PRODUCTO_ESTADO),
	CONSTRAINT CK_PRODUCTO_FEC_CREACION CHECK (FEC_MODIFICACION > FEC_CREACION),
	CONSTRAINT CK_PRODUCTO_IMP_VALOR_NETO CHECK (IMP_VALOR_NETO > 0)
);
INSERT INTO TB_PRODUCTO(DES_PRODUCTO, ID_PRODUCTO_ESTADO, IMP_VALOR_NETO, FEC_CREACION)VALUES('GALLETA DE VAINILLA', 1, 1, SYSDATE);
INSERT INTO TB_PRODUCTO(DES_PRODUCTO, ID_PRODUCTO_ESTADO, IMP_VALOR_NETO, FEC_CREACION)VALUES('GALLETA DE COCO', 1, 2, SYSDATE);
INSERT INTO TB_PRODUCTO(DES_PRODUCTO, ID_PRODUCTO_ESTADO, IMP_VALOR_NETO, FEC_CREACION)VALUES('GALLETA DE MENTA', 1, 2.5, SYSDATE);
INSERT INTO TB_PRODUCTO(DES_PRODUCTO, ID_PRODUCTO_ESTADO, IMP_VALOR_NETO, FEC_CREACION)VALUES('CHOCOLATE - CACAO AL 75%', 1, 1.75, SYSDATE);
INSERT INTO TB_PRODUCTO(DES_PRODUCTO, ID_PRODUCTO_ESTADO, IMP_VALOR_NETO, FEC_CREACION)VALUES('CHOCOLATE - CACAO AL 80%', 1, 1.50, SYSDATE);
INSERT INTO TB_PRODUCTO(DES_PRODUCTO, ID_PRODUCTO_ESTADO, IMP_VALOR_NETO, FEC_CREACION)VALUES('CHOCOLATE - CACAO AL 85%', 1, 3.18, SYSDATE);
INSERT INTO TB_PRODUCTO(DES_PRODUCTO, ID_PRODUCTO_ESTADO, IMP_VALOR_NETO, FEC_CREACION)VALUES('CHOCOLATE - CACAO AL 90%', 1, 17, SYSDATE);
INSERT INTO TB_PRODUCTO(DES_PRODUCTO, ID_PRODUCTO_ESTADO, IMP_VALOR_NETO, FEC_CREACION)VALUES('CHOCOLATE CON LECHE', 1, 25, SYSDATE);
SELECT * FROM TB_PRODUCTO;

CREATE TABLE TB_PEDIDO_ESTADO(
    ID_PEDIDO_ESTADO NUMBER GENERATED ALWAYS AS IDENTITY,
    DES_ESTADO VARCHAR2(80) NOT NULL,
    FEC_CREACION DATE NOT NULL,
    FEC_MODIFICACION DATE,
    CONSTRAINT PK_PEDIDO_ESTADO PRIMARY KEY(ID_PEDIDO_ESTADO),
    CONSTRAINT CK_PEDIDO_ESTADO_FEC_MODIFICACION CHECK (FEC_MODIFICACION > FEC_CREACION)
);
--Insertando
INSERT INTO TB_PEDIDO_ESTADO (DES_ESTADO,FEC_CREACION) VALUES('ENTREGADO',SYSDATE);
INSERT INTO TB_PEDIDO_ESTADO (DES_ESTADO,FEC_CREACION) VALUES('PENDIENTE',SYSDATE);
INSERT INTO TB_PEDIDO_ESTADO (DES_ESTADO,FEC_CREACION) VALUES('CANCELADO',SYSDATE);
select*from tb_pedido_estado;

CREATE TABLE TB_PEDIDO(
    ID_PEDIDO NUMBER GENERATED ALWAYS AS IDENTITY,
    DES_PEDIDO VARCHAR2(50) NOT NULL,
    ID_PEDIDO_ESTADO NUMBER NOT NULL,
    ID_PERSONA NUMBER NOT NULL,
    IMP_TOTAL_PEDIDO NUMBER(8,2), --NOT NULL,
    FEC_CREACION DATE DEFAULT SYSDATE NOT NULL,
    FEC_MODIFICACION DATE,
    CONSTRAINT PK_PEDIDO PRIMARY KEY(ID_PEDIDO),
    CONSTRAINT FK_PEDIDO_PEDIDO_ESTADO FOREIGN KEY (ID_PEDIDO_ESTADO) REFERENCES TB_PEDIDO_ESTADO(ID_PEDIDO_ESTADO),
    CONSTRAINT FK_PEDIDO_PERSONA FOREIGN KEY (ID_PERSONA) REFERENCES TB_PERSONA(ID_PERSONA),
    CONSTRAINT CK_PEDIDO_FEC_MODIFICACION CHECK (FEC_MODIFICACION > FEC_CREACION),
    CONSTRAINT CK_PEDIDO_IMP_TOTAL_PEDIDO CHECK (IMP_TOTAL_PEDIDO > 0)
);

CREATE TABLE TB_PEDIDO_DETALLE(
    ID_PEDIDO_DETALLE NUMBER GENERATED ALWAYS AS IDENTITY,
    ID_PEDIDO NUMBER NOT NULL,
    ID_PRODUCTO NUMBER NOT NULL,
    IMP_VALOR_NETO NUMBER(8,2),
    NUM_CANTIDAD NUMBER(8,2) NOT NULL,
    IMP_VALOR_TOTAL NUMBER(8,2),
    FEC_CREACION DATE NOT NULL,
    FEC_MODIFICACION DATE,
    CONSTRAINT PK_PEDIDO_DETALLE PRIMARY KEY (ID_PEDIDO_DETALLE),
    CONSTRAINT FK_PEDIDO_DETALLE_PEDIDO FOREIGN KEY (ID_PEDIDO) REFERENCES TB_PEDIDO(ID_PEDIDO),
    CONSTRAINT FK_PEDIDO_PRODUCTO FOREIGN KEY (ID_PRODUCTO) REFERENCES TB_PRODUCTO(ID_PRODUCTO),
    CONSTRAINT CK_PEDIDO_DETALLE_NUM_CANTIDAD CHECK (NUM_CANTIDAD > 0),
    CONSTRAINT CK_PEDIDO_DETALLE_IMP_VALOR_NETO CHECK (IMP_VALOR_NETO > 0),
    CONSTRAINT CK_PEDIDO_DETALLE_IMP_VALOR_TOTAL CHECK (IMP_VALOR_TOTAL > 0),
    CONSTRAINT CK_PEDIDO_DETALLE_FEC_MODIFICACION CHECK (FEC_MODIFICACION > FEC_CREACION)
);

/*    2)   Crear �paquete PKG_VENTAS que encapsular� los 2 procedimientos PR_INS_PEDIDO y PR_INS_PEDIDO_DETALLE�               */
-- cabecera
CREATE OR REPLACE PACKAGE PKG_VENTAS AS
    PROCEDURE PR_INS_PEDIDO(
    P_DES_PEDIDO IN TB_PEDIDO.DES_PEDIDO%TYPE,
    P_ID_PEDIDO_ESTADO IN TB_PEDIDO.ID_PEDIDO_ESTADO%TYPE,
    P_ID_PERSONA IN TB_PEDIDO.ID_PERSONA%TYPE
    );
    PROCEDURE PR_INS_PEDIDO_DETALLE(
      P_ID_PEDIDO IN TB_PEDIDO_DETALLE.ID_PEDIDO%TYPE,
      P_ID_PRODUCTO IN TB_PEDIDO_DETALLE.ID_PRODUCTO%TYPE,
      P_NUM_CANTIDAD IN TB_PEDIDO_DETALLE.NUM_CANTIDAD%TYPE
    );
END; -- fin cabecera
-- body
CREATE OR REPLACE PACKAGE BODY PKG_VENTAS AS
  -- procedimiento PR_INS_PEDIDO
  PROCEDURE PR_INS_PEDIDO (
    P_DES_PEDIDO IN TB_PEDIDO.DES_PEDIDO%TYPE,
    P_ID_PEDIDO_ESTADO IN TB_PEDIDO.ID_PEDIDO_ESTADO%TYPE,
    P_ID_PERSONA IN TB_PEDIDO.ID_PERSONA%TYPE
  ) AS
    V_ID_PEDIDO TB_PEDIDO.ID_PEDIDO%TYPE;
  BEGIN
    -- Insertando los valores en la tabla TB_PEDIDO
    INSERT INTO TB_PEDIDO (DES_PEDIDO, ID_PEDIDO_ESTADO, ID_PERSONA, FEC_CREACION)
    VALUES (P_DES_PEDIDO, P_ID_PEDIDO_ESTADO, P_ID_PERSONA, SYSDATE)
    RETURNING ID_PEDIDO INTO V_ID_PEDIDO;
 
    DBMS_OUTPUT.PUT_LINE('Pedido registrado con �xito. ID del pedido: ' || V_ID_PEDIDO || ', Descripci�n del pedido: ' || P_DES_PEDIDO);
  END PR_INS_PEDIDO;
  -- procedimiento PR_INS_PEDIDO_DETALLE
  PROCEDURE PR_INS_PEDIDO_DETALLE (
    P_ID_PEDIDO IN TB_PEDIDO_DETALLE.ID_PEDIDO%TYPE,
    P_ID_PRODUCTO IN TB_PEDIDO_DETALLE.ID_PRODUCTO%TYPE,
    P_NUM_CANTIDAD IN TB_PEDIDO_DETALLE.NUM_CANTIDAD%TYPE
    ) AS
    V_ID_PEDIDO_DETALLE TB_PEDIDO_DETALLE.ID_PEDIDO_DETALLE%TYPE;
  BEGIN
    -- Validar cantidad
    IF P_NUM_CANTIDAD < 2 THEN
      DBMS_OUTPUT.PUT_LINE('Error: la cantidad debe ser mayor o igual a 2.');
      RETURN;
    END IF;
  
    -- Inserta los valores en la tabla TB_PEDIDO_DETALLE
    INSERT INTO TB_PEDIDO_DETALLE (ID_PEDIDO, ID_PRODUCTO, NUM_CANTIDAD, FEC_CREACION)
    VALUES (P_ID_PEDIDO, P_ID_PRODUCTO, P_NUM_CANTIDAD, SYSDATE)
    RETURNING ID_PEDIDO_DETALLE INTO V_ID_PEDIDO_DETALLE;

    DBMS_OUTPUT.PUT_LINE('El detalle del pedido fue agregado correctamente');
  END PR_INS_PEDIDO_DETALLE;
END; -- fin body
--INSERTANDO PEDIDO..
BEGIN
    --DES,ESTADO,IDPERSONA
    PKG_VENTAS.PR_INS_PEDIDO('Comprado en tienda',2,1);
END;

select*from TB_PEDIDO_ESTADO;
--INSERTANDO PEDIDO DETALLE..
BEGIN
                                   --IDPEDIDO,IDPRODUCTO,CANTIDAD
    PKG_VENTAS.PR_INS_PEDIDO_DETALLE(9,19,3);
END;
select*from tb_producto;
--Consultando--
SELECT * FROM TB_PEDIDO
SELECT * FROM TB_PEDIDO_DETALLE

--Eliminar paquete--
--DROP PACKAGE BODY PKG_VENTAS;
--DELETE FROM TB_PEDIDO

/*    3)   (SQL Puro no cursores) Crear otro paquete que al terminar de llenar los detalles del Pedido actualic� 
      el valor de la tabla TB_PEDIDO_DETALLE donde traer� el valor "IMP_VALOR_NETO" del producto de la tabla TB_PRODUCTO
      y calcular�n el "IMP_VALOR_TOTAL" de la tabla TB_PEDIDO_DETALLE�  �                                                     */
-- Nota: 
-- Creamos el paquete PKG_UTILIDAD
CREATE OR REPLACE PACKAGE PKG_UTILIDAD AS
    PROCEDURE PR_UPD_MONTOS_TOTALES;
END PKG_UTILIDAD;
-- Implementamos el cuerpo del paquete
CREATE OR REPLACE PACKAGE BODY PKG_UTILIDAD AS
    PROCEDURE PR_UPD_MONTOS_TOTALES AS
        -- Declaramos las variables
        v_imp_valor_neto TB_PRODUCTO.IMP_VALOR_NETO%TYPE;
        v_imp_valor_total TB_PEDIDO_DETALLE.IMP_VALOR_TOTAL%TYPE;
        v_id_pedido_detalle TB_PEDIDO_DETALLE.ID_PEDIDO_DETALLE%TYPE;
        v_id_pedido TB_PEDIDO.ID_PEDIDO%TYPE;
        v_num_cantidad TB_PEDIDO_DETALLE.NUM_CANTIDAD%TYPE;
        v_id_producto TB_PRODUCTO.ID_PRODUCTO%TYPE;
        v_fec_creacion TB_PEDIDO_DETALLE.FEC_CREACION%TYPE;
    BEGIN
        -- Actualizamos los campos IMP_VALOR_NETO e IMP_VALOR_TOTAL de cada detalle de pedido
        UPDATE TB_PEDIDO_DETALLE pd
        SET (pd.IMP_VALOR_NETO, pd.IMP_VALOR_TOTAL) = (
            SELECT pr.IMP_VALOR_NETO, pr.IMP_VALOR_NETO * pd.NUM_CANTIDAD
            FROM TB_PRODUCTO pr
            WHERE pr.ID_PRODUCTO = pd.ID_PRODUCTO
        );
        
        -- Actualizamos el campo IMP_TOTAL_PEDIDO de cada pedido
        FOR r IN (
            SELECT pd.ID_PEDIDO_DETALLE, pd.ID_PEDIDO, pd.NUM_CANTIDAD, p.IMP_TOTAL_PEDIDO
            FROM TB_PEDIDO_DETALLE pd
            JOIN TB_PEDIDO p ON p.ID_PEDIDO = pd.ID_PEDIDO
            WHERE pd.IMP_VALOR_TOTAL IS NOT NULL
        )
        LOOP
            UPDATE TB_PEDIDO p
            SET p.IMP_TOTAL_PEDIDO = r.IMP_TOTAL_PEDIDO + (r.NUM_CANTIDAD * v_imp_valor_neto)
            WHERE p.ID_PEDIDO = r.ID_PEDIDO;
        END LOOP;
    END PR_UPD_MONTOS_TOTALES;
END PKG_UTILIDAD;
 --llamando...
 BEGIN
    PKG_UTILIDAD.PR_UPD_MONTOS_TOTALES;
END;
--
SELECT * FROM TB_PEDIDO;
SELECT * FROM TB_PEDIDO_DETALLE;