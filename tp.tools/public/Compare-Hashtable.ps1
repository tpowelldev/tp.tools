function Compare-Hashtable {
    <#
    .SYNOPSIS
    Recursive hash table comparison function

    .DESCRIPTION
    Recursively compares the key/vale (or only key) pairs of each hash table, returning differences,
    or optionally differences and matches

    .PARAMETER Reference
    Reference hashtable for comparison

    .PARAMETER Difference
    Difference hashtable for comparison

    .PARAMETER IncludeEqual
    Rather than returning $null if the tables match, display the matching elements

    .PARAMETER KeysOnly
    Perform the comparison on only the keys of each hashtable.
    This can be useful when comparing empty template configuration files for example

    .EXAMPLE
    Compare-Hashtable -Reference $hash1 -Difference $hash2

    Compares keys and values of the assigned hashtables, returning '<=','!=','=>' depending where differences lie.

    .EXAMPLE
    Compare-Hashtable -Reference $hash1 -Difference $hash2 -IncludeEqual:$true

    Compares keys and values of the assigned hashtables, returning '<=','!=','=>' for any differences and '==' for equal values

    .EXAMPLE
    Compare-Hashtable -Reference $hash1 -Difference $hash2 -KeysOnly:$true

    Compares only the keys in the assigned hashtables. This can be useful when comparing empty template configuration files, etc.

    .NOTES

    #>

    param
    (
        [hashtable]$Reference,
        [hashtable]$Difference,
        [switch]$IncludeEqual,
        [switch]$KeysOnly
    )

    # Need to recurse any nested keys, so create an internal function to do this
    function AnalyseHashTable {
        param (
            [hashtable]$Hash1,
            [hashtable]$Hash2,
            [string]$Direction,
            [boolean]$IncludeEqual = $false,
            [boolean]$KeysOnly = $false,
            [string]$Parent = ''
        )

        foreach ($rKey in $Hash1.Keys) {

            # Check to see if the current value is a nested hashtable, we'll recurse later if so
            if ($null -ne $Hash1[$rKey] -and $Hash1[$rKey].GetType().Name -eq 'Hashtable') {
                $isHashtable = $true
            } else {
                $isHashtable = $false
            }

            # Check to see if the current key exists in the other object at our current depth,
            # If not, no point continuing on this branch
            if ($Hash1.ContainsKey($rKey) -and -not $Hash2.ContainsKey($rKey)) {
                [pscustomobject]@{
                    Key           = $parent+$rKey
                    RefValue      = $null
                    DifValue      = $null
                    SideIndicator = $Direction
                }
                continue
            } else {
                # If we're only looking for keys and we're including equal, write the result
                if ($KeysOnly){
                    if ($IncludeEqual) {
                        [pscustomobject]@{
                            Key           = $parent+$rKey
                            RefValue      = $null
                            DifValue      = $null
                            SideIndicator = '=='
                        }
                    }
                    # If this key contains a nested hashtable, recurse to the child
                    if ($isHashtable -eq $true) {
                        $parent = "$rKey."
                        AnalyseHashTable -Hash1 $Hash1.$rKey -Hash2 $Hash2.$rKey -Direction $Direction -IncludeEqual $IncludeEqual -KeysOnly $KeysOnly -Parent $parent
                    }
                } else {
                    # If the current key's contents isn't a hashtable, compare the value
                    if ($isHashtable -ne $true) {
                        if ($Hash1.$rKey -ne $Hash2.$rKey) {
                            [pscustomobject]@{
                                Key             = $parent+$rKey
                                RefValue        = $Hash1.$rKey
                                DifValue        = $Hash2.$rKey
                                SideIndicator   = '!='
                            }
                        } else {
                            if ($IncludeEqual) {
                                [pscustomobject]@{
                                    Key           = $parent+$rKey
                                    RefValue      = $Hash1.$rKey
                                    DifValue      = $Hash2.$rKey
                                    SideIndicator = '=='
                                }
                            }
                        }
                    } else {
                        # Again, it it's a nested hashtable, recurse to the child
                        if ($IncludeEqual) {
                            [pscustomobject]@{
                                Key           = $parent+$rKey
                                RefValue      = $null
                                DifValue      = $null
                                SideIndicator = '=='
                            }
                        }
                        $parent = "$rKey."
                        AnalyseHashTable -Hash1 $Hash1.$rKey -Hash2 $Hash2.$rKey -Direction $Direction -IncludeEqual $IncludeEqual -KeysOnly $KeysOnly -Parent $parent
                    }
                }
            }
        }
    }

    $output =  [System.Collections.Generic.List[psobject]]::new()

    # Test the reference keys and add matches to the output
    $splatRef = @{
        Hash1           = $Reference
        Hash2           = $Difference
        Direction       = '<='
        IncludeEqual    = if ($IncludeEqual) { $true } else { $false }
        KeysOnly        = if ($KeysOnly) { $true } else { $false }
    }
    AnalyseHashTable @splatRef | ForEach-Object { $output.Add($_) }

    # Now test the difference keys and add matches to the output
    $splatDif = @{
        Hash1           = $Difference
        Hash2           = $Reference
        Direction       = '=>'
        IncludeEqual    = if ($IncludeEqual) { $true } else { $false }
        KeysOnly        = if ($KeysOnly) { $true } else { $false }
    }
    AnalyseHashTable @splatDif | Where-Object SideIndicator -eq '=>' | ForEach-Object { $output.Add($_) }

    $output
}
