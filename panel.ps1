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
$LIMITE = 14

$sync = [hashtable]::Synchronized(@{})
$sync.tun = $false
$sync.fw = -1
$sync.vig = $null
$sync.vpn = $null
$sync.ip = ""
$sync.ipFecha = [DateTime]::MinValue
$sync.stop = $false
$sync.esperada = ""
try { $sync.esperada = (Get-Content "$carpeta\ajustes.json" -Raw | ConvertFrom-Json).esperada } catch { }

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
$lblNota.Text = "Las consultas corren en segundo plano: la ventana no se bloquea. Si la IP sale gris, la lectura esta vencida."
$form.Controls.Add($lblNota)

$script:cargaHasta = [DateTime]::Now.AddSeconds(6)

function Refrescar {
    $cargando = [DateTime]::Now -lt $script:cargaHasta
    $edad = ([DateTime]::Now - $sync.ipFecha).TotalSeconds
    $fresco = ($sync.ip -ne "" -and $sync.ip -ne "sin respuesta" -and $edad -le $LIMITE)
    $okIP = ($fresco -and $sync.esperada -ne "" -and $sync.ip -eq $sync.esperada)

    if ($sync.tun) { $lblTun.Text = "Tunel: ACTIVO"; $lblTun.ForeColor = $verde }
    else { $lblTun.Text = "Tunel: apagado"; $lblTun.ForeColor = $gris }

    if ($sync.fw -lt 0) { $lblFw.Text = "Firewall: consultando..."; $lblFw.ForeColor = $gris }
    elseif ($sync.fw -gt 0) { $lblFw.Text = "Firewall: BLOQUEANDO ($($sync.fw) reglas)"; $lblFw.ForeColor = $verde }
    else { $lblFw.Text = "Firewall: APAGADO"; $lblFw.ForeColor = $rojo }

    if ($sync.vig -eq $null) { $lblVig.Text = "Vigilante: consultando..."; $lblVig.ForeColor = $gris }
    elseif ($sync.vig) { $lblVig.Text = "Vigilante: CORRIENDO"; $lblVig.ForeColor = $verde }
    else { $lblVig.Text = "Vigilante: detenido"; $lblVig.ForeColor = $gris }

    if ($sync.vpn -eq $null) { $lblVPN.Text = "VPN: consultando..."; $lblVPN.ForeColor = $gris }
    elseif ($sync.vpn) { $lblVPN.Text = "VPN: CONECTADO (conflicto)"; $lblVPN.ForeColor = $rojo }
    else { $lblVPN.Text = "VPN: desconectado"; $lblVPN.ForeColor = $gris }

    if ($sync.ip -eq "") {
        $lblIP.Text = "IP: consultando..."; $lblIP.ForeColor = $gris
    } elseif (-not $fresco) {
        $lblIP.Text = "IP: sin dato fresco"; $lblIP.ForeColor = $gris
    } elseif (-not $sync.tun) {
        $lblIP.Text = "IP actual: $($sync.ip)"; $lblIP.ForeColor = $gris
    } elseif ($okIP) {
        $lblIP.Text = "IP: $($sync.ip) / $($sync.esperada)"; $lblIP.ForeColor = $verde
    } else {
        $lblIP.Text = "IP: $($sync.ip) / $($sync.esperada)"; $lblIP.ForeColor = $rojo
    }

    if ($cargando) {
        $lblModo.Text = "COMPROBANDO"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(90,90,90); $lblModo.ForeColor = [System.Drawing.Color]::White
    } elseif ($sync.tun -and -not $fresco) {
        $lblModo.Text = "SIN DATO FRESCO"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(90,90,90); $lblModo.ForeColor = [System.Drawing.Color]::White
    } elseif ($sync.tun -and $sync.fw -gt 0 -and $sync.vig -and $okIP -and -not $sync.vpn) {
        $lblModo.Text = "MODO CLAUDE - PROTEGIDO"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(30,123,52); $lblModo.ForeColor = [System.Drawing.Color]::White
    } elseif ($sync.tun -and -not $okIP) {
        $lblModo.Text = "MODO CLAUDE - IP INCORRECTA (FUGA)"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(178,34,34); $lblModo.ForeColor = [System.Drawing.Color]::White
    } elseif (-not $sync.tun -and $sync.fw -gt 0) {
        $lblModo.Text = "MODO NORMAL - PROTEGIDO"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(20,107,123); $lblModo.ForeColor = [System.Drawing.Color]::White
    } elseif (-not $sync.tun -and $sync.fw -eq 0) {
        $lblModo.Text = "MODO NORMAL - DESPROTEGIDO"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(139,32,32); $lblModo.ForeColor = [System.Drawing.Color]::White
    } else {
        $lblModo.Text = "PARCIAL - REVISAR"
        $lblModo.BackColor = [System.Drawing.Color]::FromArgb(184,134,11); $lblModo.ForeColor = [System.Drawing.Color]::White
    }
}

function ForzarCarga {
    $script:cargaHasta = [DateTime]::Now.AddSeconds(6)
    $sync.fw = -1; $sync.vig = $null; $sync.vpn = $null
    $sync.ip = ""; $sync.ipFecha = [DateTime]::MinValue
    Refrescar
}

$worker = {
    param($s)
    . "C:\sing-box\comun.ps1"
    $c1 = 0; $c2 = 0; $c3 = 0
    while (-not $s.stop) {
        try { $s.tun = (Get-NetAdapter -Name "tun-claude" -ErrorAction SilentlyContinue).Status -eq "Up" } catch { $s.tun = $false }

        $c1++
        if ($c1 -ge 2) {
            $c1 = 0
            try { $s.vig = [bool](Get-CimInstance Win32_Process -Filter "CommandLine LIKE '%killswitch.ps1%'" -ErrorAction SilentlyContinue) } catch { $s.vig = $false }
            try {
                $s.vpn = [bool](Get-NetAdapter -ErrorAction SilentlyContinue |
                    Where-Object { $_.Status -eq "Up" -and $_.Name -ne "tun-claude" -and $_.InterfaceDescription -match "VPN|WireGuard|Wintun|TAP|OpenVPN|Tailscale|Proton|Nord|Express|SonicWall|AnyConnect|Fortinet|ZeroTier|Mullvad|Surfshark|Windscribe|CyberGhost|L2TP|IKEv2|GlobalProtect" })
            } catch { $s.vpn = $false }
        }

        $c2++
        if ($c2 -ge 4) {
            $c2 = 0
            try { $s.fw = @(Get-NetFirewallRule -DisplayName "Bloquear Claude fuera de TUN*" -ErrorAction SilentlyContinue | Where-Object { $_.Enabled -eq "True" }).Count } catch { $s.fw = 0 }
        }

        $c3++
        if ($c3 -ge 6) {
            $c3 = 0
            $r = Get-IPPublica
            if ($r) { $s.ip = $r; $s.ipFecha = [DateTime]::Now } else { $s.ip = "sin respuesta" }
        }

        Start-Sleep -Milliseconds 1000
    }
}

$ps = [powershell]::Create()
[void]$ps.AddScript($worker).AddArgument($sync)
$handle = $ps.BeginInvoke()

$t1 = New-Object System.Windows.Forms.Timer
$t1.Interval = 400
$t1.Add_Tick({ Refrescar })

$bOn.Add_Click({ ForzarCarga; Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$carpeta\iniciar_claude.ps1`"" })
$bOff.Add_Click({ ForzarCarga; Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$carpeta\apagar_claude.ps1`"" })
$bFwOn.Add_Click({ ForzarCarga; Get-NetFirewallRule -DisplayName "Bloquear Claude fuera de TUN*" -ErrorAction SilentlyContinue | Enable-NetFirewallRule })
$bFwOff.Add_Click({ ForzarCarga; Get-NetFirewallRule -DisplayName "Bloquear Claude fuera de TUN*" -ErrorAction SilentlyContinue | Disable-NetFirewallRule })
$bDatos.Add_Click({ Start-Process notepad.exe "C:\sing-box\datos.txt" })

$form.Add_Shown({ Refrescar; $t1.Start() })
$form.Add_FormClosing({
    $sync.stop = $true
    $t1.Stop()
    Start-Sleep -Milliseconds 150
    try { $ps.Stop() } catch { }
    try { $ps.Dispose() } catch { }
})

[System.Windows.Forms.Application]::Run($form)