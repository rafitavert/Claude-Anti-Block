Write-Host "Cerrando aplicaciones..." -ForegroundColor Yellow
Stop-Process -Name "claude" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "chrome" -Force -ErrorAction SilentlyContinue

Get-CimInstance Win32_Process -Filter "CommandLine LIKE '%killswitch.ps1%'" |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

Start-Sleep -Seconds 2
Write-Host "Apagando tunel..." -ForegroundColor Cyan
Stop-Process -Name "sing-box" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

if (Get-NetAdapter -Name "tun-claude" -ErrorAction SilentlyContinue) {
    Write-Host "Aviso: el adaptador tun-claude sigue presente." -ForegroundColor Yellow
}
Write-Host "Conexion local restaurada." -ForegroundColor Green
Start-Sleep -Seconds 2