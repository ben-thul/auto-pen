CREATE OR ALTER PROCEDURE [admin].SignObject (
    @SchemaName sysname = NULL,
    @ObjectName sysname = NULL
)
AS
BEGIN
    DECLARE @SigningStatement NVARCHAR(max) = (
        SELECT CONCAT('add signature to ',
            cte.FullName,
            ' by certificate ',
            QUOTENAME(c.name), ';'
        )
        FROM (
            SELECT CONCAT(QUOTENAME(o.SchemaName), '.', QUOTENAME(o.ObjectName)) AS FullName ,
                o.CertificateName
            FROM [admin].ObjectSignatures as o
            WHERE (ObjectName = @ObjectName OR @ObjectName IS NULL)
                AND (SchemaName = @SchemaName OR @SchemaName IS NULL)
        ) AS cte

        -- only sign objects that exist
        JOIN sys.objects as o
            ON o.object_id = OBJECT_ID(cte.FullName)

        -- if specified certificate doesn't exist, still try to sign the object
        -- by it, but this will fail.
        LEFT JOIN sys.certificates AS c
            ON cte.CertificateName = c.name

        -- if signature by specified certificate is missing, try to add it
        LEFT JOIN sys.crypt_properties AS sigs
            ON sigs.major_id = o.object_id
            AND sigs.thumbprint = c.thumbprint
        WHERE sigs.thumbprint IS NULL
        FOR XML PATH('')
    );

    IF(@SigningStatement IS NOT NULL)
    BEGIN
        PRINT @SigningStatement;
        EXEC(@SigningStatement);
    END
END
GO
