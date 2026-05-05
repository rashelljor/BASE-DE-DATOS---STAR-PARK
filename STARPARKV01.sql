CREATE DATABASE DB_StarParkV01
GO

-- ============================================================
-- BASE DE DATOS: StarParkV01
-- SCRIPT ORGANIZADO
-- ============================================================



-- ============================================================
-- 1. USO DE LA BASE DE DATOS
-- ============================================================
USE DB_StarParkV01
GO


-- ============================================================
-- 2. VALORES POR DEFECTO
-- ============================================================
CREATE DEFAULT Fecha_Actual_Hoy
	AS GETDATE()
GO


-- ============================================================
-- 3. REGLAS DE VALIDACIÓN
-- ============================================================
CREATE RULE Regla_Estado_Reclamo
	AS @col IN ('Pendiente', 'En revisión', 'Solucionado')
GO

CREATE RULE Valida_Correo
	AS @col LIKE '%_@__%.__%'
GO

CREATE RULE Regla_Estado_Met_Tipo
	AS @col IN ('Efectivo', 'Billetera Virtual')
GO

CREATE RULE Regla_Nombre_Met_Pago
	AS @col IN ('SOLES', 'DÓLARES', 'PLIN')
GO

CREATE RULE Regla_Precio_Monto
	AS @col >= 0.01
GO

CREATE RULE Regla_Estado_Transacción
	AS @col IN ('Pagada', 'Anulada', 'Devuelta')
GO

CREATE RULE Regla_Cantidad_Entera
	AS @col >= 1
GO

CREATE RULE Regla_Estado_Emp
	AS @col IN ('ACTIVO', 'INACTIVO')
GO

CREATE RULE Regla_Cargo_Emp
	AS @col IN ('OPERADOR', 'CAJERO', 'TÉCNICO', 'GERENTE', 'ADMINISTRADOR')
GO

CREATE RULE Regla_Fecha_Especial
	AS (@col >= '2010-01-01') AND (@col <= GETDATE())
GO

CREATE RULE Regla_Turno_Emp
	AS @col IN ('MAÑANA', 'TARDE')
GO

CREATE RULE Regla_Nombre_Categoría
	AS @col IN ('CONFITERÍA', 'SERVICIO', 'JUGUETE')
GO

CREATE RULE Regla_Estado_Prom
	AS @col IN ('VIGENTE', 'FINALIZADA')
GO

CREATE RULE Regla_Porcen_Prom
	AS @col BETWEEN 0.01 AND 100
GO


-- ============================================================
-- 4. TABLAS SIN CLAVES FORÁNEAS
-- ============================================================

-- Tabla: tblCategoría
CREATE TABLE tblCategoría
(
	ID_Categoría         varchar(8)   NOT NULL,
	cat_Nombre           varchar(30)  NOT NULL,
	cat_Descripción      varchar(50)  NOT NULL,
	CONSTRAINT XPKtblCategoría PRIMARY KEY (ID_Categoría ASC)
)
GO

-- Tabla: tblCliente
CREATE TABLE tblCliente
(
	DNI_Cliente          varchar(8)   NOT NULL,
	cli_RUC              varchar(11)  NULL,
	cli_Teléfono         varchar(11)  NOT NULL,
	cli_Nombre           varchar(30)  NOT NULL,
	cli_Apellido         varchar(30)  NOT NULL,
	cli_Email            varchar(50)  NOT NULL,
	CONSTRAINT XPKtblCliente PRIMARY KEY (DNI_Cliente ASC)
)
GO

-- Tabla: tblEmpleado
CREATE TABLE tblEmpleado
(
	ID_Empleado          varchar(8)   NOT NULL,
	emp_Nombre           varchar(30)  NOT NULL,
	emp_Apellido         varchar(30)  NOT NULL,
	emp_Cargo            varchar(20)  NOT NULL,
	emp_Teléfono         varchar(11)  NOT NULL,
	emp_FechaCont        datetime     NOT NULL,
	emp_Salario          decimal(8,2) NOT NULL,
	emp_Dirección        varchar(50)  NOT NULL,
	Turno_Caja           varchar(20)  NOT NULL,
	emp_Estado           varchar(20)  NOT NULL,
	CONSTRAINT XPKtblEmpleado PRIMARY KEY (ID_Empleado ASC)
)
GO

-- Tabla: tblMétodoPago
CREATE TABLE tblMétodoPago
(
	ID_MétodoPago        varchar(8)   NOT NULL,
	met_Nombre           varchar(30)  NOT NULL,
	met_Tipo             varchar(20)  NOT NULL,
	CONSTRAINT XPKtblMétodoPago PRIMARY KEY (ID_MétodoPago ASC)
)
GO

-- Tabla: tblProveedor
CREATE TABLE tblProveedor
(
	ID_Proveedor         varchar(8)   NOT NULL,
	prv_Ruc              varchar(20)  NOT NULL,
	prv_Teléfono         varchar(11)  NOT NULL,
	prv_Dirección        varchar(50)  NOT NULL,
	prv_Email            varchar(50)  NOT NULL,
	CONSTRAINT XPKtblProveedor PRIMARY KEY (ID_Proveedor ASC)
)
GO

-- Tabla: tblPromoción
CREATE TABLE tblPromoción
(
	ID_Promoción         varchar(8)   NOT NULL,
	prm_Nombre           varchar(30)  NOT NULL,
	prm_FechaIn          datetime     NOT NULL,
	prm_FechaFi          datetime     NOT NULL,
	prm_Estado           varchar(20)  NOT NULL,
	CONSTRAINT XPKtblPromoción PRIMARY KEY (ID_Promoción ASC)
)
GO


-- ============================================================
-- 5. TABLAS CON CLAVES FORÁNEAS
-- ============================================================

-- Tabla: tblProducto (depende de tblCategoría)
CREATE TABLE tblProducto
(
	ID_Producto          varchar(8)   NOT NULL,
	pro_Nombre           varchar(30)  NOT NULL,
	pro_Marca            varchar(20)  NOT NULL,
	pro_Descripción      varchar(50)  NOT NULL,
	pro_Precio           decimal(8,2) NOT NULL,
	pro_Stock            integer      NOT NULL,
	ID_Categoría         varchar(8)   NOT NULL,
	CONSTRAINT XPKtblProducto PRIMARY KEY (ID_Producto ASC),
	CONSTRAINT R_9 FOREIGN KEY (ID_Categoría)
		REFERENCES tblCategoría (ID_Categoría)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO

-- Tabla: tblReclamo (depende de tblCliente)
CREATE TABLE tblReclamo
(
	ID_Reclamo           varchar(8)   NOT NULL,
	rec_Fecha            datetime     NOT NULL,
	rec_Descripción      varchar(50)  NOT NULL,
	rec_Estado           varchar(20)  NOT NULL,
	DNI_Cliente          varchar(8)   NOT NULL,
	CONSTRAINT XPKtblReclamo PRIMARY KEY (ID_Reclamo ASC, DNI_Cliente ASC),
	CONSTRAINT R_1 FOREIGN KEY (DNI_Cliente)
		REFERENCES tblCliente (DNI_Cliente)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO

-- Tabla: tblTransacción (depende de tblCliente, tblMétodoPago, tblEmpleado)
CREATE TABLE tblTransacción
(
	ID_Transacción       integer      IDENTITY(1,1),
	tra_Fecha_Hora       datetime     NOT NULL,
	tra_MontoTotal       decimal(10,2) NOT NULL,
	tra_Estado           varchar(20)  NOT NULL,
	DNI_Cliente          varchar(8)   NOT NULL,
	ID_MétodoPago        varchar(8)   NOT NULL,
	ID_Empleado          varchar(8)   NOT NULL,
	CONSTRAINT XPKtblTransacción PRIMARY KEY (ID_Transacción ASC, DNI_Cliente ASC, ID_Empleado ASC),
	CONSTRAINT R_2 FOREIGN KEY (DNI_Cliente)
		REFERENCES tblCliente (DNI_Cliente)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT R_4 FOREIGN KEY (ID_MétodoPago)
		REFERENCES tblMétodoPago (ID_MétodoPago)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT R_7 FOREIGN KEY (ID_Empleado)
		REFERENCES tblEmpleado (ID_Empleado)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO

-- Tabla: tblDetalleCompra (depende de tblProducto, tblProveedor)
CREATE TABLE tblDetalleCompra
(
	ID_Producto          varchar(8)   NOT NULL,
	ID_Proveedor         varchar(8)   NOT NULL,
	detCo_CostoUnitario  decimal(8,2) NOT NULL,
	detCo_UnidadMedCom   varchar(50)  NOT NULL,
	detCo_Cantidad       integer      NOT NULL,
	detCo_CostoTotal     decimal(8,2) NOT NULL,
	CONSTRAINT XPKtblDetalleCompra PRIMARY KEY (ID_Producto ASC, ID_Proveedor ASC),
	CONSTRAINT R_11 FOREIGN KEY (ID_Producto)
		REFERENCES tblProducto (ID_Producto)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT R_18 FOREIGN KEY (ID_Proveedor)
		REFERENCES tblProveedor (ID_Proveedor)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO

-- Tabla: tblDetallePromoción (depende de tblProducto, tblPromoción)
CREATE TABLE tblDetallePromoción
(
	ID_Producto          varchar(8)   NOT NULL,
	ID_Promoción         varchar(8)   NOT NULL,
	detP_CantidadMin     integer      NOT NULL,
	detP_PorcentajeDes   decimal(8,2) NOT NULL,
	detP_LímiteClie      integer      NOT NULL,
	CONSTRAINT XPKtblDetallePromoción PRIMARY KEY (ID_Producto ASC, ID_Promoción ASC),
	CONSTRAINT R_12 FOREIGN KEY (ID_Producto)
		REFERENCES tblProducto (ID_Producto)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT R_16 FOREIGN KEY (ID_Promoción)
		REFERENCES tblPromoción (ID_Promoción)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO

-- Tabla: tblDetalleVenta (depende de tblProducto, tblTransacción)
CREATE TABLE tblDetalleVenta
(
	ID_Producto          varchar(8)   NOT NULL,
	ID_Transacción       integer      NOT NULL,
	DNI_Cliente          varchar(8)   NOT NULL,
	ID_Empleado          varchar(8)   NOT NULL,
	detV_Cantidad        integer      NOT NULL,
	detV_PrecioU         decimal(8,2) NOT NULL,
	detV_SubTotal        decimal(8,2) NOT NULL,
	CONSTRAINT XPKtblDetalleVenta PRIMARY KEY (ID_Producto ASC, ID_Transacción ASC, DNI_Cliente ASC, ID_Empleado ASC),
	CONSTRAINT R_10 FOREIGN KEY (ID_Producto)
		REFERENCES tblProducto (ID_Producto)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT R_14 FOREIGN KEY (ID_Transacción, DNI_Cliente, ID_Empleado)
		REFERENCES tblTransacción (ID_Transacción, DNI_Cliente, ID_Empleado)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO


-- ============================================================
-- 6. ASOCIACIÓN DE VALORES POR DEFECTO A COLUMNAS
-- ============================================================
EXEC sp_bindefault 'Fecha_Actual_Hoy', 'tblPromoción.prm_FechaIn'
GO

EXEC sp_bindefault 'Fecha_Actual_Hoy', 'tblReclamo.rec_Fecha'
GO

EXEC sp_bindefault 'Fecha_Actual_Hoy', 'tblTransacción.tra_Fecha_Hora'
GO


-- ============================================================
-- 7. ASOCIACIÓN DE REGLAS A COLUMNAS
-- ============================================================

-- tblCategoría
EXEC sp_bindrule 'Regla_Nombre_Categoría',   'tblCategoría.cat_Nombre'
GO

-- tblCliente
EXEC sp_bindrule 'Valida_Correo',             'tblCliente.cli_Email'
GO

-- tblDetalleCompra
EXEC sp_bindrule 'Regla_Precio_Monto',        'tblDetalleCompra.detCo_CostoUnitario'
GO
EXEC sp_bindrule 'Regla_Cantidad_Entera',     'tblDetalleCompra.detCo_Cantidad'
GO
EXEC sp_bindrule 'Regla_Precio_Monto',        'tblDetalleCompra.detCo_CostoTotal'
GO

-- tblDetallePromoción
EXEC sp_bindrule 'Regla_Cantidad_Entera',     'tblDetallePromoción.detP_CantidadMin'
GO
EXEC sp_bindrule 'Regla_Porcen_Prom',         'tblDetallePromoción.detP_PorcentajeDes'
GO
EXEC sp_bindrule 'Regla_Cantidad_Entera',     'tblDetallePromoción.detP_LímiteClie'
GO

-- tblDetalleVenta
EXEC sp_bindrule 'Regla_Cantidad_Entera',     'tblDetalleVenta.detV_Cantidad'
GO
EXEC sp_bindrule 'Regla_Precio_Monto',        'tblDetalleVenta.detV_PrecioU'
GO
EXEC sp_bindrule 'Regla_Precio_Monto',        'tblDetalleVenta.detV_SubTotal'
GO

-- tblEmpleado
EXEC sp_bindrule 'Regla_Cargo_Emp',           'tblEmpleado.emp_Cargo'
GO
EXEC sp_bindrule 'Regla_Fecha_Especial',      'tblEmpleado.emp_FechaCont'
GO
EXEC sp_bindrule 'Regla_Precio_Monto',        'tblEmpleado.emp_Salario'
GO
EXEC sp_bindrule 'Regla_Turno_Emp',           'tblEmpleado.Turno_Caja'
GO
EXEC sp_bindrule 'Regla_Estado_Emp',          'tblEmpleado.emp_Estado'
GO

-- tblMétodoPago
EXEC sp_bindrule 'Regla_Nombre_Met_Pago',     'tblMétodoPago.met_Nombre'
GO
EXEC sp_bindrule 'Regla_Estado_Met_Tipo',     'tblMétodoPago.met_Tipo'
GO

-- tblProducto
EXEC sp_bindrule 'Regla_Precio_Monto',        'tblProducto.pro_Precio'
GO

-- tblPromoción
EXEC sp_bindrule 'Regla_Estado_Prom',         'tblPromoción.prm_Estado'
GO

-- tblProveedor
EXEC sp_bindrule 'Valida_Correo',             'tblProveedor.prv_Email'
GO

-- tblReclamo
EXEC sp_bindrule 'Regla_Estado_Reclamo',      'tblReclamo.rec_Estado'
GO

-- tblTransacción
EXEC sp_bindrule 'Regla_Precio_Monto',        'tblTransacción.tra_MontoTotal'
GO
EXEC sp_bindrule 'Regla_Estado_Transacción',  'tblTransacción.tra_Estado'
GO
