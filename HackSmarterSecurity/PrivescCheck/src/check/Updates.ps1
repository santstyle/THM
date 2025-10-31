function Invoke-WindowsUpdateCheck {
    <#
    .SYNOPSIS
    Gets the last update time of the machine.

    Author: @itm4n
    License: BSD 3-Clause

    .DESCRIPTION
    The Windows Update status can be queried thanks to the Microsoft.Update.AutoUpdate COM object. It gives the last successful search time and the last successful update installation time.

    .EXAMPLE
    PS C:\> Invoke-WindowsUpdateCheck

    Time
    ----
    2020-01-12 - 09:17:37
    #>

    [CmdletBinding()]
    param()

    try {
        $WindowsUpdate = (New-Object -ComObject "Microsoft.Update.AutoUpdate").Results

        if ($WindowsUpdate.LastInstallationSuccessDate) {
            $WindowsUpdateResult = New-Object -TypeName PSObject
            $WindowsUpdateResult | Add-Member -MemberType "NoteProperty" -Name "Time" -Value $(Convert-DateToString -Date $WindowsUpdate.LastInstallationSuccessDate -IncludeTime)
            $WindowsUpdateResult | Add-Member -MemberType "NoteProperty" -Name "TimeRaw" -Value $WindowsUpdate.LastInstallationSuccessDate
            $WindowsUpdateResult
        }
    }
    catch {
        # We might get an access denied when querying this COM object
        Write-Verbose "Error while requesting COM object Microsoft.Update.AutoUpdate."
    }
}

function Invoke-HotFixCheck {
    <#
    .SYNOPSIS
    If a patch was not installed in the last 31 days, return the latest patch that was installed, otherwise return nothing.

    .DESCRIPTION
    This check lists update packages and determines whether an update was applied within the last 31 days.

    .EXAMPLE
    PS C:\> Invoke-HotFixCheck

    HotFixID  Description     InstalledBy           InstalledOn
    --------  -----------     -----------           -----------
    KB4578968 Update          NT AUTHORITY\SYSTEM   2020-10-14 18:06:18
    KB4580325 Security Update NT AUTHORITY\SYSTEM   2020-10-14 13:09:37
    KB4577266 Security Update NT AUTHORITY\SYSTEM   2020-09-11 13:37:59
    KB4570334 Security Update NT AUTHORITY\SYSTEM   2020-08-13 17:45:34
    KB4566785 Security Update NT AUTHORITY\SYSTEM   2020-07-16 13:08:14
    KB4561600 Security Update NT AUTHORITY\SYSTEM   2020-06-22 13:00:50
    KB4537759 Security Update                       2020-05-11 07:44:14
    KB4557968 Security Update                       2020-05-11 07:37:09

    .NOTES
    Get-HotFix in PowerShell version 2 does not always report the installation date. The trick used in this script was taken from the following.
    https://p0w3rsh3ll.wordpress.com/2012/10/25/getting-windows-updates-installation-history/
    #>

    [CmdletBinding()]
    param(
        [UInt32] $BaseSeverity
    )

    begin {
        function Get-HotFixDate {
            $Session = New-Object -ComObject Microsoft.Update.Session
            $UpdateSearcher = $Session.CreateUpdateSearcher()
            $TotalHistoryCount = $UpdateSearcher.GetTotalHistoryCount()
            foreach ($UpdateItem in $($UpdateSearcher.QueryHistory(0, $TotalHistoryCount))) {
                if ($UpdateItem.Title -match "\(KB\d{6,7}\)") {
                    $Id = $Matches[0].Replace("(", "").Replace(")", "")
                }
                else {
                    continue
                }
                $Result = New-Object -TypeName PSObject
                $Result | Add-Member -MemberType "NoteProperty" -Name "HotFixID" -Value $Id
                $Result | Add-Member -MemberType "NoteProperty" -Name "InstalledOn" -Value $(Get-Date -Date $UpdateItem.Date)
                $Result
            }
        }

        $HotFixDates = $null
        $HotFixList = @()
        $Vulnerable = $false
    }

    process {

        $HotFixHistory = Get-HotFixWithTimeout -ErrorAction SilentlyContinue
        if ($null -eq $HotFixHistory) {
            Write-Warning "Failed to retrieve hotfix history."
        }

        foreach ($HotFix in $HotFixHistory) {

            if ($null -eq $HotFix.InstalledOn) {
                if ($null -eq $HotFixDates) { $HotFixDates = Get-HotFixDate }
                $InstalledOn = ($HotFixDates | Where-Object { $_.HotFixID -eq $HotFix.HotFixID } | Select-Object -First 1).InstalledOn
            }
            else {
                $InstalledOn = $HotFix.InstalledOn
            }

            # If still don't manage to get the installation date, show a warning message.
            if ($null -eq $InstalledOn) {
                Write-Warning "Failed to determine install date of update package $($HotFix.HotFixID)"
            }

            $HotFixObject = $HotFix | Select-Object HotFixID, Description, InstalledBy
            $HotFixObject | Add-Member -MemberType "NoteProperty" -Name "InstalledOn" -Value $InstalledOn
            $HotFixList += $HotFixObject
        }

        $HotFixListSorted = $HotFixList | Sort-Object -Property InstalledOn, HotFixID -Descending
        $LatestHotfix = $HotFixListSorted | Select-Object -First 1

        if ($null -ne $LatestHotfix) {
            $TimeSpan = New-TimeSpan -Start $LatestHotfix.InstalledOn -End $(Get-Date)

            if ($TimeSpan.TotalDays -gt 31) {
                $Vulnerable = $true
            }
        }

        $CheckResult = New-Object -TypeName PSObject
        $CheckResult | Add-Member -MemberType "NoteProperty" -Name "Result" -Value $HotFixListSorted
        $CheckResult | Add-Member -MemberType "NoteProperty" -Name "Severity" -Value $(if ($Vulnerable) { $BaseSeverity } else { $script:SeverityLevel::None })
        $CheckResult
    }
}

function Invoke-BiosUpdateCheck {
    <#
    .SYNOPSIS
    Check whether the BIOS was updated in the last 180 days.

    .DESCRIPTION
    This cmdlet uses the Get-SystemInformation helper to retrieve the BIOS release date and check whether it is older than 180 days.

    .EXAMPLE
    PS C:\> Invoke-BiosUpdateCheck

    BiosReleaseDate : 2025-02-21
    Description     : The BIOS was installed or updated 178 ago (<180).

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [UInt32] $BaseSeverity
    )

    begin {
        $MaxDays = 180
    }

    process {
        $Vulnerable = $false
        $SystemInformation = Get-SystemInformation

        if ([string]::IsNullOrEmpty($SystemInformation.BiosReleaseDate)) {
            Write-Warning "Failed to retrieve BIOS release date."
            $Description = "Failed to retrieve BIOS release date."
        }
        else {
            $BiosReleaseDate = Convert-StringToDate -Date $SystemInformation.BiosReleaseDate
            $TimeSpan = New-TimeSpan -Start $BiosReleaseDate -End $(Get-Date)
            $TotalDays = [math]::Ceiling($TimeSpan.TotalDays)
            $Description = "The BIOS was installed or updated $($TotalDays) days ago"

            if ($TotalDays -gt $MaxDays) {
                $Description += " (>$($MaxDays))."
                $Vulnerable = $true
            }
            else {
                $Description += " (<$($MaxDays))."
            }
        }

        $Result = New-Object -TypeName PSObject
        $Result | Add-Member -MemberType "NoteProperty" -Name "BiosReleaseDate" -Value $SystemInformation.BiosReleaseDate
        $Result | Add-Member -MemberType "NoteProperty" -Name "Description" -Value $Description

        $CheckResult = New-Object -TypeName PSObject
        $CheckResult | Add-Member -MemberType "NoteProperty" -Name "Result" -Value $Result
        $CheckResult | Add-Member -MemberType "NoteProperty" -Name "Severity" -Value $(if ($Vulnerable) { $BaseSeverity } else { $script:SeverityLevel::None })
        $CheckResult
    }
}
