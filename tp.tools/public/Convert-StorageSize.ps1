function Convert-StorageSize {
    [CmdletBinding()]
    param (
        [ValidateSet('B','KB','MB','GB','TB','PB')]
        [string]$From,
        [ValidateSet('B','KB','MB','GB','TB','PB')]
        [string]$To,
        [Parameter(Mandatory)]
        [double]$Value
    )

    switch ($From) {
        'B'  { $Value = $Value }
        'KB' { $Value = $Value * [math]::Pow(1024,1) }
        'MB' { $Value = $Value * [math]::Pow(1024,2) }
        'GB' { $Value = $Value * [math]::Pow(1024,3) }
        'TB' { $Value = $Value * [math]::Pow(1024,4) }
        'PB' { $Value = $Value * [math]::Pow(1024,5) }
    }

    switch ($To) {
        'B'  { return $Value }
        'KB' { $Value = $Value / 1KB }
        'MB' { $Value = $Value / 1MB }
        'GB' { $Value = $Value / 1GB }
        'TB' { $Value = $Value / 1TB }
        'PB' { $Value = $Value / 1PB }
    }

    return [math]::Round($Value, 4, [System.MidpointRounding]::AwayFromZero)
}
