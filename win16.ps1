function Show-Menu {      param (            [string]$Title = 'My Menu'      )      cls      Write-Host "================ $Title ================"           Write-Host "1: Press '1' For Configure Network."      Write-Host "2: Press '2' To Change RDP Port"      Write-Host "3: Press '3' Create winadmin User"      Write-Host "4: Press '4' Windows Activate"      Write-Host "5: Press '5' Install .NET Framework"      Write-Host "6: Press '6' Remove SMB Role"      Write-Host "7: Press '7' Extend Partition ( For VPS Setup )"      Write-Host "8: Press '8' Changing Administrator Password"     Write-Host "Q: Press 'Q' to quit."      Write-Host "======================================" } do {      Show-Menu      $input = Read-Host "Please Enter Your Choice"      switch ($input)      {            '1' {                 cls                 'You chose option #1' 
                                
                    $ip= Read-Host -Prompt "`n`nEnter The IP "
                    $gw= Read-Host -Prompt "`nEnter the Gateway "
                    $dns1= Read-Host -Prompt "`nEnter the First DNS Record "
                    $dns2= Read-Host -Prompt "`nEnter the Second DNS Record "


                    Write-Host " `n`nYour Provided Following Information"

                    Start-Sleep -s 3

                    Write-Host "IP Address : $ip"
                    Write-Host "Gateway    : $gw"
                    Write-Host "DNS1       : $dns1"
                    Write-Host "DNS2       : $dns2"

                    Start-Sleep -s 3
                    &{$adapter = Get-NetAdapter -Name Ethernet;New-NetIPAddress -InterfaceAlias $adapter.Name -AddressFamily IPv4 -IPAddress $ip -PrefixLength 24 -DefaultGateway $gw; Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses ("$($dns1)","$($dns2)")}
                    #&{$adapter = Get-NetAdapter -Name Ethernet;New-NetIPAddress -InterfaceAlias $adapter.Name -AddressFamily IPv4 -IPAddress $ip -PrefixLength 24; Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses ("$($dns1)","$($dns2)")}

                    #Remove-NetIPAddress -IPAddress 109.203.117.241

                    Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Ethernet'
                    Get-DnsClientServerAddress | Select-Object -ExpandProperty ServerAddresses
           } '2' {                 cls                 'You chose option #2'                                 Write-Host "`n`n`n Current RDP Port Number is "
                        REG QUERY "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber


                        $newport= Read-Host "`n`n`n Enter The Port Number Which You Want To Set "
                        $rnm = Read-Host "`n Enter The Rule Name "

                        New-NetFirewallRule -DisplayName "$($rnm)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $newport

                        #Write-Host "`n`n`n New Firewall Rule Successfully added...!"

                        Start-Sleep -s 5

                        $hexval= "{0:x}" -f $($newport)


                        REG ADD "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d $hexval /f

                        Write-Host "`n`n`n Your Provided Port Number is : $hexval"

                        Start-Sleep -s 5

                        Write-Host "`n`n`n New RDP Port Information and its Status As Below  "

                        REG QUERY "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber

                        Start-Sleep -s 3


                        netstat -ano|findstr /i "$hexval"

                        Start-Sleep -s 3

                        Write-Host "`n`n`n`n`n`n Services Will Now Restart ....!"
                        net stop TermService /y
                        net start TermService /y


                                            } '3' {                 cls                 'You chose option #3'                         #New-LocalUser -Name "user2" -Description "Test User2" -NoPassword
                        $Password = Read-Host -AsSecureString
                        New-LocalUser -Name winadmin -Password $Password -AccountNeverExpires -FullName winadmin -PasswordNeverExpires -UserMayNotChangePassword
                        Add-LocalGroupMember -Group "Administrators" -Member "winadmin"

                        Start-Sleep -s 2
                        Write-Host "Successfully created winadmin user...!`n`n"

                        #Remove-LocalUser -Name "AdminContoso02"
           }                       '4' {                                       $service= get-wmiObject -query "select * from SoftwareLicensingService" -computername $env:computername

                        #To Get Computer Name
                        #$env:computername

                        #TO get OS Information
                        #(Get-WMIObject win32_operatingsystem).name
                        $key = "K9Y9T-N8P68-CVXQT-PWDMF-BY632"
                        $service.InstallProductKey($($key))
                        

                        Start-Sleep -s 3

                        Write-Host "Winows Successfully activated ...!"

                        Start-Sleep -s 3

                        $service.RefreshLicenseStatus()
                        #$a= "KBN-KNM1"
                        #Write-Host "$a"               } '5' {                     cls                     'You chose option #1' 
                                
                    Install-WindowsFeature -Name NET-Framework-Features -computerName $env:computername                      Write-Host "`n`n`n Successfully Added .NET Framework Role"               } '6' {                     cls                     'You chose option #2'                        Uninstall-WindowsFeature -Name FS-SMB1 -computerName $env:computername                        Write-Host "`n`n`n Successfully Removed SMB Role`n`n`n"                                                                   } '7' {                      cls                     'You chose option #7'                        $MaxSize = (Get-PartitionSupportedSize -DriveLetter C).sizeMax
                        $Size_GB = [math]::Round($MaxSize / 1GB)

                        Resize-Partition -DriveLetter c -Size $MaxSize

                        Write-Host "Partion Extended Successfully...!"
                        Write-Host "Partiton Size is : $Size_GB" 
                                                                   }'8' {                      cls                     'You chose option #8'                        $Password = Read-Host -AsSecureString
                        Get-LocalUser -Name "Administrator" | Set-LocalUser -Password $Password                                                                  }'q' {                 return            }      }      pause } until ($input -eq 'q') 