while ($true) {
$counter_t=0
$counter_f=0
$triger=Get-Content "C:\Windows\SysWOW64\trigger.txt"
$hostname = Get-WMIObject Win32_ComputerSystem| Select-Object -ExpandProperty Name
$token="1019846742:AAE_I-M0B4tIGaZo2RhiZyZDbUZZhvCynAs"
$chat_id="-341602750"
$log = [System.Diagnostics.EventLog]::SourceExists("Sentinel-Checker")

function telega($token, $chat_id, $message, $hostname) {
  $payload = @{
      "chat_id" = $chat_id;
      "text" = $message, $hostname;
  }

  Invoke-WebRequest -Uri ("https://api.telegram.org/bot{0}/sendMessage" -f $token) -Method Post -ContentType "application/json;charset=utf-8" -Body (ConvertTo-Json -Compress -InputObject $payload)
}

#function log1($event_id) {

#}

if (!$log) {
  Write-Output "Source Sentinel-Checker isn't exists"
  New-EventLog -LogName Application -Source "Sentinel-Checker"
}
else{
  Write-Output "Source Sentinel-Checker is exists"
  Start-Sleep -Seconds 1
}


for ($i=1; $i -le 20; $i++){

$sentinel = Get-Process SentinelAgent   -ErrorAction SilentlyContinue

if (!$sentinel) {
  $counter_t++  
}
else {
   $counter_f++  
}
Start-Sleep -Seconds 1
}

Write-Output $counter_f $counter_t $triger
if (($counter_t -gt $counter_f) -and ($triger -eq "0")){


telega $token $chat_id "SentinelOne was corrupted on" $hostname
Write-EventLog -LogName "Application" -Source "Sentinel-Checker" -EventID 666 -EntryType Information -Message "SentinelOne was corrupted on $hostname." -Category 1 -RawData 10,20
'1' | Out-File -FilePath "C:\Windows\SysWOW64\trigger.txt"

}

elseif (($counter_t -gt $counter_f) -and ($triger -eq "1")) {
  Write-EventLog -LogName "Application" -Source "Sentinel-Checker" -EventID 666 -EntryType Information -Message "SentinelOne still down." -Category 1 -RawData 10,20

   
}
elseif (($counter_t -lt $counter_f) -and ($triger -eq "1")){

telega $token $chat_id "SentinelOne was recovered on" $hostname
Write-EventLog -LogName "Application" -Source "Sentinel-Checker" -EventID 666 -EntryType Information -Message "SentinelOne was recovered on $hostname." -Category 1 -RawData 10,20
'0' | Out-File -FilePath "C:\Windows\SysWOW64\trigger.txt"


}

elseif (($counter_t -lt $counter_f) -and ($triger -eq "0")){
  Write-Output "SentinelOne is running"
}


Start-Sleep -Seconds 600

}

