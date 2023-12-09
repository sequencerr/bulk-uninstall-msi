param (
  [Parameter(Mandatory, ValueFromPipeline, HelpMessage="MSI Programs JSON list must be provided to script cli.")]
  [string]$inputJson
)
$msiprogs = ($inputJson | ConvertFrom-Json).PSObject.Properties | ForEach-Object { [pscustomobject]@{ Value = $_.Name; Name = $_.Value } }

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) { throw "Error: PowerShell requires administrator privileges to modify registry. Run the script as an administrator." }
Write-Host "PowerShell is running with administrator privileges."

$jobs = @()
foreach ($entry in $msiprogs) {
    $job = Start-Job -ArgumentList $(pwd), $entry.Value, $entry.Name -ScriptBlock {
        PARAM ($cwd, $ProductCode, $ProductName)
        Set-Location "$cwd\MicrosoftProgram_Install_and_Uninstall.meta";
        . .\MSIMATSFN.ps1

        if (!$ProductCode) { throw "FAILED (no code specified): Processing entry: $($ProductCode) $($ProductName)" }

        $value=[UninstallProduct2]::LogandUninstallProduct($ProductCode) #Uninstall with the Windows Installer -x switch first
        if ($value -ne "0") { RapidProductRegistryRemove $ProductCode }
    }
    Write-Host "$($job.Name) Started for: $($entry.Value) $($entry.Name)"
    $jobs += $job
}

if ($jobs.Count -gt 0) {
    Write-Host "Waiting $($jobs.Count) jobs..."
    Wait-Job -Job $jobs | Out-Null
    Write-Host (Receive-Job -Job $jobs)
    Write-Host "Stopping $($jobs.Count) jobs..."
    Remove-Job -Job $jobs
} else {
    Write-Host "No jobs were started."
}
