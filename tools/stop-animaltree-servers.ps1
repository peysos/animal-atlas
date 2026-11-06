$self = $PID
$procs = Get-CimInstance Win32_Process | Where-Object {
  $_.ProcessId -ne $self -and $_.CommandLine -and (
    $_.CommandLine -like '*serve-animaltree.ps1*' -or $_.CommandLine -like '*serve-positions.ps1*'
  )
}
$count = 0
foreach ($p in $procs) {
  try { Stop-Process -Id $p.ProcessId -Force; $count++ } catch {}
}
$positions = 'C:\Users\pkepe\OneDrive\Desktop\My computer\vibecode\Animaltree\positions.json'
if (Test-Path $positions) { Remove-Item $positions -Force }
"Stopped $count preview server process(es)."
"positions.json removed: $(-not (Test-Path $positions))"
