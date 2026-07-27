param([string]$Pat = "")

$E = [char]0x1b
$PURPLE = $E + "[38;2;199;125;255m"
$GREEN  = $E + "[38;2;107;231;131m"
$PINK   = $E + "[38;2;255;122;192m"
$RESET  = $E + "[0m"

$GIT_USER = "23JoelElph"
$UP = $env:USERPROFILE
$OCD = $UP + "\.config\opencode"
$SKD = $OCD + "\skills"
$AD  = $OCD + "\agents"
$CMD = $OCD + "\commands"
$INS = $OCD + "\instructions"
$INST = $UP + "\pepe-install"
$VAULT = $UP + "\pepe-vault"
$ARS = $UP + "\pepe-arsenal"
$FriendName = $env:USERNAME
if ([string]::IsNullOrEmpty($FriendName)) { $FriendName = "pepe-user" }

Write-Host $PURPLE
Write-Host "    ____  _____ ____  _____    ____ ___  ____  _____"
Write-Host "   |  _ \| ____|  _ \| ____|  / ___/ _ \|  _ \| ____|"
Write-Host "   | |_) |  _| | |_) |  _|   | |  | | | | | | |  _|"
Write-Host "   |  __/| |___|  __/| |___  | |__| |_| | |_| | |___"
Write-Host "   |_|   |_____|_|   |_____|  \____\___/|____/|_____|"
Write-Host $RESET
Write-Host $PURPLE"═══════════════════════════════════════════"$RESET
Write-Host "  PEPE CODE · Windows + OpenCode · " $FriendName
Write-Host $PURPLE"═══════════════════════════════════════════"$RESET

# ═══ 0: ЗАВИСИМОСТИ ═══
Write-Host "`n"$PURPLE"═══"$RESET " [0/8] Зависимости"
if (-not (Get-Command "winget" -ErrorAction SilentlyContinue)) {
    Write-Host "  " $PINK"!"$RESET "winget не найден"
}
if (-not (Get-Command "node.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "  " $PINK"!"$RESET "ставлю node..."
    winget install --id OpenJS.NodeJS.LTS -e --silent --accept-package-agreements 2>&1 | Out-Null
}
if (-not (Get-Command "git.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "  " $PINK"!"$RESET "ставлю git..."
    winget install --id Git.Git -e --silent --accept-package-agreements 2>&1 | Out-Null
}
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
Write-Host "  " $GREEN"✓"$RESET " node:" (node --version) " git:" (git --version).Split(' ')[2]

# ═══ 1: OPENCODE ═══
Write-Host "`n"$PURPLE"═══"$RESET " [1/8] OpenCode"
$ocRoot = npm root -g 2>$null
$ocCmd = $ocRoot + "\..\opencode.cmd"
if (Test-Path $ocCmd) {
    Write-Host "  · уже:" (& $ocCmd --version 2>$null)
} else {
    Write-Host "  " $PINK"!"$RESET "ставлю opencode-ai..."
    npm install -g opencode-ai --force 2>&1 | Out-Null
    $ocRoot = npm root -g 2>$null
    $ocCmd = $ocRoot + "\..\opencode.cmd"
    if (Test-Path $ocCmd) {
        $npmDir = $ocCmd.Substring(0, $ocCmd.LastIndexOf("\"))
        $oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($oldPath -notlike "*" + $npmDir + "*") {
            [Environment]::SetEnvironmentVariable("Path", $oldPath + ";" + $npmDir, "User")
        }
        $ver = & $ocCmd --version 2>$null
        Write-Host "  " $GREEN"✓"$RESET " opencode:" $ver
    } else {
        Write-Host "  " $PINK"!"$RESET "opencode установлен, нужен новый PowerShell"
    }
}

# ═══ 2: SKILLS ═══
Write-Host "`n"$PURPLE"═══"$RESET " [2/8] Skills"
if (-not (Test-Path $SKD)) { New-Item -ItemType Directory -Force -Path $SKD | Out-Null }
if (-not (Test-Path $INST)) { git clone "https://github.com/" + $GIT_USER + "/pepe-install.git" $INST 2>&1 | Out-Null }

$src = $INST + "\skills"
$total = 0
if (Test-Path $src) {
    foreach ($d in (Get-ChildItem $src -Directory)) {
        $dst = $SKD + "\" + $d.Name
        if (-not (Test-Path $dst)) { Copy-Item -Recurse $d.FullName $dst; $total++ }
    }
}
# ECC
$eccDir = $env:TEMP + "\ecc-repos"
if (-not (Test-Path $eccDir)) { New-Item -ItemType Directory -Force -Path $eccDir | Out-Null }
$ecc = $eccDir + "\ecc"
if (-not (Test-Path $ecc)) { git clone --depth 1 "https://github.com/affaan-m/ECC.git" $ecc 2>&1 | Out-Null }
$src = $ecc + "\skills"
if (Test-Path $src) {
    foreach ($d in (Get-ChildItem $src -Directory)) {
        $dst = $SKD + "\" + $d.Name
        if (-not (Test-Path $dst)) { Copy-Item -Recurse $d.FullName $dst; $total++ }
    }
}
# Cybersec
$cyb = $eccDir + "\cyber"
if (-not (Test-Path $cyb)) { git clone --depth 1 "https://github.com/mukul975/Anthropic-Cybersecurity-Skills.git" $cyb 2>&1 | Out-Null }
$src = $cyb + "\skills"
if (Test-Path $src) {
    foreach ($d in (Get-ChildItem $src -Directory)) {
        $dst = $SKD + "\" + $d.Name
        if (-not (Test-Path $dst)) { Copy-Item -Recurse $d.FullName $dst; $total++ }
    }
}
$cnt = (Get-ChildItem $SKD -Directory).Count
Write-Host "  " $GREEN"✓"$RESET " skills:" $cnt "(" $total "новых)"

# ═══ 3: OSINT + SCOOP ═══
Write-Host "`n"$PURPLE"═══"$RESET " [3/8] OSINT + Scoop"
# pip
foreach ($t in @("trufflehog","manuf","shodan")) {
    if (Get-Command $t -ErrorAction SilentlyContinue) { Write-Host "  ·" $t }
    else { pip install $t -q 2>&1 | Out-Null; pip install $t -q 2>&1 | Out-Null; if (Get-Command $t -ErrorAction SilentlyContinue) { Write-Host "  " $GREEN"✓"$RESET $t } }
}
# git osint
foreach ($t in @(@{u="https://github.com/bkerler/DroneID"; n="DroneID"},@{u="https://github.com/o-gs/dji-firmware-tools"; n="dji-firmware-tools"},@{u="https://github.com/mihneamanolache/cert-cli"; n="cert-cli"})) {
    $d = $ARS + "\" + $t.n
    if (Test-Path $d) { Write-Host "  ·" $t.n }
    else { git clone --depth 1 $t.u $d 2>&1 | Out-Null; Write-Host "  " $GREEN"✓"$RESET $t.n }
}
# Scoop + CLI
if (-not (Get-Command "scoop.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "  " $PINK"!"$RESET "ставлю Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force 2>&1 | Out-Null
    [System.Net.ServicePointManager]::SecurityProtocol = 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')) 2>&1 | Out-Null
}
if (Get-Command "scoop.exe" -ErrorAction SilentlyContinue) {
    Write-Host "  " $GREEN"✓"$RESET "Scoop"
    foreach ($s in @("amass","subfinder","httpx","nuclei","uncover","trufflehog","gitleaks","hashcat","radare2","die")) {
        if (Get-Command ($s + ".exe") -ErrorAction SilentlyContinue) { Write-Host "  ·" $s }
        else { Write-Host "  " $PINK"!"$RESET "ставлю" $s "..."; scoop install $s 2>&1 | Out-Null }
    }
    # Ghidra
    if (-not (Test-Path ($ARS + "\ghidra"))) {
        Write-Host "  " $PINK"!"$RESET "ставлю Ghidra..."
        scoop bucket add extras 2>&1 | Out-Null
        scoop install ghidra 2>&1 | Out-Null
    }
}

# ═══ 4: REVERSE ═══
Write-Host "`n"$PURPLE"═══"$RESET " [4/8] Reverse"
if (-not (Get-Command "java.exe" -ErrorAction SilentlyContinue)) {
    winget install "EclipseAdoptium.Temurin.21.JDK" -e --silent 2>&1 | Out-Null
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
}
if (-not (Get-Command "frida.exe" -ErrorAction SilentlyContinue)) { pip install frida-tools -q 2>&1 | Out-Null }
if (-not (Get-Command "jadx.exe" -ErrorAction SilentlyContinue)) { scoop install jadx 2>&1 | Out-Null }
scoop install ilspy 2>&1 | Out-Null
foreach ($l in @("binwalk","capstone","unicorn")) { python -c "import $l" 2>$null; if ($LASTEXITCODE -ne 0) { pip install $l -q 2>&1 | Out-Null } }
# git re
foreach ($t in @(@{u="https://github.com/pyinstxtractor/pyinstxtractor-ng"; n="pyinstxtractor-ng"},@{u="https://github.com/Lil-House/Pyarmor-Static-Unpack-1shot"; n="pyarmor-1shot"},@{u="https://github.com/extremecoders-re/nuitka-extractor"; n="nuitka-extractor"})) {
    $d = $ARS + "\" + $t.n
    if (-not (Test-Path $d)) { git clone --depth 1 $t.u $d 2>&1 | Out-Null }
}

# ═══ 5: АГЕНТЫ + КОМАНДЫ ═══
Write-Host "`n"$PURPLE"═══"$RESET " [5/8] Агенты + команды"
foreach ($d in @($AD, $CMD, $INS)) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null } }
$s = $INST + "\commands"
if (Test-Path $s) { foreach ($f in (Get-ChildItem $s -Filter "*.md")) { $d = $CMD + "\" + $f.Name; if(-not(Test-Path $d)){Copy-Item $f.FullName $d} } }
$s = $INST + "\agents"
if (Test-Path $s) { foreach ($f in (Get-ChildItem $s -Filter "*.md")) { $d = $AD + "\" + $f.Name; $dt = $d -replace '\.md$','.txt'; if(-not(Test-Path $d)-and-not(Test-Path $dt)){Copy-Item $f.FullName $d} } }
Write-Host "  " $GREEN"✓"$RESET " commands:" (Get-ChildItem $CMD -Filter "*.md").Count " agents:" (Get-ChildItem $AD -Include "*.md","*.txt").Count

# ═══ 6: MCP ═══
Write-Host "`n"$PURPLE"═══"$RESET " [6/8] MCP"
foreach ($m in @("sequential-thinking","memory","filesystem","playwright","mcp-shodan")) {
    $chk = npm list -g --depth=0 2>$null | Select-String $m
    if ($chk) { Write-Host "  ·" $m }
    else { npm install -g "@modelcontextprotocol/server-"$m --force 2>&1 | Out-Null }
}
npm install -g @playwright/mcp@latest --force 2>&1 | Out-Null
npx playwright install chromium 2>&1 | Out-Null

# ═══ 7: VAULT + КОНФИГ ═══
Write-Host "`n"$PURPLE"═══"$RESET " [7/8] Vault + конфиг"
if ($Pat) {
    git clone ("https://" + $Pat + "@github.com/" + $GIT_USER + "/pepe-vault.git") $VAULT 2>&1 | Out-Null
    if (Test-Path ($VAULT + "\.git")) { Write-Host "  " $GREEN"✓"$RESET "vault склонирован" }
    else { Write-Host "  " $PINK"!"$RESET "vault: fail" }
}
# opencode.jsonc
$cfgFile = $OCD + "\opencode.jsonc"
$vp = $VAULT -replace '\\','/'
$ap = $ARS -replace '\\','/'
$json = '{"$schema":"https://opencode.ai/config.json","username":"' + $FriendName + '","model":"openrouter/deepseek/deepseek-v4-flash","default_agent":"general","instructions":["CLAUDE.md"],"references":{"pepe-vault":{"path":"' + $vp + '"},"pepe-arsenal":{"path":"' + $ap + '"}},"permission":{"edit":"allow","bash":"allow","external_directory":{"' + $vp + '/**":"allow","*":"ask"}},"formatter":false,"lsp":false}'
$json | Out-File $cfgFile -Encoding utf8

# CLAUDE.md
$cm = "# PEPE ($FriendName)`n`nЯ PEPE - помощник. Создан Molodoy и Formica.`n`n## Vault`n" + $vp + "`n`n## Arsenal`n" + $ap + "`n`n## Skills`n847+ (ECC + Cybersec)"
$cm | Out-File ($OCD + "\CLAUDE.md") -Encoding utf8
"# Runtime Budget`n- For simple questions answer in 1-3 sentences without tools." | Out-File ($INS + "\runtime.md") -Encoding utf8

# ═══ 8: БАННЕР ═══
$pd = Split-Path $PROFILE -Parent
if (-not (Test-Path $pd)) { New-Item -ItemType Directory -Force -Path $pd | Out-Null }
$b = '`n$phrases=@("Дизассемблируй или умри","За каждым XORом - истина","Брат, давай реверсить","Ghidra зовет")`n$p=$phrases[(Get-Random -Maximum $phrases.Length)]`n$e=[char]0x1b`nWrite-Host "$e[38;2;199;125;255m"`nWrite-Host "PEPE CODE 🐸"`nWrite-Host "$e[0m"`nWrite-Host "$e[2;3m» $p$e[0m"`n'
$pc = Get-Content $PROFILE -ErrorAction SilentlyContinue
if ($pc -notmatch "PEPE") { Add-Content $PROFILE $b }

# ═══ ИТОГ ═══
Write-Host "`n"$PURPLE"═══════════════════════════════════════════"$RESET
Write-Host "  PEPE CODE УСТАНОВЛЕН · " $FriendName
Write-Host $PURPLE"═══════════════════════════════════════════"$RESET
Write-Host "  Skills:" (Get-ChildItem $SKD -Directory).Count
Write-Host "`n1. setx OPENROUTER_API_KEY ""sk-or-v1-..."""
Write-Host "2. Открой НОВЫЙ PowerShell"
Write-Host "3. opencode"
Write-Host "`n"$PURPLE"welcome to PEPE CODE, "$FriendName" 🐸"$RESET
