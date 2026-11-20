# Esquema por versión de sing-box

El instalador ajusta esto solo. Este anexo es para mantener el repo.

| Campo | 1.12 | 1.13 | 1.14 | 1.15 | 1.16 |
|---|---|---|---|---|---|
| inet4_address | eliminado | - | - | - | - |
| sniff en inbound | válido | eliminado | - | - | - |
| Acción sniff en ruta | válido | válido | válido | válido | válido |
| DNS formato address | válido | válido | eliminado | - | - |
| DNS formato type y server | válido | válido | válido | válido | válido |
| stack | válido | válido | válido | deprecado | deprecado |

Reglas que aplica instalar.ps1

- Mínimo 1.12
- Menor de 1.14: DNS legacy con https://
- Menor de 1.13: sniff true en el inbound, sin regla sniff
- Menor de 1.15: incluye stack system

Si sale 1.17: quitar stack del todo y revisar https://sing-box.sagernet.org/migration/