Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$id = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$carpeta = "C:\sing-box"
$gris = [System.Drawing.Color]::Gray
$verde = [System.Drawing.Color]::Green
$rojo = [System.Drawing.Color]::Red

$form = New-Object System.Windows.Forms.Form
$form.Text = "Estado del entorno"
$form.ClientSize = New-Object System.Drawing.Size(420, 420)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true
$form.FormBorderStyle = "Sizable"
$form.MaximizeBox = $false

$lblModo = New-Object System.Windows.Forms.Label
$lblModo.SetBounds(15, 15, 390, 52)
$lblModo.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblModo.TextAlign = "MiddleCenter"
$lblModo.Text = "COMPROBANDO"
$lblModo.BackColor = [System.Drawing.Color]::FromArgb(90,90,90)
$lblModo.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($lblModo)

$fuente = New-Object System.Drawing.Font("Consolas", 10)

function NuevoIndicador($y, $texto) {
    $l = New-Object System.Windows.Forms.Label
    $l.SetBounds(15, $y, 390, 24)
    $l.Font = $fuente
    $l.ForeColor = $gris
    $l.Text = $texto
    $form.Controls.Add($l)
    return $l
}

$lblTun = NuevoIndicador 76  "Tunel: ..."
$lblFw  = NuevoIndicador 102 "Firewall: ..."
$lblVig = NuevoIndicador 128 "Vigilante: ..."
$lblVPN = NuevoIndicador 154 "VPN: ..."
$lblIP  = NuevoIndicador 180 "IP: ..."

$bOn = New-Object System.Windows.Forms.Button
$bOn.SetBounds(15, 216, 125, 38); $bOn.Text = "Encender"
$form.Controls.Add($bOn)

$bOff = New-Object System.Windows.Forms.Button
$bOff.SetBounds(148, 216, 125, 38); $bOff.Text = "Apagar"
$form.Controls.Add($bOff)

$bFwOn = New-Object System.Windows.Forms.Button
$bFwOn.SetBounds(281, 216, 124, 38); $bFwOn.Text = "Firewall ON"
$form.Controls.Add($bFwOn)

$bFwOff = New-Object System.Windows.Forms.Button
$bFwOff.SetBounds(15, 261, 190, 38); $bFwOff.Text = "Firewall OFF (modo VPN)"
$form.Controls.Add($bFwOff)

$bDatos = New-Object System.Windows.Forms.Button
$bDatos.SetBounds(213, 261, 192, 38); $bDatos.Text = "Abrir datos.txt"
$form.Controls.Add($bDatos)

$lblNota = New-Object System.Windows.Forms.Label
$lblNota.SetBounds(15, 309, 390, 100)
$lblNota.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$lblNota.ForeColor = [System.Drawing.Color]::DimGray
$lblNota.Text = "Modo Claude: tunel arriba, Claude sale por tu proxy. Modo Normal: tunel apagado, Claude encerrado si el firewall sigue puesto. Desconecta el VPN antes de encender."
$form.Controls.Add($lblNota)

$script:esperada = ""
try { $script:esperada = (Get-Content "C:\sing-box\ajustes.json" -Raw | ConvertFrom-Json).esperada } catch { }

$script:cargaHasta = [DateTime]::Now.AddSeconds(10)
$script:ip = ""
$script:tun = $false
$script:fw = -1
$script:vig = $null
$script:vpn = $null
$script:n1 = 99
$script:n2 = 99
$script:n3 = 99

function Refrescar {
    $cargando = [DateTime]::Now -lt $script:cargaHasta

    if ($script:tun) { $lblTun.Text = "Tunel: ACTIVO"; $lblTun.ForeColor = $verde }
    else { $lblTun.Text = "Tunel: apagado"; $lblTun.ForeColor = $gris }

    if ($cargando -and $script:fw -lt 0) { $lblFw.Text = "Firewall: consultando..."; $lblFw.ForeColor = $gris }
    elseif ($script:fw -gt 0) { $lblFw.Text = "Firewall: BLOQUEANDO ($($script:fw) reglas)"; $lblFw.ForeColor = $verde }
    else { $lblFw.Text = "Firewall: APAGADO"; $lblFw.ForeColor = $rojo }

    if ($cargando -and $script:vig -eq $null) { $lblVig.Text = "Vigilante: consultando..."; $lblVig.ForeColor = $gris }
    elseif ($script:vig) { $lblVig.Text = "Vigilante: CORRIENDO"; $lblVig.ForeColor = $verde }
    else { $lblVig.Text = "Vigilante: detenido"; $lblVig.ForeColor = $gris }

    if ($cargando -and $script:vpn -eq $null) { $lblVPN.Text = "VPN: consultando..."; $lblVPN.ForeColor = $gris }
    elseif ($script:vpn) { $lblVPN.Text = "VPN: CONECTADO (conflicto)"; $lblVPN.ForeColor = $rojo }
    else { $lblVPN.Text = "VPN: desconectado"; $lblVPN.ForeColor = $gris }

    if ($script:ip -eq "") {
        $lblIP.Text = "IP: consultando..."; $lblIP.ForeColor = $gris
    } elseif (-not $script:tun) {
        $lblIP.Text = "IP actual: $($script:ip)"; $lblIP.ForeColor = $gris
    } elseif ($script:esperada -ne "" -and $script:ip -eq $script:esperada) {
        $lblIP.Text = "IP: $($script:ip) / $($script:esperada)"; $lblIP.ForeColor = $verde
    } else {
        $lblIP.Text = "IP: $($script:ip) / $($script:esperada)"; $lblIP.ForeColor = $rojo
    }

    $okIP = ($script:esperada -ne "" -and $script:ip -eq $script:esperada)

    if ($cargando) {
        $lblModo.Text = "COMPROBANDO"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(90,90,90); $lblModo.ForeColor = [System.Drawing.Color]::White
    } elseif ($script:tun -and $script:fw -gt 0 -and $script:vig -and $okIP -and -not $script:vpn) {
        $lblModo.Text = "MODO CLAUDE - PROTEGIDO"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(30,123,52); $lblModo.ForeColor = [System.Drawing.Color]::White
    } elseif ($script:tun -and $script:ip -ne "" -and -not $okIP) {
        $lblModo.Text = "MODO CLAUDE - IP INCORRECTA (FUGA)"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(178,34,34); $lblModo.ForeColor = [System.Drawing.Color]::White
    } elseif (-not $script:tun -and $script:fw -gt 0) {
        $lblModo.Text = "MODO NORMAL - PROTEGIDO"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(20,107,123); $lblModo.ForeColor = [System.Drawing.Color]::White
    } elseif (-not $script:tun -and $script:fw -eq 0) {
        $lblModo.Text = "MODO NORMAL - DESPROTEGIDO"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(139,32,32); $lblModo.ForeColor = [System.Drawing.Color]::White
    } else {
        $lblModo.Text = "PARCIAL - REVISAR"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(184,134,11); $lblModo.ForeColor = [System.Drawing.Color]::White
    }
}

function ForzarCarga {
    $script:cargaHasta = [DateTime]::Now.AddSeconds(10)
    $script:fw = -1; $script:vig = $null; $script:vpn = $null; $script:ip = ""
    $script:n1 = 99; $script:n2 = 99; $script:n3 = 99
    Refrescar
}

$t1 = New-Object System.Windows.Forms.Timer
$t1.Interval = 1000
$t1.Add_Tick({
    try { $script:tun = (Get-NetAdapter -Name "tun-claude" -ErrorAction SilentlyContinue).Status -eq "Up" } catch { $script:tun = $false }
    Refrescar

    $script:n1++
    if ($script:n1 -ge 2) {
        $script:n1 = 0
        try { $script:vig = [bool](Get-CimInstance Win32_Process -Filter "CommandLine LIKE '%killswitch.ps1%'" -ErrorAction SilentlyContinue) } catch { $script:vig = $false }
        try {
            $script:vpn = [bool](Get-NetAdapter -ErrorAction SilentlyContinue |
                Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -match "VPN|WireGuard|TAP|OpenVPN|Tailscale|Proton|Nord|Express" })
        } catch { $script:vpn = $false }
        Refrescar
    }

    $script:n2++
    if ($script:n2 -ge 3) {
        $script:n2 = 0
        try { $script:fw = @(Get-NetFirewallRule -DisplayName "Bloquear Claude fuera de TUN*" -ErrorAction SilentlyContinue | Where-Object { $_.Enabled -eq "True" }).Count } catch { $script:fw = 0 }
        Refrescar
    }

    $script:n3++
    if ($script:n3 -ge 10) {
        $script:n3 = 0
        try { $script:ip = (Invoke-RestMethod -Uri "http://ip-api.com/json/?fields=status,query" -TimeoutSec 4).query } catch { $script:ip = "sin respuesta" }
        Refrescar
    }
})

$bOn.Add_Click({ ForzarCarga; Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$carpeta\iniciar_claude.ps1`"" })
$bOff.Add_Click({ ForzarCarga; Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$carpeta\apagar_claude.ps1`"" })
$bFwOn.Add_Click({ ForzarCarga; Get-NetFirewallRule -DisplayName "Bloquear Claude fuera de TUN*" -ErrorAction SilentlyContinue | Enable-NetFirewallRule })
$bFwOff.Add_Click({ ForzarCarga; Get-NetFirewallRule -DisplayName "Bloquear Claude fuera de TUN*" -ErrorAction SilentlyContinue | Disable-NetFirewallRule })
$bDatos.Add_Click({ Start-Process notepad.exe "C:\sing-box\datos.txt" })

$form.Add_Shown({ Refrescar; $t1.Start() })
[System.Windows.Forms.Application]::Run($form)