# setup_db.ps1 - Applies schema.sql and seed.sql to Neon via ODBC
# Run from d:\prolog:  powershell -ExecutionPolicy Bypass -File db\setup_db.ps1

$ErrorActionPreference = 'Stop'

# Load .env
$envFile = Join-Path $PSScriptRoot "..\\.env"
if (Test-Path $envFile) {
    foreach ($line in Get-Content $envFile) {
        if ($line -match '^\s*#' -or $line -match '^\s*$') { continue }
        if ($line -match '^([^=]+)=(.*)$') {
            $k = $Matches[1].Trim()
            $v = $Matches[2].Trim().Trim("'").Trim('"')
            [System.Environment]::SetEnvironmentVariable($k, $v, 'Process')
        }
    }
    Write-Host '.env loaded.'
} else {
    Write-Host 'No .env file found - using shell environment variables.'
}

$pghost = $env:PGHOST
$pgdb   = $env:PGDATABASE
$pguser = $env:PGUSER
$pgpass = $env:PGPASSWORD
$pgssl  = if ($env:PGSSLMODE) { $env:PGSSLMODE } else { 'require' }

$connStr = "DRIVER={PostgreSQL Unicode(x64)};Server=$pghost;Port=5432;Database=$pgdb;Uid=$pguser;Pwd=$pgpass;SSLmode=$pgssl;"

Write-Host "Connecting to $pgdb on $pghost ..."
$conn = New-Object System.Data.Odbc.OdbcConnection($connStr)
$conn.Open()
Write-Host 'Connected.'

function Run-SqlFile {
    param([string]$Path)
    $sql = Get-Content $Path -Raw
    # Split on semicolons (non-capturing) - let PostgreSQL handle inline comments
    $statements = $sql -split ';' | Where-Object { $_.Trim() -ne '' }
    $ok = 0; $skipped = 0
    foreach ($stmt in $statements) {
        $s = $stmt.Trim()
        if ($s -eq '') { continue }
        try {
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $s
            $cmd.CommandTimeout = 30
            $null = $cmd.ExecuteNonQuery()
            $ok++
        } catch {
            $preview = $s -replace '\s+', ' '
            $preview = $preview.Substring(0, [Math]::Min(80, $preview.Length))
            Write-Warning "  SKIP: $preview"
            $skipped++
        }
    }
    Write-Host "  $ok statements executed, $skipped skipped."
}

$schemaFile = Join-Path $PSScriptRoot 'schema.sql'
$seedFile   = Join-Path $PSScriptRoot 'seed.sql'

Write-Host 'Running schema.sql ...'
Run-SqlFile $schemaFile
Write-Host 'Schema done.'

Write-Host 'Running seed.sql ...'
Run-SqlFile $seedFile
Write-Host 'Seed done.'

$conn.Close()
Write-Host 'Database setup complete.'
