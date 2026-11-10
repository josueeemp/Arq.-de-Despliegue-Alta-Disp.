
param(
    [Parameter(Mandatory=$true)]
    [string]$OutputFile
)

if (Test-Path $OutputFile) {
    Remove-Item $OutputFile
}

Write-Host "Ejecutando 200 solicitudes..."

for ($i = 1; $i -le 200; $i++) {
    $tempFile = [System.IO.Path]::GetTempFileName()

    try {
        $output = curl.exe -sS -o $tempFile -w "%{http_code} %{time_total}" http://localhost:8080/v1/products 2>$null

        $body = Get-Content -Raw -Path $tempFile 2>$null |
            ForEach-Object { $_ -replace "`r?`n", ' ' }

        $line = "{0:D3} {1} {2}" -f $i, $output, $body

        Add-Content -Path $OutputFile -Value $line
        Write-Host $line
    }
    finally {
        Remove-Item -Force $tempFile -ErrorAction SilentlyContinue
    }
}

$lines = Get-Content $OutputFile

$total = $lines.Count
$success = ($lines | Where-Object { $_ -like '*"status":"SUCCESS"*' }).Count
$http200 = ($lines | Where-Object { $_ -match '^\d+\s+200\s+' }).Count
$httpErrors = $total - $http200

Write-Host "`nRESULTADOS"
Write-Host "Respuestas SUCCESS: $success"
Write-Host "Respuestas HTTP 200: $http200"
Write-Host "Respuestas distintas de 200: $httpErrors"
Write-Host "Solicitudes totales: $total"

if ($total -gt 0) {
    $availability = [math]::Round($http200 / $total, 4)
    Write-Host "Disponibilidad observada: $availability"
}
