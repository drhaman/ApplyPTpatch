
<#PSScriptInfo
    .VERSION 1.0
    .GUID 
    .AUTHOR Dale
    .SYNOPSIS
        PTPAPPLY
    .DESCRIPTION
        Apply PT Patch to target DB
    .PARAMETER PTVersion
        Peopletools patch without dots 85908
    .PARAMETER TargetDB
        Target database in Upper Case HEFD
    .EXAMPLE
        ApplyPTpatch.ps1 -ptversion 85908 -targetdb HEFD
#>


[CmdletBinding()]
    Param(
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [String]
        $ptversion,

        [Parameter(Mandatory=$true)]
        [String]
        $targetdb
        )

$ptmajor=$ptversion.Substring(0,3)

$ca_home = 'C:\psoft\ca'
$STEP = 0
$status = "running"
if ($STEP -eq 0) {
    Write-output "Starting new PeopleTools Upgrade job for ${targetdb}"
    Set-Location ${ca_home}\${ptversion}
    & ".\changeassistant.bat" `
        -MODE UM `
        -ACTION PTPAPPLY `
        -TGTENV ${targetdb} `
        -OUT "${ca_home}\output\PTPAPPLY-Start.log" `
        -UPD "PATCH${ptmajor}" `
        -WARNINGSOK Y -EXONERR Y 
} else {
    Write-Output "Resuming PeopleTools Upgrade job for ${targetdb}"
}
Do {
    Set-Location ${ca_home}\${ptversion}
    & ".\changeassistant.bat" `
        -MODE UM `
        -ACTION PTPAPPLY `
        -TGTENV ${targetdb} `
        -OUT "${ca_home}\output\PTPAPPLY-$STEP.log" `
        -UPD "PATCH${ptmajor}" `
        -WARNINGSOK Y -EXONERR Y -RESETJOB N -RESUMEJOB COMPLETECONTINUE
    Write-Host "Change Assistant Exit Code: ${LASTEXITCODE}"
    switch ($LASTEXITCODE) {
        0 { 
            Write-Output    "Change Assistant reported no more steps to run."
            $status = "done"
            break
        }
        1 { 
            Write-Output    "Error in PeopleTools upgrade job. Open Change Assistant to review the error."
            Write-Host      "Command to open CA: set-location '${ca_home}\${ptversion}'; .\changeassistant.bat"
            Write-Host      "Error on Step: `n`t" ${STEP} "("  ")"
            Set-Location ${ca_home}\${ptversion}
            break 
        }
        2 { 
            # Add Code in here to capture the CA output, determine the manual stop, and handle appropriately
            # For now, continue for a vanilla upgrade
            Write-Host      "Manual Stop Encountered"
            Write-Host      "Manual Stop "  " Completed"
            Write-Host      "Step: " $STEP
        }
        3 { 
            Write-Output    "Change Assistant failed to get a lock on the environment."
            Write-Host      "Command to open CA: set-location '${ca_home}\${ptversion}'; .\changeassistant.bat"
            Write-Host      "Error on Step: `n`t" ${STEP} "("  ")"
            $status = "Error"
        }
        Default {
            Write-Output    "Unknown Error Occured. Exiting."
            Write-Host      "Command to open CA: set-location '${ca_home}\${ptversion}'; .\changeassistant.bat"
            Write-Host      "Error on Step: `n`t" ${STEP} "("  ")"
            $status = "Error"
        }
    }
    $STEP++
} while ($status -eq "running")
