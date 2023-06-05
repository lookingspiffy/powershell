function New-QuickMenu {

    <#
    .SYNOPSIS
        Convert an array into a selectable menu.
    
    
    .NOTES
        Name: New-QuickMenu
        Author: github/lookingspiffy
        Version: 1.0
        DateCreated: 2022-Mar-31


    .DESCRIPTION
        This function converts an item array into a selectable list. When the choice is submitted, the array item is returned.
    
    
    .EXAMPLE
        New-QuickMenu -Options "Strawberry, Raspberry, Blueberry" -Prompt "Select a berry"
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)]
        [array]$Options,
        [parameter(position=1)]
        [string]$Prompt = "Select one"
    )
    $vSelection = Read-Host -Prompt "$(
        "$($Prompt):`n`n"
        [int]$i = 1
        foreach ($vOption in $Options){
            "$($i): $($vOption)`n"
            $i++        
        }
            "`nSelect an option"
    )"
    Write-Verbose "vSelection = $($vSelection)"
    $Options[$vSelection-1]
}