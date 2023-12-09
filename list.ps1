Set-Location .\MicrosoftProgram_Install_and_Uninstall.meta
. .\MSIMATSFN.ps1
$result = [MakeStringTest]::loop()
Set-Location ..

if ($args[0] -eq '-a') {} else { $result = $result | Where-Object { $_.Name -notmatch '^(vs[_ ]|vcpp_|WinRT|Windows ((\w+ Extension )?SDK|Team)|Microsoft Visual C\+\+)' } }
$resultReform = @{}
foreach ($entry in $result) { $resultReform[$entry.Value] = $entry.Name }
$jsonOutput = "{"
foreach ($entry in ($resultReform.GetEnumerator() | Sort-Object Value)) { $jsonOutput += "`"" + $entry.Name + "`":`"" + $entry.Value + "`"," }
$jsonOutput = ($jsonOutput.TrimEnd(',') + "}" | ConvertFrom-Json | ConvertTo-Json -Depth 4)
Set-Content -Path '.\msiprogs.json' -Value ($jsonOutput)
