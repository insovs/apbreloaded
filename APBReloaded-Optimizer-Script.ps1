#
# .SYNOPSIS
# APB Reloaded Performance & Latency Optimization Toolkit (v1.4).
# Version : 1.4 / Last Update: Jan 21, 2026
#

# https://guns.lol/inso.vs
if (-not ((New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit}
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Add-Type -Name Win32 -Namespace "" -MemberDefinition @"
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]   public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
[Win32]::ShowWindow([Win32]::GetConsoleWindow(), 0) | Out-Null

$global:insoptiConsoleBox = $null
$global:insoptiConsolePending = [System.Collections.Generic.List[object]]::new()

function insoptiwh($txt,$type="info"){;switch($type){"success"{$s="+";$c1="white";$c2="Green";if($txt -match "(.*)(successfully)(.*)"){$part1=$matches[1];$part2=$matches[2];$part3=$matches[3]}else{$part1=$txt;$part2="";$part3=""}};"error"{$s="!";$c1="DarkRed";$c2="Red"};"warning"{$s="?";$c1="red";$c2="DarkYellow"};default{$s="+";$c1="DarkCyan";$c2="Cyan"}};insoptiwrth "[" -NoNewline -ForegroundColor $c1; insoptiwrth $s -NoNewline -ForegroundColor $c2; insoptiwrth "] " -NoNewline -ForegroundColor $c1
if($type -eq "success" -and $part2){insoptiwrth $part1 -NoNewline -ForegroundColor "white"; insoptiwrth $part2 -NoNewline -ForegroundColor "Green"; insoptiwrth $part3 -ForegroundColor "white"}else{insoptiwrth $txt -ForegroundColor $c2}}

function insoptiwrth {
    param([Parameter(ValueFromPipeline=$true)]$Object,[string]$ForegroundColor,[switch]$NoNewline,[string]$BackgroundColor)
    $params=@{}
    if($Object){$params['Object']=$Object}
    if($ForegroundColor){$params['ForegroundColor']=$ForegroundColor}
    if($BackgroundColor){$params['BackgroundColor']=$BackgroundColor}
    if($NoNewline){$params['NoNewline']=$true}
    Write-Host @params
    $colorMap=@{'Black'='000000';'DarkBlue'='00008B';'DarkGreen'='006400';'DarkCyan'='008B8B';'DarkRed'='8B0000';'DarkMagenta'='8B008B';'DarkYellow'='808000';'Gray'='808080';'DarkGray'='A9A9A9';'Blue'='4FC3F7';'Green'='66BB6A';'Cyan'='00BCD4';'Red'='EF5350';'Magenta'='CE93D8';'Yellow'='FFD54F';'White'='FFFFFF'}
    $hex=if($ForegroundColor -and $colorMap.ContainsKey($ForegroundColor)){$colorMap[$ForegroundColor]}else{'FFFFFF'}
    $entry=[PSCustomObject]@{Text=if($Object){"$Object"}else{''}; Color=$hex; NoNewline=$NoNewline.IsPresent}
    $global:insoptiConsolePending.Add($entry)
    if($global:insoptiConsoleBox -ne $null){insoptiFlushConsole}
}

function insoptiFlushConsole {
    if($global:insoptiConsoleBox -eq $null){return}
    foreach($e in $global:insoptiConsolePending){
        $box=$global:insoptiConsoleBox
        $box.SelectionStart=$box.TextLength
        $box.SelectionLength=0
        $r=[convert]::ToInt32($e.Color.Substring(0,2),16)
        $g=[convert]::ToInt32($e.Color.Substring(2,2),16)
        $b=[convert]::ToInt32($e.Color.Substring(4,2),16)
        $box.SelectionColor=[System.Drawing.Color]::FromArgb($r,$g,$b)
        $txt=if($e.NoNewline){$e.Text}else{$e.Text+"`n"}
        $box.AppendText($txt)
        $box.ScrollToCaret()
    }
    $global:insoptiConsolePending.Clear()
    [System.Windows.Forms.Application]::DoEvents()
}

function insoptiPrintConsoleHeader {
    insoptiwrth "(https://guns.lol/inso.vs)" -ForegroundColor Cyan; insoptiwrth ""
}

Get-Process|Where-Object{$_.ProcessName -like "GGG*"}|ForEach-Object{Stop-Process -Id $_.Id -Force}
$insoptiperf,$insoptiQoS,$insoptigpu='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\APB.exe\PerfOptions','HKLM:\SOFTWARE\Policies\Microsoft\Windows\QoS\APB.exe','HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences'

function insoptiGetAPBExe {$insoptiroots=Get-PSDrive -PSProvider FileSystem|Where-Object{$_.Root}|ForEach-Object{$_.Root};$insoptipaths=@();foreach($r in $insoptiroots){$insoptipaths+="${r}Program Files (x86)\GamersFirst\APB Reloaded\binaries\APB.exe";$insoptipaths+="${r}GamersFirst\APB Reloaded\binaries\APB.exe";$insoptipaths+="${r}APB Reloaded\binaries\APB.exe";$insoptipaths+="${r}Games\APB Reloaded\binaries\APB.exe"};$insoptipaths+="C:\Program Files (x86)\GamersFirst\APB Reloaded\binaries\APB.exe";$insoptipaths|Where-Object{Test-Path $_}|Select-Object -First 1}
function insoptiGetAPBDir {$insoptiexePath=insoptiGetAPBExe;if($insoptiexePath){Split-Path $insoptiexePath -Parent}else{$null}}
function insoptiApplyPerfOptions {;try {;New-Item -Path $insoptiperf -Force|Out-Null;@{'CpuPriorityClass'=3;'IoPriority'=3}.GetEnumerator()|ForEach-Object{New-ItemProperty -Path $insoptiperf -Name $_.Key -Value $_.Value -PropertyType DWord -Force|Out-Null};insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Green;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Green;insoptiwrth " set CPU `& I/O priority to " -NoNewline -ForegroundColor White;insoptiwrth "High" -NoNewline -ForegroundColor Green;insoptiwrth ", Allocates more resources to APB." -ForegroundColor White} catch {insoptiwh "Failed to configure performance options." "error"}}
function insoptiApplyQoS {;try {$insoptiAPBexe=insoptiGetAPBExe;if(-not $insoptiAPBexe){insoptiwh "APB executable not found." "error";return};if(-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){insoptiwh "ApplyQoS requires administrator rights." "error";return};New-Item -Path $insoptiQoS -Force -ErrorAction Stop|Out-Null;@{'Application Name'='APB.exe';'AppPathName'=$insoptiAPBexe;'DSCP Value'='46';'Local IP'='*';'Local IP Prefix Length'='*';'Local Port'='*';'Protocol'='*';'Remote IP'='*';'Remote IP Prefix Length'='*';'Remote Port'='*';'Throttle Rate'='-1';'Version'='1.0'}.GetEnumerator()|ForEach-Object{New-ItemProperty -Path $insoptiQoS -Name $_.Key -Value $_.Value -PropertyType String -Force -ErrorAction Stop|Out-Null};insoptiwh "Successfully created a QoS rules for prioritized network traffic." "success"}catch{insoptiwh "QoS creation error: $($_.Exception.Message)" "error"}}
function insoptiApplyGPU {;try {;if(-not(Test-Path $insoptigpu)){New-Item -Path $insoptigpu -ItemType Directory|Out-Null};$insoptiAPBexe=insoptiGetAPBExe;if(-not $insoptiAPBexe){insoptiwh "APB executable not found." "error";return};New-ItemProperty -Path $insoptigpu -Name $insoptiAPBexe -Value 'GpuPreference=2' -PropertyType String -Force|Out-Null;insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Green;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Green;insoptiwrth " set GPU preference to " -NoNewline -ForegroundColor White;insoptiwrth "High Performance" -NoNewline -ForegroundColor Green;insoptiwrth ", in Windows Settings." -ForegroundColor White}catch{insoptiwh "GPU configuration error." "error"}}
function insoptiApplyRunAsAdmin {;try {;$insoptiAPBexe=insoptiGetAPBExe;if(-not $insoptiAPBexe){insoptiwh "APB executable not found." "error";return};New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name $insoptiAPBexe -Value "~ RUNASADMIN" -PropertyType String -Force|Out-Null;$insoptiifeopath="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\APB.exe";if(-not(Test-Path $insoptiifeopath)){New-Item -Path $insoptiifeopath -Force|Out-Null};New-ItemProperty -Path $insoptiifeopath -Name "RunAsAdmin" -Value 1 -PropertyType DWord -Force|Out-Null;insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Green;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Green;insoptiwrth " configured APB Reloaded to run as " -NoNewline -ForegroundColor White;insoptiwrth "Administrator" -NoNewline -ForegroundColor Green;insoptiwrth "."}catch{insoptiwh "Error configuring administrator privileges." "error"}}
function insoptiApplyFirewall {;try {;$insoptiAPBexe=insoptiGetAPBExe;if(-not $insoptiAPBexe){return insoptiwh "APB executable not found." "error"};"In","Out"|ForEach-Object{New-NetFirewallRule -DisplayName "APBClient ($_)" -Direction "${_}bound" -Program $insoptiAPBexe -Action Allow -ErrorAction SilentlyContinue|Out-Null};insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Green;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Green;insoptiwrth " added firewall rules " -NoNewline -ForegroundColor White;insoptiwrth "Inbound `& Outbound" -NoNewline -ForegroundColor Green;insoptiwrth "."}catch{insoptiwh "Firewall configuration error: $($_.Exception.Message)" "error"}}
function insoptiApplyDefender {;try {;$insoptiAPBdir=insoptiGetAPBDir;if(-not(Test-Path $insoptiAPBdir)){return insoptiwh "APB directory not found." "error"};Add-MpPreference -ExclusionPath $insoptiAPBdir -ErrorAction SilentlyContinue;if($?){insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Green;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Green;insoptiwrth " added Windows Defender " -NoNewline -ForegroundColor White;insoptiwrth "Exclusion" -NoNewline -ForegroundColor Green;insoptiwrth ", Prevents background scans from impacting performance." -ForegroundColor White}else{insoptiwh "Windows Defender exclusion could not be applied." "warning"}}catch{insoptiwh "Error Defednder exclusion: Windows Defender is disabled or unavailable on this system. No changes have been made." "error"}}
function insoptiApplyDisableFullscreenOptim {
    try {
        $insoptiAPBexe=insoptiGetAPBExe
        if(-not $insoptiAPBexe){insoptiwh "APB executable not found." "error";return}
        $insoptilayersPath="HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
        if(-not(Test-Path $insoptilayersPath)){New-Item -Path $insoptilayersPath -Force|Out-Null}
        $insoptiexisting=(Get-ItemProperty -Path $insoptilayersPath -Name $insoptiAPBexe -ErrorAction SilentlyContinue)."$insoptiAPBexe"
        if($insoptiexisting){if($insoptiexisting -notmatch "DISABLEDXMAXIMIZEDWINDOWEDMODE"){New-ItemProperty -Path $insoptilayersPath -Name $insoptiAPBexe -Value ($insoptiexisting.TrimEnd()+" DISABLEDXMAXIMIZEDWINDOWEDMODE").Trim() -PropertyType String -Force|Out-Null}}
        else{New-ItemProperty -Path $insoptilayersPath -Name $insoptiAPBexe -Value "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" -PropertyType String -Force|Out-Null}
        insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Green;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Green;insoptiwrth " disabled Fullscreen Optimizations for " -NoNewline -ForegroundColor White;insoptiwrth "APB.exe" -NoNewline -ForegroundColor Green;insoptiwrth "." -ForegroundColor White
    } catch {insoptiwh "Error disabling fullscreen optimizations: $($_.Exception.Message)" "error"}
}
function insoptiRemoveAll {
    try{if(Test-Path $insoptiperf){Remove-Item $insoptiperf -Recurse -Force};insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Yellow;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Yellow;insoptiwrth " removed CPU `& I/O priority, Restored to " -NoNewline -ForegroundColor White;insoptiwrth "Normal" -NoNewline -ForegroundColor Cyan;insoptiwrth " default priority." -ForegroundColor White}catch{insoptiwh "Error removing performance options." "error"}
    try{if(Test-Path $insoptiQoS){Remove-Item $insoptiQoS -Recurse -Force};insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Yellow;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Yellow;insoptiwrth " removed Network Custom QoS rules traffic priority " -NoNewline -ForegroundColor White;insoptiwrth "Deleted" -NoNewline -ForegroundColor Cyan;insoptiwrth "." -ForegroundColor White}catch{insoptiwh "Error removing QoS." "error"}
    try{$insoptiAPBexe=insoptiGetAPBExe;if($insoptiAPBexe){Remove-ItemProperty -Path $insoptigpu -Name $insoptiAPBexe -ErrorAction SilentlyContinue};insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Yellow;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Yellow;insoptiwrth " removed GPU preference, Restored to " -NoNewline -ForegroundColor White;insoptiwrth "System Defaults" -NoNewline -ForegroundColor Cyan;insoptiwrth "." -ForegroundColor White}catch{insoptiwh "Error removing GPU settings." "error"}
    try{$insoptiAPBexe=insoptiGetAPBExe;$lp="HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers";if($insoptiAPBexe -and (Test-Path $lp)){$ex=(Get-ItemProperty -Path $lp -Name $insoptiAPBexe -ErrorAction SilentlyContinue)."$insoptiAPBexe";if($ex){$nv=$ex -replace "DISABLEDXMAXIMIZEDWINDOWEDMODE","" -replace "RUNASADMIN","" -replace "~\s*","" -replace "\s+"," ";$nv=$nv.Trim();if($nv -eq "" -or $nv -eq "~"){Remove-ItemProperty -Path $lp -Name $insoptiAPBexe -ErrorAction SilentlyContinue}else{New-ItemProperty -Path $lp -Name $insoptiAPBexe -Value $nv -PropertyType String -Force|Out-Null}}};$ip="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\APB.exe";if(Test-Path $ip){Remove-ItemProperty -Path $ip -Name "RunAsAdmin" -ErrorAction SilentlyContinue};insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Yellow;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Yellow;insoptiwrth " removed RunAsAdmin + Fullscreen flags, " -NoNewline -ForegroundColor White;insoptiwrth "Restored" -NoNewline -ForegroundColor Cyan;insoptiwrth "." -ForegroundColor White}catch{insoptiwh "Error removing RunAsAdmin / Fullscreen flags." "error"}
    try{Get-NetFirewallRule -DisplayName "APBClient*" -ErrorAction SilentlyContinue|Remove-NetFirewallRule -ErrorAction SilentlyContinue;insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Yellow;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Yellow;insoptiwrth " removed Firewall rules for APB Reloaded, Rules " -NoNewline -ForegroundColor White;insoptiwrth "Deleted" -NoNewline -ForegroundColor Cyan;insoptiwrth "." -ForegroundColor White}catch{insoptiwh "Error removing firewall rules." "error"}
    try{$insoptiAPBdir=insoptiGetAPBDir;if($insoptiAPBdir){Remove-MpPreference -ExclusionPath $insoptiAPBdir -ErrorAction SilentlyContinue};insoptiwrth "[" -NoNewline -ForegroundColor White;insoptiwrth "+" -NoNewline -ForegroundColor Yellow;insoptiwrth "] " -NoNewline -ForegroundColor White;insoptiwrth "Successfully" -NoNewline -ForegroundColor Yellow;insoptiwrth " removed Windows Defender exclusion, Scanning " -NoNewline -ForegroundColor White;insoptiwrth "Re-enabled" -NoNewline -ForegroundColor Cyan;insoptiwrth "." -ForegroundColor White}catch{insoptiwh "Error removing Windows Defender exclusion." "error"}
    insoptiwrth " ";insoptiwrth "================================================================================================================================" -ForegroundColor DarkGray;insoptiwrth " ";insoptiwrth "                                              All optimizations removed successfully." -ForegroundColor Yellow;insoptiwrth " ";insoptiwrth "================================================================================================================================" -ForegroundColor DarkGray;insoptiwrth " "
}

if(-not(Get-Command "Add-Type" -ErrorAction SilentlyContinue)){insoptiwh "GUI not available, PowerShell version too old." "error";return}
Add-Type -AssemblyName System.Windows.Forms,System.Drawing

$insoptif=New-Object Windows.Forms.Form
$insoptif.Text="APB Reloaded - Performance `& Latency Optimization Toolkit"
$insoptif.BackColor=[Drawing.Color]::FromArgb(18,18,18)
$insoptif.FormBorderStyle="FixedDialog"
$insoptif.MaximizeBox=$false
$insoptif.StartPosition="CenterScreen"
$insoptif.Opacity=0

# Title
$insoptiTitle=New-Object Windows.Forms.Label
$insoptiTitle.Text="APB Reloaded Optimizer"
$insoptiTitle.Font=New-Object Drawing.Font("Segoe UI",13,[Drawing.FontStyle]::Bold)
$insoptiTitle.ForeColor=[Drawing.Color]::White
$insoptiTitle.AutoSize=$true
$insoptiTitle.Location=New-Object Drawing.Point(20,14)
$insoptif.Controls.Add($insoptiTitle)

$insoptiSub1=New-Object Windows.Forms.Label
$insoptiSub1.Text="Click on the options below to configure OS-level performance tweaks and apply custom optimizations."
$insoptiSub1.Font=New-Object Drawing.Font("Segoe UI",8.5)
$insoptiSub1.ForeColor=[Drawing.Color]::FromArgb(170,170,170)
$insoptiSub1.AutoSize=$true
$insoptiSub1.Location=New-Object Drawing.Point(20,40)
$insoptif.Controls.Add($insoptiSub1)

$insoptiSub2=New-Object Windows.Forms.Label
$insoptiSub2.Text="These adjustments target CPU, GPU, network latency, and system responsiveness."
$insoptiSub2.Font=New-Object Drawing.Font("Segoe UI",8.5)
$insoptiSub2.ForeColor=[Drawing.Color]::FromArgb(170,170,170)
$insoptiSub2.AutoSize=$true
$insoptiSub2.Location=New-Object Drawing.Point(20,56)
$insoptif.Controls.Add($insoptiSub2)

$insoptisep=New-Object Windows.Forms.Label
$insoptisep.Size=New-Object Drawing.Size(572,1)
$insoptisep.Location=New-Object Drawing.Point(20,76)
$insoptisep.BackColor=[Drawing.Color]::FromArgb(55,55,55)
$insoptif.Controls.Add($insoptisep)

# Checkbox + description rows
$insopticbx=@{}

$insoptioRows=@(
    @{key="All-in-One (Apply everything at once)";    desc="Applies all optimizations in one click - CPU, Network, GPU, Firewall, Defender, RunAsAdmin, Fullscreen"; h=68},
    @{key="CPU Priority (CPU and I/O Priority set to High)"; desc="Increases CPU and I/O priority to allocate more resources to APB Reloaded"; h=54},
    @{key="Network Optimization (add optimized QoS rules)";  desc="Creates QoS rules with DSCP 46 and disables throttling to reduce latency and packet loss"; h=54},
    @{key="GPU (High Performance)";                          desc="Forces APB Reloaded to run on the high-performance GPU for maximum FPS"; h=54},
    @{key="RunAsAdmin (IFEO and Compatibility)";             desc="Configures APB Reloaded to always run as Administrator for better compatibility"; h=54},
    @{key="Firewall (Permissions)";                          desc="Adds Inbound and Outbound firewall rules to prevent connection blocking"; h=54},
    @{key="Defender (Exclusion)";                            desc="Excludes APB Reloaded directory from Windows Defender scans to reduce performance drops"; h=54},
    @{key="Disable Fullscreen Optimizations (APB.exe)";      desc="Disables Windows fullscreen optimizations for APB.exe, reduces DWM overhead and lowers frame latency"; h=68},
    @{key="Remove all optimizations (deletes all changes)";  desc="Reverts all applied tweaks and restores system defaults"; h=54}
)

$insoptiy=90
foreach($row in $insoptioRows){
    $cb=New-Object Windows.Forms.CheckBox
    $cb.Text=$row.key
    $cb.Location=New-Object Drawing.Point(28,$insoptiy)
    $cb.AutoSize=$true
    $cb.Font=New-Object Drawing.Font("Segoe UI Semibold",9.5)
    $cb.ForeColor=[Drawing.Color]::FromArgb(240,240,240)
    $cb.BackColor=[Drawing.Color]::Transparent
    $insoptif.Controls.Add($cb)
    $insopticbx[$row.key]=$cb

    $desc=New-Object Windows.Forms.Label
    $desc.Text=$row.desc
    $desc.Font=New-Object Drawing.Font("Segoe UI",8.5)
    $desc.ForeColor=[Drawing.Color]::FromArgb(155,155,155)
    $desc.Location=New-Object Drawing.Point(50,($insoptiy+24))
    $desc.Size=New-Object Drawing.Size(520,30)
    $insoptif.Controls.Add($desc)

    $insoptiy+=$row.h
}

# --- Separator before Console Output ---
$insoptiSep2=New-Object Windows.Forms.Label
$insoptiSep2.Size=New-Object Drawing.Size(572,1)
$insoptiSep2.Location=New-Object Drawing.Point(20,($insoptiy+8))
$insoptiSep2.BackColor=[Drawing.Color]::FromArgb(45,45,45)
$insoptif.Controls.Add($insoptiSep2)

# Console label
$insoptiConsoleLabelY=$insoptiy+18
$insoptiConsoleLabel=New-Object Windows.Forms.Label
$insoptiConsoleLabel.Text="Console Output"
$insoptiConsoleLabel.Font=New-Object Drawing.Font("Segoe UI Semibold",8)
$insoptiConsoleLabel.ForeColor=[Drawing.Color]::FromArgb(100,100,100)
$insoptiConsoleLabel.AutoSize=$true
$insoptiConsoleLabel.Location=New-Object Drawing.Point(20,$insoptiConsoleLabelY)
$insoptif.Controls.Add($insoptiConsoleLabel)

# RichTextBox console
$insoptiRTBY=$insoptiConsoleLabelY+18
$insoptiRTB=New-Object Windows.Forms.RichTextBox
$insoptiRTB.Location=New-Object Drawing.Point(21,$insoptiRTBY)
$insoptiRTB.Size=New-Object Drawing.Size(570,140)
$insoptiRTB.BackColor=[Drawing.Color]::FromArgb(12,12,12)
$insoptiRTB.ForeColor=[Drawing.Color]::FromArgb(210,210,210)
$insoptiRTB.Font=New-Object Drawing.Font("Consolas",8.5)
$insoptiRTB.ReadOnly=$true
$insoptiRTB.BorderStyle="None"
$insoptiRTB.ScrollBars="Vertical"
$insoptiRTB.WordWrap=$true
$insoptif.Controls.Add($insoptiRTB)

$insoptiConsoleBorder=New-Object Windows.Forms.Panel
$insoptiConsoleBorder.Location=New-Object Drawing.Point(20,($insoptiRTBY-1))
$insoptiConsoleBorder.Size=New-Object Drawing.Size(572,142)
$insoptiConsoleBorder.BackColor=[Drawing.Color]::FromArgb(40,40,40)
$insoptiConsoleBorder.SendToBack()
$insoptif.Controls.Add($insoptiConsoleBorder)

# Apply button - placed BELOW the console
$insoptiBtnY=$insoptiRTBY+148+14
$insoptib=New-Object Windows.Forms.Button
$insoptib.Text="Apply"
$insoptib.Size=New-Object Drawing.Size(200,42)
$insoptib.BackColor=[Drawing.Color]::FromArgb(0,120,255)
$insoptib.ForeColor=[Drawing.Color]::White
$insoptib.Font=New-Object Drawing.Font("Segoe UI Semibold",10,[Drawing.FontStyle]::Bold)
$insoptib.FlatStyle="Flat"
$insoptib.FlatAppearance.BorderSize=0
$insoptib.Location=New-Object Drawing.Point(196,$insoptiBtnY)
$insoptif.Controls.Add($insoptib)
$insoptib.Add_MouseEnter({$insoptib.BackColor=[Drawing.Color]::FromArgb(30,150,255)})
$insoptib.Add_MouseLeave({$insoptib.BackColor=[Drawing.Color]::FromArgb(0,120,255)})

# Footer
$insoptiFooterY=$insoptiBtnY+56
$insoptif.ClientSize=New-Object Drawing.Size(612,($insoptiFooterY+20))

$insoptilf=New-Object Windows.Forms.Label
$insoptilf.Text="(c)insopti (https://guns.lol/inso.vs)"
$insoptilf.Font=New-Object Drawing.Font("Segoe UI",8)
$insoptilf.ForeColor=[Drawing.Color]::FromArgb(110,110,110)
$insoptilf.AutoSize=$true
$insoptilf.Location=New-Object Drawing.Point(20,$insoptiFooterY)
$insoptif.Controls.Add($insoptilf)

$global:insoptiConsoleBox=$insoptiRTB

$insoptif.Add_Shown({
    $w=$insoptif.ClientSize.Width
    $insoptiTitle.Location=New-Object Drawing.Point((($w-$insoptiTitle.Width)/2),14)
    $insoptiSub1.Location=New-Object Drawing.Point((($w-$insoptiSub1.Width)/2),40)
    $insoptiSub2.Location=New-Object Drawing.Point((($w-$insoptiSub2.Width)/2),56)
    $insoptilf.Location=New-Object Drawing.Point((($w-$insoptilf.Width)/2),$insoptiFooterY)
    insoptiPrintConsoleHeader
    insoptiFlushConsole
})

$insoptib.Add_Click({
    $global:insoptiConsoleBox.Clear()
    insoptiPrintConsoleHeader
    if($insopticbx["Remove all optimizations (deletes all changes)"].Checked){insoptiRemoveAll;insoptiFlushConsole;[Windows.Forms.MessageBox]::Show("     All optimizations have been successfully removed.")|Out-Null;return}
    if($insopticbx["All-in-One (Apply everything at once)"].Checked){insoptiApplyPerfOptions;insoptiApplyQoS;insoptiApplyGPU;insoptiApplyRunAsAdmin;insoptiApplyFirewall;insoptiApplyDefender;insoptiApplyDisableFullscreenOptim;insoptiFlushConsole;[Windows.Forms.MessageBox]::Show("     All optimizations have been applied successfully !")|Out-Null;return}
    if($insopticbx["CPU Priority (CPU and I/O Priority set to High)"].Checked){insoptiApplyPerfOptions}
    if($insopticbx["Network Optimization (add optimized QoS rules)"].Checked){insoptiApplyQoS}
    if($insopticbx["GPU (High Performance)"].Checked){insoptiApplyGPU}
    if($insopticbx["RunAsAdmin (IFEO and Compatibility)"].Checked){insoptiApplyRunAsAdmin}
    if($insopticbx["Firewall (Permissions)"].Checked){insoptiApplyFirewall}
    if($insopticbx["Defender (Exclusion)"].Checked){insoptiApplyDefender}
    if($insopticbx["Disable Fullscreen Optimizations (APB.exe)"].Checked){insoptiApplyDisableFullscreenOptim}
    insoptiFlushConsole
    [Windows.Forms.MessageBox]::Show("       Operations completed.")|Out-Null
})

$insoptit=New-Object Windows.Forms.Timer;$insoptit.Interval=15
$insoptit.Add_Tick({if($insoptif.Opacity -lt 1){$insoptif.Opacity+=0.05}else{$insoptit.Stop()}});$insoptit.Start()
[void]$insoptif.ShowDialog()
# https://guns.lol/inso.vs
