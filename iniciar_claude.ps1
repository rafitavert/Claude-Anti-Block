$carpeta = "C:\sing-box"
. "$carpeta\comun.ps1"

if (-not (Test-Admin)) { Write-Host "Este script necesita administrador." -ForegroundColor Red; Pause; exit }
foreach ($f in "config.json", "ajustes.json", "wintun.dll", "sing-box.exe") {
    if (-not (Test-Path "$carpeta\$f")) { Write-Host "Falta $f en $carpeta" -ForegroundColor Red; Pause; exit }
}

$aj = Get-Ajustes
$info = Get-ClaudeInfo
if (-not $info) { Write-Host "No encontre Claude instalado." -ForegroundColor Red; Pause; exit }

Write-Host "Validando configuracion..." -ForegroundColor Cyan
& "$carpeta\sing-box.exe" check -c "$carpeta\config.json"
if ($LASTEXITCODE -ne 0) { Write-Host "config.json invalido." -ForegroundColor Red; Pause; exit }

Write-Host "Levantando tunel..." -ForegroundColor Cyan
Start-Process -FilePath "$carpeta\sing-box.exe" -ArgumentList "run -c `"$carpeta\config.json`"" -WorkingDirectory $carpeta -WindowStyle Hidden

for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Milliseconds 500
    if ((Get-NetAdapter -Name "tun-claude" -ErrorAction SilentlyContinue).Status -eq "Up") { break }
}
if ((Get-NetAdapter -Name "tun-claude" -ErrorAction SilentlyContinue).Status -ne "Up") {
    Write-Host "El adaptador tun-claude no levanto." -ForegroundColor Red
    Stop-Process -Name "sing-box" -Force -ErrorAction SilentlyContinue; Pause; exit
}

Start-Sleep -Seconds 2
$ip = Get-IPPublica
if (-not $ip) {
    Write-Host "Sin respuesta al verificar la salida. Revisa credenciales y puerto." -ForegroundColor Red
    Stop-Process -Name "sing-box" -Force -ErrorAction SilentlyContinue; Pause; exit
}
if ($ip -ne $aj.esperada) {
    Write-Host "ALERTA: salida $ip, esperaba $($aj.esperada). Abortando." -ForegroundColor Red
    Stop-Process -Name "sing-box" -Force -ErrorAction SilentlyContinue; Pause; exit
}
Write-Host "Salida verificada: $ip" -ForegroundColor Green

Write-Host "Aplicando reglas de firewall..." -ForegroundColor Cyan
& "$carpeta\firewall.ps1" | Out-Null

Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File $carpeta\killswitch.ps1"
Start-ClaudeApp $info
Start-Process -FilePath "chrome.exe"