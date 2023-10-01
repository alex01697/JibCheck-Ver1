function Menu {
    Write-Host "###### Select an option ######"
    Write-Host "1.Start TEST"
    Write-Host "2.Exit"
}

#Main Function 
function Option1 {

     #####IPv4########
     #Chenge the vrebale to corect (listening server) IP add!!!!!!!
     $IP= ""   

    #Get the pass criteria form pass_criteria.json
    function GetCriteria {
        # Read the JSON content from the file
        $jsonContent = Get-Content -Path ".\pass_criteria\pass_criteria.json" -Raw
        
        # Convert JSON data to a PowerShell object
        $jsonObject = $jsonContent | ConvertFrom-Json

        foreach ($interval in $jsonObject.MinCriteriaData) {
            $MinCriteriaData = $interval.value
        }
        return  $MinCriteriaData
    }

    $MinCriteriaData = GetCriteria
    Write-Host  "MIN PASS CRITERIA: $MinCriteriaData Gb"  
    $adapters = Get-NetAdapter
    if ($adapters) {
        foreach ($adapter in $adapters) {
            # Check if Adapter is UP and run the test
            if ($adapter.Status -eq "Up") {
                $adapterName = $adapter.Name
                $mac = $adapter.MacAddress
                $ipAddress = (Get-NetIPConfiguration | Where-Object { $_.InterfaceAlias -eq $adapterName } | Where-Object { $_.IPv4Address -ne $null }).IPv4Address
                Write-Host ("$($adapter.Name):$($adapter.Status)`n")
                write-host "MacAddresses $mac Is Up!!!`n" | Add-Content -Path .\$($serialNumber).txt
                Write-Host "IP: $ipAddress `n"
                $partNumber = Read-Host "Part Number "
                $serialNumber = Read-Host "Serial Number "
                $technicianNmae = Read-Host "Technician Name "
                $iperfPath = Join-Path -Path "ipref_test\iperf-3.1.3-win64" -ChildPath "iperf3.exe"
                $logFileName = "$serialNumber.txt"
                $Date = Get-Date
                Start-Process -FilePath $iperfPath -ArgumentList "-J -c $($IP)-p 6060 --logfile $($serialNumber).json"
                #waitig finish Test
                write-host "`n@###############*Test Running*###############@`n"
                Start-Sleep -s 15
                # Add logs to file $serialNumber.txt
                Add-Content -Path .\$logFileName "Part Number: $partNumber `nSerial Number: $serialNumber `nTechnician: $technicianNmae`nMACADDRSSES: $mac`nDate: $Date`n"    
                $x = Get-Content -Path .\"$serialNumber.json"
                # Convert JSON data to a PowerShell object
                $jsonObject = $x | ConvertFrom-Json
            
                # Extract and print the "bits_per_second" values from the "intervals" section
                foreach ($interval in $jsonObject.intervals) {
                    foreach ($stream in $interval.streams) {
                        $bitsPerSecond = ($stream.bits_per_second) / 1Gb
                        $bitsPerSecond = $bitsPerSecond -as [float]
                        Add-Content -Path .\$logFileName "Speed:  $bitsPerSecond GB `n############################################################"
                    }
                    $average += $bitsPerSecond / 10   
                }
            
                # Extract and print the "bits_per_second" value from the "end" section
                foreach ($stream in $jsonObject.end.streams) {
                    $bitsPerSecond = $stream.sender.bits_per_second
                }
                
                #Check $average 
                if ($average -gt $MinCriteriaData    ) { 
                    Add-Content -Path .\$logFileName  "Test Past `n $average `n $MinCriteriaData "
                }
                else {
                        
                    Add-Content -Path .\$logFileName  "Test failed, $average"
                }
            }
            else {
                Write-Host ("$($adapter.Name):$($adapter.Status)`n")
            }
        }
    }
    else {
        Write-Host "No adapters found."
    }
    Break
}

#Active menu function 
do {
    Menu
    $choice = Read-Host "Enter your choice (1-2)"

    switch ($choice) {
        "1" { Option1 }
        "2" { exit }
        default { Write-Host "Invalid choice. Please try again." }
    }
}
while ($choice -ne "2")
