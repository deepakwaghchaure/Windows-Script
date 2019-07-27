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

$op1=@()
$op2=@()
$myresult=@()

$output = foreach ($hostnm in $vmhost)
{
 Enable-VMResourceMetering -Name $hostnm -ResourcePoolType @("Processor","VHD","Ethernet","Memory")
 
 echo "--------------------</br>"
 echo "<b>" $hostnm  "</b></br>"
 echo "--------------------</br>" 
   
 $op1=Get-VM –ComputerName $hostnm | Select-Object Name,State,@{Name="RAM In GB"; Expression={[math]::round($_.MemoryAssigned/1GB, 2)}},@{Name="Uptime in Hours"; Expression={[math]::round($_.Uptime, 2)}} | ConvertTo-Html -head $a 
 #(Get-VM –ComputerName $hostnm).HardDrives |get-vhd | Select-Object Path, @{Name="Size In GB";Expression={[math]::round($_.Size/1GB, 2)}}| ConvertTo-Html -head $a 
 
 #Measure-VMResourcePool -Name $hostnm -ResourcePoolType Memory| ConvertTo-Html -head $a

 $op3 = Get-VM  –ComputerName $hostnm| Select -ExpandProperty NetworkAdapters | Select VMName, IPAddresses, Status
 Get-VM –Name * -Computername $hostnm | enable-vmresourcemetering
 $op2=Measure-VM –Name * -Computername $hostnm |Sort-Object VMName | Select-Object VMName, @{Name="RAM In GB"; Expression={[math]::round($_.MaxRAM/1024, 2)}} ,@{Name="Disk Size in GB"; Expression={[math]::round($_.TotalDisk/1024, 2)}} | ConvertTo-Html -head $a

 $myresult =$op1+$op2

 }
  
$report = $report + $output + $myresult + "</body></html>"
$report | Out-File $file