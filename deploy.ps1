param(
[Parameter(Mandatory=$true)]
[string]$SqlInstance,


[Parameter(Mandatory=$true)]
[string]$Database
)

$files = @(
    '01-admin.ObjectSignatures.sql',
    '02-admin.SignObject.sql',
    '03-ModuleSigningDDLTrigger.sql'
);

foreach ($file in $files) {
    invoke-sqlcmd -ServerInstance $SqlInstance -Database $Database -InputFile $file;
}
