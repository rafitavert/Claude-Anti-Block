# Manual técnico

> Para lectores no técnicos: GUIA-FACIL.md. Este documento es la referencia de detalle.

Tiempo estimado: 45 minutos. Léelo completo antes de empezar.

## Paso 0 — Elegir el proveedor

Necesitas un proxy ISP o static residential DEDICADO. No sirve:

- Residential por GB con rotación: la IP cambia y Claude lo nota.
- Datacenter puro: marcado como hosting.
- Planes "pay per IP" con IPs compartidas.

Al comprar, elige país y, si el panel lo permite, un ASN de operador de consumo. Evita ASN de hosting.

Verifica que el panel te dé IP numérica, puerto, usuario y contraseña. Prefiere SOCKS5 sobre HTTP: menos overhead por conexión y autenticación en el saludo, no por petición.

## Paso 1 — Carpeta y sing-box

1. Crea C:\sing-box
2. Descarga sing-box-*-windows-amd64.zip de https://github.com/SagerNet/sing-box/releases — versión entre 1.12 y 1.16.
3. Extrae sing-box.exe y libcronet.dll en C:\sing-box

## Paso 2 — Verificar la versión

    C:\sing-box\sing-box.exe version

Debe estar entre 1.12 y 1.16. Si es menor, el instalador rechaza.

## Paso 3 — Instalar

PowerShell como administrador, desde scripts:

    .\instalar.ps1 -Servidor 1.2.3.4 -Puerto 12324 -Usuario usuario -Clave clave -Protocolo socks

El instalador: resuelve el hostname si diste uno, descarga wintun.dll, detecta la versión, genera el config.json según el esquema que corresponda, valida con sing-box check, escribe ajustes.json y datos.txt, y copia los scripts operativos.

Si el check falla, revisa ANEXO-VERSIONES.md

## Paso 4 — Accesos directos

    .\crear-accesos.ps1

Verifica en Propiedades, Opciones avanzadas que ambos estén elevados. Deben mostrar el escudo.

## Paso 5 — Confirmar la ruta de Claude

    Get-ChildItem "$env:LOCALAPPDATA\AnthropicClaude", "$env:LOCALAPPDATA\Programs" -Filter claude.exe -Recurse -ErrorAction SilentlyContinue
    Get-AppxPackage *Claude*

Si lo segundo devuelve algo, es app de Store y la ruta es dinámica: los scripts ya lo manejan, no hagas nada.

## Paso 6 — Primer arranque

Cierra Chrome. Botón 1. Debes ver la IP en verde y las apps abriéndose.

    Get-NetAdapter -Name tun-claude | Select Status

Debe ser Up. La IP del adaptador debe ser 172.19.0.1

## Paso 7 — Validar la IP

    Invoke-RestMethod "http://ip-api.com/json/?fields=query,countryCode,isp,org,as"

País correcto y as de operador real. Si org es hosting puro, pide reemplazo antes de usar la cuenta.

## Paso 8 — Fugas

whoer.net, ipleak.net (lista de DNS), browserleaks.com/webrtc

Esperado: IP del proxy, DNS del mismo país, sin IP local en WebRTC, Proxy: No

## Paso 9 — Kill switch

Con las apps abiertas, apaga el Wi-Fi. Cierre en aproximadamente un segundo.

    Get-Content C:\sing-box\killswitch.log -Tail 1

Debe decir CORTE: sin adaptador fisico activo

## Paso 10 — Firewall

Con el túnel apagado, abre Claude con el icono original y manda un mensaje. Debe fallar.

Si conecta, corre .\firewall.ps1 como administrador y repite.

## Paso 11 — Limpieza

Borra el icono original del Escritorio y de la barra de tareas.

## Uso diario

Botón 1, trabajar, botón 2. Tras un corte: 2 y luego 1.

## Mantenimiento

- Renueva antes del vencimiento. Si cambian IP o puerto, vuelve a correr instalar.ps1
- Tras cada actualización de Claude, arranca una vez con el botón para regenerar el firewall.
- Diagnóstico con .\estado.ps1