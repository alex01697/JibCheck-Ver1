
function Option1 {
    $ipV4 = Test-Connection -ComputerName $env:COMPUTERNAME -Count 1 | Select -ExpandProperty IPV4Address
    $Server_Ipv4 = $ipV4.IPAddressToString 
    $iperfPath = Join-Path -Path "ipref_test\iperf-3.1.3-win64" -ChildPath "iperf3.exe"
    Start-Process -FilePath $iperfPath -ArgumentList "-B $Server_Ipv4  -s -p 6060"
    exit 
}

Option1 
