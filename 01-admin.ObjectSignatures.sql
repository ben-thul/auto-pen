IF SCHEMA_ID('admin') IS NULL
    exec('CREATE SCHEMA [admin] AUTHORIZATION dbo;');
go
IF OBJECT_ID('admin.ObjectSignatures') IS NULL
BEGIN

    CREATE TABLE [admin].ObjectSignatures (
        SchemaName      sysname NOT NULL ,
        ObjectName      sysname NOT NULL ,
        CertificateName sysname NOT NULL
    );

    CREATE UNIQUE CLUSTERED INDEX [CIX_ObjectSignatures]
        ON [admin].ObjectSignatures (SchemaName, ObjectName, CertificateName);
END
GO
