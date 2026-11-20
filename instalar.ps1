[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Servidor,
    [Parameter(Mandatory)][int]$Puerto,
    [Parameter(Mandatory)][string]$Usuario,
    [Parameter(Mandatory)][string]$Clave,
    [ValidateSet("socks","http")][string]$Protocolo = "socks",
    [string]$ServidorDNS = "1.1.1.1",
    [string]$WintunUrl = "https://www.wintun.net/builds/wintun-0.14.1.zip",
    [string]$Destino = "C:\sing-box"
)

. "$PSScriptRoot\comun.ps1"

if (-not (Test-Admin)) { Write-Host "Ejecuta como administrador." -ForegroundColor Red; exit 1 }
if (-not (Test-Path "$Destino\sing-box.exe")) {
    Write-Host "No encuentro sing-box.exe en $Destino. Descargalo de SagerNet/sing-box." -ForegroundColor Red; exit 1
}

$salida = (& "$Destino\sing-box.exe" version 2>&1 | Out-String)
if ($salida -notmatch 'version\s+(\d+)\.(\d+)\.(\d+)') {
    Write-Host "No pude leer la version de sing-box." -ForegroundColor Red; exit 1
}
$maj = [int]$Matches[1]; $min = [int]$Matches[2]; $rev = [int]$Matches[3]
if ($maj -lt 1 -or ($maj -eq 1 -and $min -lt 12)) {
    Write-Host "Requiere sing-box 1.12 o superior. Tienes $maj.$min.$rev." -ForegroundColor Red; exit 1
}
Write-Host "sing-box $maj.$min.$rev detectado." -ForegroundColor Cyan

$esperada = $Servidor
if ($Servidor -notmatch '^\d{1,3}(\.\d{1,3}){3}$') {
    try {
        $esperada = ([System.Net.Dns]::GetHostAddresses($Servidor) |
            Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
            Select-Object -First 1).IPAddressToString
        Write-Host "Hostname resuelto a $esperada" -ForegroundColor Cyan
    } catch {
        Write-Host "No pude resolver $Servidor. Usa la IP numerica." -ForegroundColor Red; exit 1
    }
}

if (-not (Test-Path "$Destino\wintun.dll")) {
    Write-Host "Descargando wintun.dll..." -ForegroundColor Cyan
    $zip = Join-Path $env:TEMP "wintun.zip"
    try {
        Invoke-WebRequest -Uri $WintunUrl -OutFile $zip -UseBasicParsing
        Expand-Archive -Path $zip -DestinationPath "$env:TEMP\wintun" -Force
        Copy-Item "$env:TEMP\wintun\bin\amd64\wintun.dll" "$Destino\wintun.dll" -Force
        Write-Host "wintun.dll instalada." -ForegroundColor Green
    } catch {
        Write-Host "Fallo la descarga. Bajala de wintun.net y ponla en $Destino." -ForegroundColor Red; exit 1
    }
}

if ($maj -eq 1 -and $min -lt 14) {
    $dns = '{ "address": "https://' + $ServidorDNS + '/dns-query", "tag": "dns-remoto", "detour": "proxy-isp" }'
} else {
    $dns = '{ "type": "https", "tag": "dns-remoto", "server": "' + $ServidorDNS + '", "detour": "proxy-isp" }'
}

if ($maj -eq 1 -and $min -lt 13) {
    $sniffIn = '"sniff": true,'
    $sniffRule = ""
} else {
    $sniffIn = ""
    $sniffRule = '{ "action": "sniff" },'
}

if ($maj -eq 1 -and $min -lt 15) { $stack = '"stack": "system",' } else { $stack = "" }

$cfg = Get-Content "$PSScriptRoot\config.template.json" -Raw
$cfg = $cfg.Replace("__DNS__", $dns).Replace("__SNIFF_IN__", $sniffIn).Replace("__SNIFF_RULE__", $sniffRule)
$cfg = $cfg.Replace("__STACK__", $stack).Replace("__TIPO__", $Protocolo).Replace("__SERVIDOR__", $Servidor)
$cfg = $cfg.Replace("__PUERTO__", $Puerto).Replace("__USUARIO__", $Usuario).Replace("__CLAVE__", $Clave)
Set-Content -Path "$Destino\config.json" -Value $cfg -Encoding ASCII

& "$Destino\sing-box.exe" check -c "$Destino\config.json"
if ($LASTEXITCODE -ne 0) { Write-Host "config.json invalido." -ForegroundColor Red; exit 1 }

@{ esperada = $esperada; puerto = $Puerto; tipo = $Protocolo } |
    ConvertTo-Json | Set-Content "$Destino\ajustes.json" -Encoding ASCII

Copy-Item "$PSScriptRoot\killswitch.ps1", "$PSScriptRoot\firewall.ps1", "$PSScriptRoot\iniciar_claude.ps1",
    "$PSScriptRoot\apagar_claude.ps1", "$PSScriptRoot\estado.ps1", "$PSScriptRoot\comun.ps1", "$PSScriptRoot\panel.ps1" $Destino -Force

@"
IP: $esperada
Puerto: $Puerto
Usuario: $Usuario
Clave: $Clave
Protocolo: $Protocolo
Instalado: $(Get-Date -f 'yyyy-MM-dd HH:mm')
sing-box: $maj.$min.$rev
Recuperacion tras corte: boton 2, luego boton 1
"@ | Set-Content "$Destino\datos.txt" -Encoding ASCII

Write-Host ""
Write-Host "Instalacion lista. Siguiente: .\crear-accesos.ps1" -ForegroundColor Green