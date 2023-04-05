

--1) Agregar columna "EMAIL" a la tabla TB_PERSONA
ALTER TABLE TB_PERSONA ADD EMAIL VARCHAR(255) NOT NULL;
SELECT * FROM TB_PERSONA
--2) Evaluar por medio de un trigger  a la tabla persona, que el valor represente al menos una estructura lógica de correo.
CREATE TRIGGER TR_VALIDAR_EMAIL
ON TB_PERSONA
AFTER INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON

  IF EXISTS (SELECT * FROM inserted WHERE PATINDEX('^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$', EMAIL) = 0)
  BEGIN
    RAISERROR('El valor de la columna EMAIL no representa una estructura lógica de correo.', 16, 1);
    ROLLBACK
  END
END

--3) Crear una tabla de auditoria de TB_PERSONA la tabla se llamara TB_PERSONA_AUDIT
CREATE TABLE TB_PERSONA_AUDIT (
    ID_AUDIT INT IDENTITY(1,1) NOT NULL,
    ID_PERSONA INT NOT NULL,
    NOMBRE_ANT VARCHAR(100),
    APELLIDO_PATERNO_ANT VARCHAR(100),
    APELLIDO_MATERNO_ANT VARCHAR(100),
    COD_DOI_ANT NUMERIC(8),
    DIRECCION_ANT VARCHAR(255),
    FEC_NACIMIENTO_ANT DATE,
    FEC_CREACION_ANT DATETIME,
    FEC_MODIFICACION_ANT DATETIME,
    SEXO_ANT CHAR(1),
    NUM_MOVIL_ANT NUMERIC(9),
    EMAIL_ANT VARCHAR(255),
    FEC_MODIFICACION_NUEVA DATETIME NOT NULL,
    CONSTRAINT PK_TB_PERSONA_AUDIT PRIMARY KEY (ID_AUDIT),
);

--4) Crear un Trigger que cuando se actualice un valor en la tabla TB_PERSONA se inserte en la tabla de auditoria

CREATE TRIGGER TR_TB_PERSONA_UPDATE_AUDIT
ON TB_PERSONA
AFTER UPDATE
AS
BEGIN
    -- Insertar una nueva fila en la tabla de auditoría para cada registro modificado
    INSERT INTO TB_PERSONA_AUDIT (ID_PERSONA, NOMBRE_ANT, APELLIDO_PATERNO_ANT, APELLIDO_MATERNO_ANT, 
                                   COD_DOI_ANT, DIRECCION_ANT, FEC_NACIMIENTO_ANT, FEC_CREACION_ANT, 
                                   FEC_MODIFICACION_ANT, SEXO_ANT, NUM_MOVIL_ANT, EMAIL_ANT, 
                                   FEC_MODIFICACION_NUEVA)
    SELECT i.ID_PERSONA, d.NOMBRE, d.APELLIDO_PATERNO, d.APELLIDO_MATERNO, d.COD_DOI, d.DIRECCION, 
           d.FEC_NACIMIENTO, d.FEC_CREACION, d.FEC_MODIFICACION, d.SEXO, d.NUM_MOVIL, d.EMAIL, 
           GETDATE() -- fecha actual
    FROM inserted i -- filas insertadas (nuevos valores)
    INNER JOIN deleted d ON i.ID_PERSONA = d.ID_PERSONA -- filas eliminadas (valores antiguos)
END;

