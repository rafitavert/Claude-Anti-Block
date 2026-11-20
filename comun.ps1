function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    return (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-ClaudeInfo {
    $pkg = Get-AppxPackage *Claude* -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pkg) {
        $e = Join-Path $pkg.InstallLocation "app\claude.exe"
        if (-not (Test-Path $e)) {
            $e = (Get-ChildItem $pkg.InstallLocation -Filter claude.exe -Recurse -Force -ErrorAction SilentlyContinue |
                Select-Object -First 1).FullName
        }
        if ($e) { return [pscustomobject]@{ Path = $e; Kind = "store"; Package = $pkg } }
    }
    $p = "$env:LOCALAPPDATA\AnthropicClaude\claude.exe"
    if (Test-Path $p) { return [pscustomobject]@{ Path = $p; Kind = "instalador"; Package = $null } }
    $alt = Get-ChildItem "$env:LOCALAPPDATA\Programs" -Filter claude.exe -Recurse -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($alt) { return [pscustomobject]@{ Path = $alt.FullName; Kind = "instalador"; Package = $null } }
    return $null
}

function Start-ClaudeApp($info) {
    if ($info.Kind -eq "store") {
        $man = Join-Path $info.Package.InstallLocation 'AppxManifest.xml'
        $appId = @(([xml](Get-Content $man)).Package.Applications.Application)[0].Id
        Start-Process "shell:AppsFolder\$($info.Package.PackageFamilyName)!$appId"
    } else {
        Start-Process -FilePath $info.Path
    }
}

function Get-Ajustes {
    return Get-Content "C:\sing-box\ajustes.json" -Raw | ConvertFrom-Json
}

function Get-IPPublica {
    try {
        $o = & curl.exe -s --max-time 5 "http://ip-api.com/json/?fields=status,query"
        if ($o -match '"query":"([^"]+)"') { return $Matches[1] }
        return $null
    } catch { return $null }
}
