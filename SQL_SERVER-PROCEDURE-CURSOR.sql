
/*1) Insertar datos de pedidos, crear al menos 6 pedidos.*/
INSERT INTO TB_PEDIDO (DES_PEDIDO, ID_PEDIDO_ESTADO, ID_PERSONA,FEC_CREACION)
VALUES
('Pedido Tienda',2,1,GETDATE()),
('Pedido Web',2,2,GETDATE()),
('Pedido POS',2,3,GETDATE()),
('Pedido Ecommerce',2,1,GETDATE()),
('Pedido POS',2,2,GETDATE()),
('Pedido Tienda',2,3,GETDATE())

/* 2) Llenar data de pedido detalle de los 6 pedido creados anteriormente y añadir al menos 2 productos por pedido_detalle.
   3) Los campos "IMP_VALOR_NETO" y "IMP_VALOR_TOTAL" no se llenará en el insert, pero si los demás campos.                 */

-- Realice un procedimiento almacenado para validar el numero ingresado en el campo NUM_CANTIDAD
CREATE PROCEDURE PA_VALIDAR_NUMERO (@NUM INT, @RESULTADO NVARCHAR(50) OUTPUT)
AS
BEGIN
    IF @NUM >= 2
        BEGIN
            -- si el número es válido
            SET @RESULTADO = 'El número ingresado es válido.'
        END
    ELSE
        BEGIN
            -- si el número no es válido
            SET @RESULTADO = 'El número ingresado no es válido.'
        END
END

-- Ademas, cree un procedimiento almaacenado para llenar la tabla TB_PEDIDO_DETALLE 
CREATE PROCEDURE PA_INSERTAR_PEDIDO_DETALLE (@ID_PEDIDO INT, @ID_PRODUCTO INT, @NUM_CANTIDAD INT)
AS
BEGIN
    -- valido el número de cantidad utilizando el procedimiento almacenado PA_VALIDAR_NUMERO
    DECLARE @RESULTADO NVARCHAR(50)
    EXEC PA_VALIDAR_NUMERO @NUM_CANTIDAD, @RESULTADO OUTPUT
    
    IF @RESULTADO = 'El número ingresado es válido.'
        BEGIN
            -- Si el número es válido, insertamos el registro en la tabla TB_PEDIDO_DETALLE
			-- sin incluir los campos IMP_VALOR_NETO y IMP_VALOR_TOTAL
            INSERT INTO TB_PEDIDO_DETALLE (ID_PEDIDO, ID_PRODUCTO, NUM_CANTIDAD, FEC_CREACION)
            VALUES (@ID_PEDIDO, @ID_PRODUCTO, @NUM_CANTIDAD, GETDATE())
        END
    ELSE
        BEGIN
            -- Si el número no es válido, no insertamos el registro en la tabla
            RAISERROR('El número ingresado no es válido.', 16, 1)
        END
END

-- Insertamos datos . . .
EXEC PA_INSERTAR_PEDIDO_DETALLE 1, 2, 3
EXEC PA_INSERTAR_PEDIDO_DETALLE 2, 4, 4
EXEC PA_INSERTAR_PEDIDO_DETALLE 3, 1, 2
EXEC PA_INSERTAR_PEDIDO_DETALLE 1, 6, 2
EXEC PA_INSERTAR_PEDIDO_DETALLE 2, 3, 5
EXEC PA_INSERTAR_PEDIDO_DETALLE 3, 8, 6

/*	 4) Van a crear un cursor que actualice la tabla TB_PEDIDO_DETALLE 
		donde traerá el valor "IMP_VALOR_NETO" del producto de la tabla TB_PRODUCTO y
		calcularán el "IMP_VALOR_TOTAL" de la tabla TB_PEDIDO_DETALLE    */

-- variables necesarias para el cursor:
DECLARE @ID_PEDIDO_DETALLE INT
DECLARE @ID_PRODUCTO INT
DECLARE @IMP_VALOR_NETO NUMERIC(8,2)
DECLARE @NUM_CANTIDAD NUMERIC(8,2)
DECLARE @IMP_VALOR_TOTAL NUMERIC(8,2)
DECLARE @FEC_CREACION DATETIME
DECLARE @FEC_MODIFICACION DATETIME
DECLARE @IMP_VALOR_NETO_PRODUCTO NUMERIC(8,2)
-- declaro el cursor
DECLARE CURSOR_DETALLE CURSOR FOR
    SELECT ID_PEDIDO_DETALLE, ID_PRODUCTO, IMP_VALOR_NETO, NUM_CANTIDAD, FEC_CREACION, FEC_MODIFICACION
    FROM TB_PEDIDO_DETALLE
OPEN CURSOR_DETALLE -- abro el cursor
-- Iteramos sobre cada fila del cursor y se calcula el valor de IMP_VALOR_TOTAL:
FETCH NEXT FROM CURSOR_DETALLE INTO @ID_PEDIDO_DETALLE, @ID_PRODUCTO, @IMP_VALOR_NETO, @NUM_CANTIDAD, @FEC_CREACION, @FEC_MODIFICACION
WHILE @@FETCH_STATUS = 0  
BEGIN
    SELECT @IMP_VALOR_NETO_PRODUCTO = IMP_VALOR_NETO FROM TB_PRODUCTO WHERE ID_PRODUCTO = @ID_PRODUCTO
    
    SET @IMP_VALOR_TOTAL = @IMP_VALOR_NETO_PRODUCTO * @NUM_CANTIDAD --PARA EL CAMPO IMP_VALOR_TOTAL
	SET @IMP_VALOR_NETO = @IMP_VALOR_NETO_PRODUCTO -- PARA EL CAMPO IMP_VALOR_NETO
    UPDATE TB_PEDIDO_DETALLE SET IMP_VALOR_NETO = @IMP_VALOR_NETO WHERE ID_PEDIDO_DETALLE = @ID_PEDIDO_DETALLE
    UPDATE TB_PEDIDO_DETALLE SET IMP_VALOR_TOTAL = @IMP_VALOR_TOTAL WHERE ID_PEDIDO_DETALLE = @ID_PEDIDO_DETALLE
    
    FETCH NEXT FROM CURSOR_DETALLE INTO @ID_PEDIDO_DETALLE, @ID_PRODUCTO, @IMP_VALOR_NETO, @NUM_CANTIDAD, @FEC_CREACION, @FEC_MODIFICACION
END
CLOSE CURSOR_DETALLE --cerrar cursor
DEALLOCATE CURSOR_DETALLE --liberar cursor

/*5) Por último en el mismo cursor actualizarán la tabla TB_PEDIDO el campo "IMP_TOTAL_PEDIDO" 
	con la sumatoria del total de la tabla TB_PEDIDO_DETALLE relacionado al pedido.            */

-- NOTA: NO SABIA COMO ALTERAR EL CURSOR DE OTRA MANERA, ASI QUE CREE UN NUEVO CURSOR QUE CUMPLE LA INSTRUCCION 4 Y 5

DECLARE @ID_PEDIDO_DETALLE INT
DECLARE @ID_PEDIDO INT
DECLARE @ID_PRODUCTO INT
DECLARE @IMP_VALOR_NETO NUMERIC(8,2)
DECLARE @NUM_CANTIDAD NUMERIC(8,2)
DECLARE @IMP_VALOR_TOTAL NUMERIC(8,2)
DECLARE @FEC_CREACION DATETIME

DECLARE CURSOR_DETALLE_TOTAL CURSOR FOR
    SELECT ID_PEDIDO_DETALLE, ID_PEDIDO, ID_PRODUCTO, IMP_VALOR_NETO, NUM_CANTIDAD, FEC_CREACION
    FROM TB_PEDIDO_DETALLE

OPEN CURSOR_DETALLE_TOTAL

FETCH NEXT FROM CURSOR_DETALLE_TOTAL INTO @ID_PEDIDO_DETALLE, @ID_PEDIDO, @ID_PRODUCTO, @IMP_VALOR_NETO, @NUM_CANTIDAD, @FEC_CREACION

WHILE @@FETCH_STATUS = 0
BEGIN
	
	SELECT @IMP_VALOR_NETO = IMP_VALOR_NETO FROM TB_PRODUCTO WHERE ID_PRODUCTO = @ID_PRODUCTO
    
	SET @IMP_VALOR_TOTAL = @IMP_VALOR_NETO * @NUM_CANTIDAD --VALOR TOTAL 

	--PARA EL CAMPO IMP_VALOR_NETO
    UPDATE TB_PEDIDO_DETALLE SET IMP_VALOR_NETO = @IMP_VALOR_NETO WHERE ID_PEDIDO_DETALLE = @ID_PEDIDO_DETALLE
	--PARA EL CAMPO IMP_VALOR_TOTAL
    UPDATE TB_PEDIDO_DETALLE SET IMP_VALOR_TOTAL = @IMP_VALOR_TOTAL WHERE ID_PEDIDO_DETALLE = @ID_PEDIDO_DETALLE

	---Para el campo IMP_TOTAL_PEDIDO- TB_PEDIDO
	UPDATE TB_PEDIDO SET IMP_TOTAL_PEDIDO = (
	SELECT SUM(IMP_VALOR_TOTAL) FROM TB_PEDIDO_DETALLE WHERE ID_PEDIDO = @ID_PEDIDO
	) WHERE ID_PEDIDO = @ID_PEDIDO

    FETCH NEXT FROM CURSOR_DETALLE_TOTAL INTO @ID_PEDIDO_DETALLE, @ID_PEDIDO, @ID_PRODUCTO, @IMP_VALOR_NETO, @NUM_CANTIDAD, @FEC_CREACION
END

CLOSE CURSOR_DETALLE_TOTAL
DEALLOCATE CURSOR_DETALLE_TOTAL


SELECT * FROM TB_PEDIDO
SELECT * FROM TB_PEDIDO_DETALLE


