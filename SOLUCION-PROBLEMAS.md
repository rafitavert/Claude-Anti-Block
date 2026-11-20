# Problemas

## El check falla con "json: unknown field"

Versión incompatible de sing-box. Ver ANEXO-VERSIONES.md

## La línea verde no sale

1. Test-NetConnection IP -Port PUERTO. Si TcpTestSucceeded es False, la red bloquea el puerto o las credenciales están mal.
2. Prueba a mano:

    curl.exe -x socks5h://usuario:clave@ip:puerto https://ipinfo.io/json

3. Revisa que el campo tipo en ajustes.json coincida con el puerto real.

## El adaptador no levanta

Falta wintun.dll, falta administrador, u otra VPN ocupa el TUN. Ciérralas.

## Claude conecta sin túnel

El firewall no aplica. Corre .\firewall.ps1 como administrador y verifica:

    Get-NetFirewallRule -DisplayName "Bloquear Claude fuera de TUN*" | Select DisplayName, Enabled, Action

## Claude no conecta ni con túnel

Confirma que tun-claude está Up y la IP de salida es la esperada. Revisa que la regla reject de UDP/443 siga presente en config.json

## Cortes falsos del kill switch

La IP cambió sin intervención tuya. El plan no es estático o el proveedor rotó la salida.

## ERR_QUIC_PROTOCOL_ERROR constante

Normal en la primera carga: Chromium cae a TCP. Si persiste, revisa la regla de UDP/443.

## WSL2 o VirtualBox sin red

strict_route los rompe. Excluye el adaptador virtual en route_exclude_address o desactiva strict_route mientras los uses.

## Redes con portal cautivo

El TUN no levanta hasta pasar el portal. Conéctate, pasa el portal con Claude cerrado y recién entonces arranca.

## La app de Claude se actualizó y el firewall dejó de bloquear

La ruta del ejecutable cambió. Arranca una vez con el botón 1: firewall.ps1 resuelve la ruta nueva solo.