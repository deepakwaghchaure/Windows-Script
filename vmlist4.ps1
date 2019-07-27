#$vmhost=Get-Content C:\Users\Administrator\Desktop\Scripts\VMHosts.txt
#$file = "C:\Users\Administrator\Desktop\Scripts\output.htm"


$vmhost=Get-Content C:\Users\Share1\Desktop\Scripts\VMHosts.txt
$file = "C:\Users\Share1\Desktop\Scripts\output.htm"


$report = "<html> <body>"
$a = "<style>"
$a = $a + "body {font-family: Tahoma; background-color:#fff;}"
$a = $a + "table {font-family: Tahoma;width: $($rptWidth)px;font-size: 12px;border-collapse:collapse;}"
$a = $a + "th {background-color: #cccc99;border: 1px solid #a7a9ac;border-bottom: none;}"
$a = $a + "td {background-color: #ffffff;border: 1px solid #a7a9ac;padding: 2px 3px 2px 3px;vertical-align: middle;text-align:center;}"
$a = $a + "</style>"


$d1=foreach ($hostnm in $vmhost){
echo "--------------------</br>"
 echo "<b>" $hostnm  "</b></br>"
 echo "--------------------</br>" 
 }


$output = foreach ($hostnm in $vmhost)
{
 Enable-VMResourceMetering -Name $hostnm -ResourcePoolType @("Processor","VHD","Ethernet","Memory")
  
$resources = @{}
    Measure-VM –Name * -ComputerName $hostnm | ForEach-Object {
        $resources[$_.VMName] = $_ | Select-Object MaxRAM, TotalDisk
    }


    $processor = @{}
    Get-VMProcessor -VMName * -ComputerName $hostnm | ForEach-Object {
        $processor[$_.VMName] = $_ | Select-Object Count
    }

    #Get-VM
   # Get-VM –ComputerName $hostnm | ?{$_.ReplicationMode -ne “Replica”} | Select -ExpandProperty NetworkAdapters | Select VMName, IPAddresses, Status
   # Get-VM | Select -ExpandProperty NetworkAdapters | Select VMName, IPAddresses, Status


   $ip1=@{}
    Get-VM | ?{$_.ReplicationMode -ne “Replica”} |Select -ExpandProperty NetworkAdapters |  ForEach-Object {
        $ip1[$_.VMName] = $_ | Select-Object IPAddresses
        }

    Get-VM |  Select-Object VMName,State,Uptime, 
            @{n='RAM in GB';e={[Math]::Round($resources[$_.Name].MaxRAM/1024, 2)}},
            @{n='Disk in GB';e={[Math]::Round($resources[$_.Name].TotalDisk/1024, 2)}},
            @{n="Number Of Processor";e={$processor[$_.Name].count}},
            @{n="IP";e={$ip1[$_.Name].IPAddresses}}
            
            


  #  Get-VM –ComputerName $hostnm |
   ##     Select-Object Name, State,Uptime,
     #       @{n='RAM in GB';e={[Math]::Round($resources[$_.Name].MaxRAM/1024, 2)}},
      #      @{n='Disk in GB';e={[Math]::Round($resources[$_.Name].TotalDisk/1024, 2)}}   


 }
  
  #$op1=Get-VM | Select -ExpandProperty NetworkAdapters | Select IPAddresses, Status

  $table = $output  | ConvertTo-Html -Head $a 

$report = $report + $d1 + $table  + "</body></html>"
$report | Out-File $file