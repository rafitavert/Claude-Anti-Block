# claude-tun-lockdown

Túnel a nivel de sistema en Windows para usar Claude Desktop desde un país bloqueado, con una IP de proxy fija y salida a prueba de fugas.

No es una VPN. Es un candado: si el túnel no está sano, Claude no sale a ningún lado.

## Qué hace

- Levanta un TUN con sing-box y fuerza todo el tráfico del sistema por tu proxy.
- Bloquea DNS y rutas alternas con strict_route.
- Verifica que la IP de salida sea exactamente la de tu proxy antes de abrir nada.
- Vigila el túnel cada segundo y cierra Claude y Chrome si cae o si la IP cambia.
- Bloquea a Claude en el Firewall de Windows para que no pueda usar la tarjeta física.

## Qué no hace

- No te vuelve invisible. Si la IP se quema, el setup sigue impecable y te quedas sin acceso.
- No evita que Anthropic detecte que estás fuera por otras señales.
- No sirve para torrents ni juegos: los proxies ISP son TCP y UDP va bloqueado a propósito.
- No funciona con planes de rotación por GB.

## Requisitos

- Windows 10 u 11, 64 bits, permisos de administrador.
- Proxy ISP o static residential dedicado, IP fija, usuario y contraseña.
- sing-box 1.14.4 probado. El instalador acepta de 1.12 a 1.16 y rechaza el resto.
- Claude Desktop instalado, por instalador normal o por Microsoft Store.
- 100 GB mensuales o más.

## Por dónde empiezo

| Si eres... | Abre |
|---|---|
| Primera vez con proxies, quieres seguir sin tecnicismos | GUIA-FACIL.md |
| Ya sabes de redes o necesitas el detalle | MANUAL-TECNICO.md |

## Instalación en una línea

Desde la carpeta del repo, como administrador:

    .\instalar.ps1 -Servidor 1.2.3.4 -Puerto 12324 -Usuario usuario -Clave clave -Protocolo socks

Instalar no basta: hay que verificar fugas y probar el kill switch. Sigue la guía.

## Advertencias

- Usa una sola IP. Cambiarla a media sesión es tan mala señal como una IP sucia.
- Entra a Claude con correo y contraseña, no con Google.
- Nunca abras Claude antes del túnel ni lo dejes abierto al cambiar de red.
- Los proveedores de ISP proxy alojan las IPs en datacenter bajo un ASN de operador. Es la categoría del producto, no un defecto de este repo. Si necesitas una residencial pura, este enfoque no te la da. Si necesitas una residencial pura, este enfoque no te la da. Si necesitas una residencial pura, este enfoque no te la da.

## Licencia

MIT.