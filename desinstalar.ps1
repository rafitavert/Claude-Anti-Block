. "$PSScriptRoot\comun.ps1"
if (-not (Test-Admin)) { Write-Host "Ejecuta como administrador." -ForegroundColor Red; exit 1 }

& "C:\sing-box\apagar_claude.ps1"

Get-NetFirewallRule -DisplayName "Bloquear Claude fuera de TUN*" -EA SilentlyContinue | Remove-NetFirewallRule
$d = [Environment]::GetFolderPath("Desktop")
Remove-Item "$d\1. Iniciar Entorno Claude.lnk", "$d\2. Apagar Tunel.lnk" -EA SilentlyContinue

Write-Host ""
Write-Host "Desinstalado: reglas y accesos directos." -ForegroundColor Green
Write-Host "C:\sing-box se conserva. Borra la carpeta a mano si quieres." -ForegroundColor Yellow