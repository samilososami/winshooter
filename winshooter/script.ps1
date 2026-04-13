# ================================================================
#  WINSHOOTER/SCRIPT.PS1 — by samilososami
#  Backend HTTP local para WINSHOOTER
#
#  Instalacion rapida:
#    irm winshooter.samilososami.com | iex
#  O directamente:
#    irm https://raw.githubusercontent.com/samilososami/winshooter/master/winshooter/script.ps1 | iex
#  Ejecucion manual:
#    powershell -ExecutionPolicy Bypass -File script.ps1
# ================================================================

param([int]$Port = 8080)

# ── CONFIG ───────────────────────────────────────────────────────
$OLLAMA_API_KEY = "9c18372f50a647908ea90588c5e0fdd2.U5AnkkJ2TYa8zoA05W_65Xcf"
$OLLAMA_API_URL = "https://ollama.com/api/chat"

# TLS 1.2 obligatorio para HTTPS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Forzar codificacion UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ── DESCARGAR INDEX.HTML A CARPETA TEMPORAL ──────────────────────
$TEMP_DIR  = Join-Path $env:TEMP "winshooter"
$HTML_PATH = Join-Path $TEMP_DIR "index.html"
$HTML_URL  = "https://raw.githubusercontent.com/samilososami/winshooter/master/winshooter/index.html"

if (-not (Test-Path $TEMP_DIR)) {
    New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null
}

Write-Host ""
Write-Host "  Descargando interfaz... " -NoNewline -ForegroundColor DarkGray
try {
    Invoke-WebRequest -Uri $HTML_URL -OutFile $HTML_PATH -UseBasicParsing
    Write-Host "[OK]" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] No se pudo descargar index.html" -ForegroundColor Red
    Write-Host "  $_" -ForegroundColor DarkRed
    exit 1
}

# ── DIRECTORIO TEMPORAL PARA SCRIPTS ────────────────────────────
$TEMP_SCRIPTS_DIR = Join-Path $TEMP_DIR "scripts"
if (-not (Test-Path $TEMP_SCRIPTS_DIR)) {
    New-Item -ItemType Directory -Path $TEMP_SCRIPTS_DIR -Force | Out-Null
}

# ── EJECUCION DE COMANDOS (SIN RESTRICCIONES) ───────────────────
function Invoke-AnyCommand {
    param([string]$Cmd)
    try {
        $out = Invoke-Expression $Cmd 2>&1 | Out-String
        return @{ success = $true; output = ($out -replace "`r","").Trim() }
    } catch {
        try {
            $out = cmd /c "$Cmd" 2>&1 | Out-String
            return @{ success = $true; output = ($out -replace "`r","").Trim() }
        } catch {
            return @{ success = $false; output = "Error al ejecutar comando: $($_.Exception.Message)" }
        }
    }
}

function Invoke-TempScript {
    param([string]$FileName, [string]$Content, [string]$Extension = "ps1")
    try {
        $safeName = $FileName -replace '[^a-zA-Z0-9_\-]', '_'
        $scriptPath = Join-Path $TEMP_SCRIPTS_DIR "$safeName.$Extension"
        [IO.File]::WriteAllText($scriptPath, $Content, [Text.Encoding]::UTF8)
        Write-Host "  [SCRIPT] Creado: $scriptPath" -ForegroundColor DarkCyan
        if ($Extension -eq "ps1") {
            $out = powershell -ExecutionPolicy Bypass -File $scriptPath 2>&1 | Out-String
        } elseif ($Extension -eq "bat" -or $Extension -eq "cmd") {
            $out = cmd /c "$scriptPath" 2>&1 | Out-String
        } elseif ($Extension -eq "vbs") {
            $out = cscript //NoLogo $scriptPath 2>&1 | Out-String
        } else {
            $out = Invoke-Expression "& '$scriptPath'" 2>&1 | Out-String
        }
        return @{ success = $true; output = ($out -replace "`r","").Trim(); path = $scriptPath }
    } catch {
        return @{ success = $false; output = "Error al ejecutar script: $($_.Exception.Message)"; path = "" }
    }
}

# ── HELPERS HTTP ─────────────────────────────────────────────────
function Send-Bytes {
    param($Res, [int]$Status, [string]$CT, [byte[]]$Bytes)
    $Res.StatusCode      = $Status
    $Res.ContentType     = $CT
    $Res.ContentLength64 = $Bytes.Length
    $Res.OutputStream.Write($Bytes, 0, $Bytes.Length)
    $Res.Close()
}
function Send-Text {
    param($Res, [int]$Status = 200, [string]$Text)
    $b = [Text.Encoding]::UTF8.GetBytes($Text)
    Send-Bytes $Res $Status "text/plain; charset=utf-8" $b
}
function Send-Json {
    param($Res, [int]$Status = 200, [string]$Json)
    $b = [Text.Encoding]::UTF8.GetBytes($Json)
    Send-Bytes $Res $Status "application/json; charset=utf-8" $b
}
function Read-Body {
    param($Req)
    (New-Object IO.StreamReader($Req.InputStream, [Text.Encoding]::UTF8)).ReadToEnd()
}

# ── INICIO DEL SERVIDOR ──────────────────────────────────────────
$listener = New-Object Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")

try {
    $listener.Start()
} catch {
    Write-Host ""
    Write-Host "  [ERROR] No se puede iniciar en el puerto $Port" -ForegroundColor Red
    Write-Host "  Prueba: powershell -ExecutionPolicy Bypass -File script.ps1 -Port 8081" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Pulsa Enter para salir"
    exit 1
}

Write-Host ""
Write-Host "  ___       ___  ________   ________  ___  ___  ________  ________  _________  _______   ________     " -ForegroundColor White
Write-Host " |\  \     |\  \|\   ___  \|\   ____\|\  \|\  \|\   __  \|\   __  \|\___   ___\\  ___ \ |\   __  \    " -ForegroundColor White
Write-Host " \ \  \    \ \  \ \  \\ \  \ \  \___|\ \  \\\  \ \  \|\  \ \  \|\  \|___ \  \_\ \   __/|\ \  \|\  \   " -ForegroundColor DarkGray
Write-Host "  \ \  \  __\ \  \ \  \\ \  \ \_____  \ \   __  \ \  \\\  \ \  \\\  \   \ \  \ \ \  \_|/_\ \   _  _\  " -ForegroundColor DarkGray
Write-Host "   \ \  \|\__\_\  \ \  \\ \  \|____|\  \ \  \ \  \ \  \\\  \ \  \\\  \   \ \  \ \ \  \_|\ \ \  \\  \| " -ForegroundColor DarkGray
Write-Host "    \ \____________\ \__\\ \__\____\_\  \ \__\ \__\ \_______\ \_______\   \ \__\ \ \_______\ \__\\ _\ " -ForegroundColor White
Write-Host "     \|____________|\|__| \|__|\_________\|__|\|__|\|_______|\|_______|    \|__|  \|_______|\|__|\|__|" -ForegroundColor White
Write-Host ""
Write-Host "  by samilososami" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Servidor activo:   http://localhost:$Port/" -ForegroundColor Cyan
Write-Host "  Modelo por defecto: minimax-m2.7:cloud" -ForegroundColor DarkGray
Write-Host "  Pulsa Ctrl+C para detener" -ForegroundColor DarkGray
Write-Host ""

$GLOBAL:WHOAMI_OUTPUT = (whoami 2>$null) -replace "`r","" -replace "`n",""

Write-Host "  Identificando usuario... " -NoNewline -ForegroundColor DarkGray
try {
    $wcName = New-Object Net.WebClient
    $wcName.Encoding = [System.Text.Encoding]::UTF8
    $wcName.Headers["Content-Type"] = "application/json"
    $wcName.Headers["Authorization"] = "Bearer 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"
    $wcName.Headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    $safeW = $GLOBAL:WHOAMI_OUTPUT -replace '\\','\\\\'
    $bodyName = '{"model":"llama-3.1-8b-instant","stream":false,"messages":[{"role":"system","content":"El usuario te enviara su nombre de usuario de Windows. Devuelve UNICAMENTE el nombre con el que se le saludara. Si ves un nombre real (DaniPro22 -> Daniel), usalo. Si es raro o tecnico (admin, userx), dejalo igual. Sin comillas ni nada mas."},{"role":"user","content":"' + $safeW + '"}]}'
    $resultName = $wcName.UploadString("https://api.groq.com/openai/v1/chat/completions", "POST", $bodyName)
    $parsed = $resultName | ConvertFrom-Json
    $extractedName = $parsed.choices[0].message.content.Trim()
    if ($extractedName.Length -gt 20 -or $extractedName.ToLower().Contains("hola") -or $extractedName.Contains(" ")) {
        $parts = $GLOBAL:WHOAMI_OUTPUT.Split('\')
        $extractedName = $parts[$parts.Length-1]
        if ($extractedName.Length -gt 0) { $extractedName = $extractedName.Substring(0,1).ToUpper() + $extractedName.Substring(1).ToLower() }
    }
    $GLOBAL:USERNAME = $extractedName
    Write-Host "[OK] $($GLOBAL:USERNAME)" -ForegroundColor Green
} catch {
    $parts = $GLOBAL:WHOAMI_OUTPUT.Split('\')
    $GLOBAL:USERNAME = $parts[$parts.Length-1]
    if ($GLOBAL:USERNAME.Length -gt 0) { $GLOBAL:USERNAME = $GLOBAL:USERNAME.Substring(0,1).ToUpper() + $GLOBAL:USERNAME.Substring(1).ToLower() }
    Write-Host "[Local] $($GLOBAL:USERNAME)" -ForegroundColor Yellow
}

Start-Process "http://localhost:$Port/"

# ── BUCLE PRINCIPAL ───────────────────────────────────────────────
$keepRunning = $true
[Console]::TreatControlCAsInput = $false
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action { $script:keepRunning = $false }

try {
    while ($keepRunning -and $listener.IsListening) {
        $contextTask = $listener.GetContextAsync()
        while (-not $contextTask.AsyncWaitHandle.WaitOne(500)) {
            if (-not $keepRunning) { break }
        }
        if (-not $keepRunning -or -not $contextTask.IsCompleted) { break }

        try {
            $ctx = $contextTask.GetAwaiter().GetResult()
            $req = $ctx.Request
            $res = $ctx.Response

            $res.Headers.Add("Access-Control-Allow-Origin",  "*")
            $res.Headers.Add("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
            $res.Headers.Add("Access-Control-Allow-Headers", "Content-Type,Authorization")

            if ($req.HttpMethod -eq "OPTIONS") { $res.StatusCode = 204; $res.Close(); continue }

            $path = $req.Url.LocalPath

            # ── GET / → servir index.html desde carpeta temporal
            if ($path -notlike "/api/*" -and $req.HttpMethod -eq "GET") {
                if (Test-Path $HTML_PATH) {
                    $b = [IO.File]::ReadAllBytes($HTML_PATH)
                    $res.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
                    $res.Headers.Add("Pragma", "no-cache")
                    $res.Headers.Add("Expires", "0")
                    Send-Bytes $res 200 "text/html; charset=utf-8" $b
                    Write-Host "  [GET]  $path" -ForegroundColor DarkGray
                } else {
                    Send-Text $res 404 "ERROR: index.html no encontrado en $HTML_PATH"
                    Write-Host "  [404]  index.html no encontrado" -ForegroundColor Red
                }
            }

            # ── POST /api/chat → proxy IA
            elseif ($path -eq "/api/chat" -and $req.HttpMethod -eq "POST") {
                $body = Read-Body $req
                $targetUrl = $OLLAMA_API_URL
                $targetKey = $OLLAMA_API_KEY
                $headers = @{
                    "Authorization" = "Bearer $targetKey"
                    "Content-Type"  = "application/json"
                }
                if ($body -like '*"model":"llama-3.1-8b-instant"*') {
                    $targetUrl = "https://api.groq.com/openai/v1/chat/completions"
                    $headers["Authorization"] = "Bearer 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"
                    $headers["User-Agent"]    = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
                }
                try {
                    $resProxy = Invoke-WebRequest -Uri $targetUrl -Method Post -Body $body -Headers $headers -ContentType "application/json"
                    Send-Bytes $res 200 "application/json; charset=utf-8" $resProxy.Content
                    Write-Host "  [CHAT] OK" -ForegroundColor Green
                } catch {
                    $statusCode = 502
                    if ($_.Exception.Response) { $statusCode = [int]$_.Exception.Response.StatusCode }
                    $errMsg = $_.Exception.Message
                    Write-Host "  [CHAT] HTTP $statusCode : $errMsg" -ForegroundColor Red
                    Send-Json $res $statusCode "{`"error`": `"$errMsg`"}"
                }
            }

            # ── POST /api/exec → ejecutar comando
            elseif ($path -eq "/api/exec" -and $req.HttpMethod -eq "POST") {
                $body = Read-Body $req
                $obj  = $body | ConvertFrom-Json
                $cmd  = $obj.command
                if (-not $cmd) {
                    Send-Json $res 400 '{"success":false,"output":"No se especifico comando."}'
                } else {
                    Write-Host "  [EXEC] $cmd" -ForegroundColor Yellow
                    $r = Invoke-AnyCommand $cmd
                    $json = "{`"success`": $($r.success.ToString().ToLower()), `"output`": $(($r.output | ConvertTo-Json -Compress))}"
                    Send-Json $res 200 $json
                }
            }

            # ── POST /api/exec-script → crear y ejecutar script temporal
            elseif ($path -eq "/api/exec-script" -and $req.HttpMethod -eq "POST") {
                $body = Read-Body $req
                $obj  = $body | ConvertFrom-Json
                $name = $obj.name
                $content = $obj.content
                $ext  = if ($obj.extension) { $obj.extension } else { "ps1" }
                if (-not $name -or -not $content) {
                    Send-Json $res 400 '{"success":false,"output":"Faltan campos: name, content."}'
                } else {
                    Write-Host "  [SCRIPT] $name.$ext" -ForegroundColor Cyan
                    $r = Invoke-TempScript -FileName $name -Content $content -Extension $ext
                    $json = "{`"success`": $($r.success.ToString().ToLower()), `"output`": $(($r.output | ConvertTo-Json -Compress)), `"path`": $(($r.path | ConvertTo-Json -Compress))}"
                    Send-Json $res 200 $json
                }
            }

            # ── GET /api/whoami → nombre del usuario
            elseif ($path -eq "/api/whoami" -and $req.HttpMethod -eq "GET") {
                $safeWhoami = $GLOBAL:USERNAME -replace '"','\"' -replace '\\','\\'
                Send-Json $res 200 "{`"whoami`": `"$safeWhoami`"}"
            }

            # ── 404
            else {
                Send-Text $res 404 "Not Found"
            }

        } catch {
            Write-Host "  [ERR] $_" -ForegroundColor DarkRed
            try { if ($ctx) { $ctx.Response.Close() } } catch {}
        }
    }
} catch {
    Write-Host ""
    Write-Host "  Interrupcion recibida..." -ForegroundColor Yellow
} finally {
    try { $listener.Stop() } catch {}
    try { $listener.Close() } catch {}
    if (Test-Path $TEMP_SCRIPTS_DIR) {
        try { Remove-Item $TEMP_SCRIPTS_DIR -Recurse -Force -ErrorAction SilentlyContinue } catch {}
    }
    Write-Host ""
    Write-Host "  WINSHOOTER detenido." -ForegroundColor DarkGray
    Write-Host ""
}