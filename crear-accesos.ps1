. "$PSScriptRoot\comun.ps1"
if (-not (Test-Admin)) { Write-Host "Ejecuta como administrador." -ForegroundColor Red; exit 1 }

$sh = New-Object -ComObject WScript.Shell
$d  = [Environment]::GetFolderPath("Desktop")

function New-Acceso($nombre, $script, $icono, $oculto) {
    $lnk = Join-Path $d "$nombre.lnk"
    $s = $sh.CreateShortcut($lnk)
    $s.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $s.Arguments = $(if ($oculto) { "-WindowStyle Hidden " } else { "" }) + "-ExecutionPolicy Bypass -File `"C:\sing-box\$script`""
    $s.WorkingDirectory = "C:\sing-box"
    $s.IconLocation = "C:\Windows\System32\shell32.dll,$icono"
    $s.Save()
    $bb = [IO.File]::ReadAllBytes($lnk); $bb[0x15] = $bb[0x15] -bor 0x20; [IO.File]::WriteAllBytes($lnk, $bb)
    Write-Host "Creado: $nombre" -ForegroundColor Green
}

New-Acceso "0. Panel de Estado" "panel.ps1" 21 $true
New-Acceso "1. Iniciar Entorno Claude" "iniciar_claude.ps1" 137 $false
New-Acceso "2. Apagar Tunel" "apagar_claude.ps1" 131 $false

Write-Host ""
Write-Host "Verifica que los tres tengan 'Ejecutar como administrador' marcado." -ForegroundColor Yellow