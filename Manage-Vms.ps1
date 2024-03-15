# Path where virtual machines are stored, change as needed
$VmsPath = ""

# Set location to vmware player folder
Set-Location 'C:\Program Files (x86)\VMware\VMware Player\'


function Get-VmStatus {
    $VmNames = Get-ChildItem -Path $VmsPath | Select-Object Name, FullName

    # Get currently running VMs
    $RunningVms = .\vmrun.exe list
    $RunningVms = $RunningVms | Where-Object { $_ -ne $RunningVms[0] } # Drop first element of array and join to long string
    $RunningVms = $RunningVms -join " "

    # Initialize VmObjects
    $VmObjects = @()
    foreach ($VmName in $VmNames) {
        $VmObject = @{
            FullName = "$($VmName.FullName)\$($VmName.Name).vmx"
            Name = $VmName.Name
            Running = $false
        }

        if ($RunningVms -like "*$($VmName.Name)*") {
            $VmObject.Running = $true
        }

        $VmObjects += $VmObject
    }

    return $VmObjects
}


while ($true) {
    $Vms = Get-VmStatus

    Write-Host "The following VMs are currntly running"
    Write-Host "------------------------------------------"
    $RunningVms = @()
    foreach ($Vm in $Vms) {
        if ($Vm.Running -eq $true) {
            Write-Host "$($Vm.Name)"
            $RunningVms += $Vm.Name
        }
    }
    Write-Host "`n"
    Write-Host "What would you like to do?"
    Write-Host "------------------------------------------"
    Write-Host "1, Start a VM"
    Write-Host "2, Stop a VM"
    Write-Host "9, Exit"

    $HostResp = Read-Host "Enter a choice: "

    if ($HostResp -eq "1") {
        if ($RunningVms.Count -eq $Vms.Count) {
            Write-Host "All VMs are currently running!"
            Write-Host "`n"
            continue
        }

        Write-Host "Which host would you like to start?"
        Write-Host "------------------------------------------"
        $i = 1
        $Choices = @()
        foreach ($Vm in $Vms) {
            if ($Vm.Running -eq $false) {
                Write-Host "$i, $($Vm.Name)"
                $Choices += $Vm.FullName
                $i++
            }
        }
        Write-Host "9, Cancel"

        $HostResp = Read-Host "Enter a choice: "
        if (([int]$HostResp -gt $Vms.Count -or [int]$HostResp -lt 1) -and $HostResp -ne "9") {
            Write-Host "Invalid choice!"
            Write-Host "`n"
            continue

        } elseif ($HostResp -eq "9") {
            Write-Host "`n"
            continue
        
        } else {
            .\vmrun.exe -T workstation start "$($Choices[[int]$HostResp -1])" nogui
            Write-Host "`n"
            continue
        }

    } elseif ($HostResp -eq "2") {
        if ($RunningVms.Count -eq 0) {
            Write-Host "No running VMs to turn off!"
            Write-Host "`n"
            continue
        }

        Write-Host "Which host would you like to stop?"
        Write-Host "------------------------------------------"
        $i = 1
        $Choices = @()
        foreach ($Vm in $Vms) {
            if ($Vm.Running -eq $true) {
                Write-Host "$i, $($Vm.Name)"
                $Choices += $Vm.FullName
                $i++
            }
        }
        Write-Host "9, Cancel"

        $HostResp = Read-Host "Enter a choice: "
        if (([int]$HostResp -gt $Vms.Count -or [int]$HostResp -lt 1) -and $HostResp -ne "9") {
            Write-Host "Invalid choice!"
            Write-Host "`n"
            continue
        
        } elseif ($HostResp -eq "9") {
            Write-Host "`n"
            continue
        
        } else {
            .\vmrun.exe -T workstation stop "$($Choices[[int]$HostResp -1])" nogui
            Write-Host "`n"
            continue
        }

    } elseif ($HostResp -eq "9") {
        break
    
    } else {
        continue
    }
}
