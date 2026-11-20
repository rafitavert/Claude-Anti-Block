# Guía fácil

Para ti, si nunca has configurado un proxy y quieres que Claude funcione desde un país donde está bloqueado.

Tiempo: unos 45 minutos, con calma.

---

## Qué vas a montar

Tu computadora tiene dos puertas: la de tu internet normal y una nueva que va a otro país.

Este montaje cierra la puerta normal para Claude y lo obliga a salir siempre por la nueva. Si la nueva se atasca, Claude se cierra solo en vez de escaparse por la de siempre.

La meta no es esconderte: es que Claude nunca te vea desde tu país.

## Lo que necesitas comprar

Un proxy dedicado y fijo en Estados Unidos. Se compra en un proveedor de proxies, no es una VPN.

Tres reglas al comprar:

1. Dedicado. Solo tuyo. Si dice "compartida" o "pay per IP", no sirve.
2. Fijo. La IP no debe cambiar sola.
3. Estados Unidos, y si puedes elegir operador, uno de casa (Comcast, Verizon, AT&T, Spectrum). Evita los que digan "datacenter" u "hosting".

Presupuesto típico: 3 a 6 dólares al mes.

Al terminar la compra el panel te dará cuatro datos: IP, puerto, usuario y contraseña. Apúntalos en papel.

## Antes de empezar necesitas

- Windows 10 u 11.
- Claude Desktop instalado y con sesión iniciada.
- Correo y contraseña para entrar a Claude (no uses "Continuar con Google").
- Permisos de administrador.

---

## Paso 1. Crear la carpeta

1. Abre el Explorador de archivos.
2. Ve a C:\
3. Clic derecho, Nuevo, Carpeta.
4. Nómbrala exactamente: sing-box

## Paso 2. Meter el motor

1. Entra a https://github.com/SagerNet/sing-box/releases
2. Busca la última versión que empiece por 1.14 y descarga el archivo que termina en windows-amd64.zip.
3. Abre el ZIP y copia sing-box.exe y libcronet.dll dentro de C:\sing-box

Debes tener dos archivos ahí. Nada más por ahora.

## Paso 3. Instalar

1. Inicio, escribe PowerShell, clic derecho, Ejecutar como administrador.
2. Escribe cd y un espacio, arrastra la carpeta del repo a la ventana. Enter.
3. Copia la línea de abajo, cambia los cuatro datos y pégala:

    .\instalar.ps1 -Servidor TU_IP -Puerto TU_PUERTO -Usuario TU_USUARIO -Clave TU_CLAVE -Protocolo socks

Deberías ver: un mensaje verde de "Instalación lista".

Si ves rojo: no sigas. Busca el mensaje en SOLUCION-PROBLEMAS.md

## Paso 4. Los dos botones

    .\crear-accesos.ps1

Crea dos iconos en el Escritorio. Deben tener un escudito azul y amarillo. Si no: clic derecho, Propiedades, Opciones avanzadas, Ejecutar como administrador.

## Paso 5. Primer encendido

Cierra Chrome.

Doble clic en 1. Iniciar Entorno Claude. Acepta el aviso de Windows.

Deberías ver: ventana negra, línea verde con tu IP nueva, y luego Claude y Chrome abriéndose solos.

Si la ventana se cierra con letras rojas, el problema está en el proxy o el puerto.

## Paso 6. Comprobar que estás en otro país

En el Chrome abierto:

1. Entra a whoer.net y mira el país: debe ser Estados Unidos.
2. Entra a ipleak.net y baja a los servidores DNS: deben ser estadounidenses.

Si el país sigue siendo el tuyo, apaga con el botón 2 y revisa.

## Paso 7. Probar el freno

Con Claude abierto, apaga el Wi-Fi.

Deberías ver: Claude y Chrome cerrarse solos en un segundo.

Vuelve a encender el Wi-Fi.

## Paso 8. La prueba final

1. Apaga con el botón 2.
2. Abre Claude con el icono viejo y manda un mensaje.

Deberías ver: que no se envía, o un aviso de falta de conexión.

3. Ciérralo, enciende con el botón 1 y manda otro mensaje. Ahora sí debe responder.

Si en el punto 2 el mensaje se envía igual, avisa: falta un bloqueo.

## Paso 9. Ordenar

Borra el icono viejo de Claude del Escritorio y de la barra de tareas. Solo se abre con el botón 1.

---

## Uso diario

1. Botón 1. Espera la línea verde.
2. Trabaja.
3. Botón 2 al terminar.

Si se corta el internet: botón 2, luego botón 1. Nunca reconectes y sigas.

## Las cinco reglas

1. Claude solo se abre con el botón 1.
2. Cierra Claude antes de apagar el túnel o cambiar de red.
3. Si cambiaste de Wi-Fi, apaga y vuelve a encender antes de abrir Claude.
4. No cambies de IP a media conversación.
5. Renueva el proxy antes de que venza.

## Palabras raras

- Proxy: intermediario en otro país. El sitio web ve su dirección, no la tuya.
- IP dedicada: dirección que es solo tuya. Apartamento propio, no hotel.
- TUN: puerta falsa que captura todo el tráfico y lo manda por el proxy.
- Kill switch: el freno. Si la puerta falsa falla, cierra Claude.
- Firewall: lista de bloqueo de Windows que impide que Claude use tu internet normal.

## Si algo sale mal

Busca tu síntoma en SOLUCION-PROBLEMAS.md. Si abres un issue, incluye qué paso hacías, qué viste y el resultado de .\estado.ps1