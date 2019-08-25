CREATE OR ALTER TRIGGER ModuleSigningDDLTrigger
    ON DATABASE
    WITH EXECUTE AS 'dbo'
    FOR
        CREATE_PROCEDURE, ALTER_PROCEDURE,
        CREATE_TRIGGER, ALTER_TRIGGER,
        CREATE_FUNCTION, ALTER_FUNCTION
AS
BEGIN
    DECLARE @event XML = EVENTDATA();

    DECLARE @SchemaName SYSNAME = @event.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname'),
        @ObjectName SYSNAME = @event.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname');

    BEGIN TRY
        EXEC [admin].SignObject
            @SchemaName = @SchemaName,
            @ObjectName = @ObjectName
    END TRY
    BEGIN CATCH
        THROW 50000, 'Module signing failed; rolling back change.', 1;
        ROLLBACK;
    END CATCH
END
