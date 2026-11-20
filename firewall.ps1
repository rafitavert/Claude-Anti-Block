. "$PSScriptRoot\comun.ps1"
if (-not (Test-Admin)) { Write-Host "Ejecuta como administrador." -ForegroundColor Red; exit 1 }

$info = Get-ClaudeInfo
if (-not $info) { Write-Host "No encontre claude.exe." -ForegroundColor Red; exit 1 }
Write-Host "Ejecutable: $($info.Path)" -ForegroundColor Cyan

Get-NetFirewallRule -DisplayName "Bloquear Claude fuera de TUN*" -ErrorAction SilentlyContinue | Remove-NetFirewallRule

$fisicas = Get-NetAdapter -Physical | Where-Object { $_.InterfaceDescription -notmatch "Miniport" }
if (-not $fisicas) { Write-Host "No hay adaptadores fisicos." -ForegroundColor Red; exit 1 }

foreach ($a in $fisicas) {
    New-NetFirewallRule -DisplayName "Bloquear Claude fuera de TUN ($($a.Name))" `
        -Direction Outbound -Program $info.Path -Action Block -Profile Any -InterfaceAlias $a.Name | Out-Null
}
Write-Host "Reglas creadas en $($fisicas.Count) adaptador(es)." -ForegroundColor Green
$fisicas | Select-Object Name, InterfaceDescription, Status | Format-Table -AutoSize