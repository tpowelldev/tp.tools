$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$modulePath = "$here\..\.."
$moduleName = Split-Path -Path $modulePath -Leaf
$function = Get-ChildItem -Path "$modulePath\Public\Compare-Hashtable.ps1"

Describe "Compare-Hashtable" -Tags 'TestFunction' {
    # Mock hash tables to pass to function
    $refHash = @{
        oneA  = @{
            twoA  = 'somevalue'
            twoB = @{
                threeA = $null
            }
            twoC = $null
        }
        oneB = $null
        oneC = @{
            twoD = $null
        }
    }
    $difHash = @{
        oneA  = @{
            twoA  = $null
            twoB = @{
                threeA = 'differentvalue'
                threeB = $null
            }
            twoC = $null
            twoD = @{
                threeC = $null
            }
        }
        oneB = $null
    }

    It 'Has correct result for keys only' {
        $testKey = [System.Collections.Generic.List[psobject]]::new()
        $testKey.Add([pscustomobject]@{ Key='oneC'; RefValue=$null; DifValue=$null; SideIndicator='<=' })
        $testKey.Add([pscustomobject]@{ Key='twoB.threeB'; RefValue=$null; DifValue=$null; SideIndicator='=>' })
        $testKey.Add([pscustomobject]@{ Key='twoB.twoD'; RefValue=$null; DifValue=$null; SideIndicator='=>' })

        $rtnKey = Compare-Hashtable -Reference $refHash -Difference $difHash -KeysOnly

        Compare-Object -ReferenceObject $testKey -DifferenceObject $rtnKey | Should BeNullOrEmpty
        Compare-Object -ReferenceObject $testKey -DifferenceObject $rtnKey -IncludeEqual | Should Not BeNullOrEmpty
        $testKey.Count | Should Match $rtnKey.Count
    }

    It 'Has correct result for keys only including equal' {
        $testKeyEq = @(
            [pscustomobject]@{ Key='oneC'; RefValue=$null; DifValue=$null; SideIndicator='<=' },
            [pscustomobject]@{ Key='oneB'; RefValue=$null; DifValue=$null; SideIndicator='==' },
            [pscustomobject]@{ Key='oneA'; RefValue=$null; DifValue=$null; SideIndicator='==' },
            [pscustomobject]@{ Key='oneA.twoB'; RefValue=$null; DifValue=$null; SideIndicator='==' },
            [pscustomobject]@{ Key='twoB.threeA'; RefValue=$null; DifValue=$null; SideIndicator='==' },
            [pscustomobject]@{ Key='twoB.twoC'; RefValue=$null; DifValue=$null; SideIndicator='==' },
            [pscustomobject]@{ Key='twoB.twoA'; RefValue=$null; DifValue=$null; SideIndicator='==' },
            [pscustomobject]@{ Key='twoB.threeB'; RefValue=$null; DifValue=$null; SideIndicator='=>' },
            [pscustomobject]@{ Key='twoB.twoD'; RefValue=$null; DifValue=$null; SideIndicator='=>' }
        )

        $rtnKeyEq = Compare-Hashtable -Reference $refHash -Difference $difHash -IncludeEqual -KeysOnly

        Compare-Object -ReferenceObject $testKeyEq -DifferenceObject $rtnKeyEq | Should BeNullOrEmpty
        Compare-Object -ReferenceObject $testKeyEq -DifferenceObject $rtnKeyEq -IncludeEqual | Should Not BeNullOrEmpty
        $testKeyEq.Count | Should Match $rtnKeyEq.Count
    }

    It 'Has correct result for keys and values' {
        $testValue = @(
            [pscustomobject]@{ Key='oneC'; RefValue=$null; DifValue=$null; SideIndicator='<=' },
            [pscustomobject]@{ Key='twoB.threeA'; RefValue=$null; DifValue='differentvalue'; SideIndicator='!=' },
            [pscustomobject]@{ Key='twoB.twoA'; RefValue='somevalue'; DifValue=$null; SideIndicator='!=' }, 
            [pscustomobject]@{ Key='twoB.threeB'; RefValue=$null; DifValue=$null; SideIndicator='=>' },
            [pscustomobject]@{ Key='twoB.twoD'; RefValue=$null; DifValue=$null; SideIndicator='=>' }
        )

        $rtnValue = Compare-Hashtable -Reference $refHash -Difference $difHash

        Compare-Object -ReferenceObject $testValue -DifferenceObject $rtnValue | Should BeNullOrEmpty
        Compare-Object -ReferenceObject $testValue -DifferenceObject $rtnValue -IncludeEqual | Should Not BeNullOrEmpty
        $testValue.Count | Should Match $rtnValue.Count
    }

    It 'Has correct result for keys and values including equal' {
        $testValueEq = @(
            [pscustomobject]@{ Key='oneC'; RefValue=$null; DifValue=$null; SideIndicator='<=' },
            [pscustomobject]@{ Key='oneB'; RefValue=$null; DifValue=$null; SideIndicator='==' },
            [pscustomobject]@{ Key='oneA'; RefValue=$null; DifValue=$null; SideIndicator='==' },
            [pscustomobject]@{ Key='oneA.twoB'; RefValue=$null; DifValue=$null; SideIndicator='==' },
            [pscustomobject]@{ Key='twoB.threeA'; RefValue=$null; DifValue='differentvalue'; SideIndicator='!=' },
            [pscustomobject]@{ Key='twoB.twoC'; RefValue=$null; DifValue=$null; SideIndicator='==' },
            [pscustomobject]@{ Key='twoB.twoA'; RefValue='somevalue'; DifValue=$null; SideIndicator='!=' }, 
            [pscustomobject]@{ Key='twoB.threeB'; RefValue=$null; DifValue=$null; SideIndicator='=>' },
            [pscustomobject]@{ Key='twoB.twoD'; RefValue=$null; DifValue=$null; SideIndicator='=>' }
        )

        $rtnValueEq = Compare-Hashtable -Reference $refHash -Difference $difHash -IncludeEqual

        Compare-Object -ReferenceObject $testValueEq -DifferenceObject $rtnValueEq | Should BeNullOrEmpty
        Compare-Object -ReferenceObject $testValueEq -DifferenceObject $rtnValueEq -IncludeEqual | Should Not BeNullOrEmpty
        $testValueEq.Count | Should Match $rtnValueEq.Count
    }
}
