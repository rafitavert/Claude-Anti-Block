$carpeta = "C:\sing-box"
. "$carpeta\comun.ps1"

"Proceso sing-box ....... $(if (Get-Process sing-box -EA SilentlyContinue) {'OK'} else {'FALTA'})"
"Adaptador tun-claude ... $(if ((Get-NetAdapter -Name tun-claude -EA SilentlyContinue).Status -eq 'Up') {'OK'} else {'CAIDO'})"
"Vigilante .............. $(if (Get-CimInstance Win32_Process -Filter "CommandLine LIKE '%killswitch.ps1%'") {'OK'} else {'FALTA'})"
"IP de salida ........... $(Get-IPPublica)"
$aj = $null; try { $aj = Get-Ajustes } catch {}
"IP esperada ............ $(if ($aj) { $aj.esperada } else { 'sin ajustes.json' })"
"Reglas de firewall ..... $(@(Get-NetFirewallRule -DisplayName 'Bloquear Claude fuera de TUN*' -EA SilentlyContinue).Count)"
"Adaptadores activos .... $(@(Get-NetAdapter -Physical -EA SilentlyContinue | Where-Object Status -eq 'Up').Count)"