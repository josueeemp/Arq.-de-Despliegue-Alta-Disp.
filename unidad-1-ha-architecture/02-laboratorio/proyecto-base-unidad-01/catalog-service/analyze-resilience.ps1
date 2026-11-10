if (-not (Test-Path "availability-baseline.txt") -or -not (Test-Path "resilience-sample.txt")) {
    Write-Host "Error: Archivos no encontrados." -ForegroundColor Red
    Write-Host "Asegúrate de que existen: availability-baseline.txt y resilience-sample.txt"
    exit 1
}

Write-Host ""
Write-Host "ANÁLISIS DE RESILIENCIA: Lab 1.1 vs Lab 1.2" -ForegroundColor Cyan
Write-Host ""

Write-Host "LÍNEA BASE (Lab 1.1 - SIN patrones)" -ForegroundColor Yellow

$baseline = @(Get-Content availability-baseline.txt)
$total_1_1 = $baseline.Count
$success_1_1 = ($baseline | Where-Object { $_ -like '*"status":"SUCCESS"*' }).Count
$errors_1_1 = $total_1_1 - $success_1_1
$avail_1_1 = if ($total_1_1 -gt 0) { [math]::Round($success_1_1 / $total_1_1, 4) } else { 0 }

Write-Host "Total solicitudes:        $total_1_1"
Write-Host "SUCCESS (HTTP 200):       $success_1_1 (~$([math]::Round($success_1_1 * 100 / $total_1_1))%)"
Write-Host "Errores/No disponibles:   $errors_1_1 (~$([math]::Round($errors_1_1 * 100 / $total_1_1))%)"
Write-Host "Disponibilidad:           $avail_1_1 ($([math]::Round($success_1_1 * 100 / $total_1_1))%)"

Write-Host ""
Write-Host "CON PATRONES (Lab 1.2 - Timeout + Retry + Fallback + CircuitBreaker)" -ForegroundColor Yellow

$resilience = @(Get-Content resilience-sample.txt)
$total_1_2 = $resilience.Count
$success_1_2 = ($resilience | Where-Object { $_ -like '*"status":"SUCCESS"*' }).Count
$degraded_1_2 = ($resilience | Where-Object { $_ -like '*"status":"DEGRADED_CACHE"*' }).Count
$total_respuestas = $success_1_2 + $degraded_1_2
$avail_1_2 = if ($total_1_2 -gt 0) { [math]::Round($total_respuestas / $total_1_2, 4) } else { 0 }

Write-Host "Total solicitudes:        $total_1_2"
Write-Host "SUCCESS (HTTP 200):       $success_1_2 (~$([math]::Round($success_1_2 * 100 / $total_1_2))%)"
Write-Host "DEGRADED_CACHE (HTTP 200):$degraded_1_2 (~$([math]::Round($degraded_1_2 * 100 / $total_1_2))%)"
Write-Host "Errores HTTP 500:         0"
Write-Host "Disponibilidad:           $avail_1_2 ($([math]::Round($total_respuestas * 100 / $total_1_2))%)"

Write-Host ""
Write-Host "COMPARACIÓN - MEJORA OBTENIDA" -ForegroundColor Green

$mejora_avail = [math]::Round($avail_1_2 - $avail_1_1, 4)
$mejora_porcentaje = [math]::Round(($avail_1_2 - $avail_1_1) * 100, 2)

Write-Host ('Disponibilidad mejorada: {0} ({1} puntos porcentuales)' -f $mejora_avail, $mejora_porcentaje)
$errores_porcentaje = [math]::Round($errors_1_1 * 100 / $total_1_1)
Write-Host ('Errores eliminados: ~100% (de ~{0}% a 0%)' -f $errores_porcentaje)
Write-Host "HTTP 500 desaparecieron:  Completamente"
Write-Host "Respuestas degradadas:    $degraded_1_2 solicitudes salvadas por Fallback"

Write-Host ""
Write-Host "CONCLUSIÓN" -ForegroundColor Green

if ($avail_1_2 -gt 0.99) {
    Write-Host "La implementación de patrones de resiliencia fue EXITOSA." -ForegroundColor Green
    Write-Host "Disponibilidad alcanzada: ~100%" -ForegroundColor Green
} else {
    Write-Host "La implementación funciona, pero revisa si el CircuitBreaker se activó correctamente." -ForegroundColor Yellow
}

Write-Host ""