$carpeta = "C:\sing-box"
. "$carpeta\comun.ps1"
$esperada = (Get-Ajustes).esperada
$log = "$carpeta\killswitch.log"
$contador = 0

function Cortar($motivo) {
    "$(Get-Date -f 'HH:mm:ss') CORTE: $motivo" | Out-File $log -Append -Encoding utf8
    Stop-Process -Name "claude" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "chrome" -Force -ErrorAction SilentlyContinue
}

while ($true) {
    $tun = Get-NetAdapter -Name "tun-claude" -ErrorAction SilentlyContinue
    $proceso = Get-Process -Name "sing-box" -ErrorAction SilentlyContinue
    $fisica = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Up" }

    if (-not $tun -or $tun.Status -ne "Up") { Cortar "adaptador tun-claude caido o ausente"; break }
    if (-not $proceso) { Cortar "proceso sing-box terminado"; break }
    if (-not $fisica) { Cortar "sin adaptador fisico activo"; break }

    $contador++
    if ($contador -ge 10) {
        $contador = 0
        $ip = Get-IPPublica
        if (-not $ip) { Cortar "sin respuesta del verificador de IP"; break }
        if ($ip -ne $esperada) { Cortar "IP de salida distinta ($ip)"; break }
    }
    Start-Sleep -Milliseconds 1000
}