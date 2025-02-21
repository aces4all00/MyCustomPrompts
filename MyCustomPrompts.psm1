$MyCustomPrompts = @{
    Standard = {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal] $identity
        $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($principal.IsInRole($adminRole)) {'[ADMIN]'}
        ) -join ''
        
        $body = @(
            '[PS {0}.{1}]' -f $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor
            $PWD.Path
        )
        
        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix}"
    }

    Demo = {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal] $identity
        $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($principal.IsInRole($adminRole)) {'[ADMIN]'}
            '[Demo]'
        ) -join ''
        
        $body = @(
            '[PS {0}.{1}]' -f $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor
            $PWD.Path
        )
        
        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix}"
    }
}

if ($Function:prompt) {
    $MyCustomPrompts["original"] = $Function:prompt.GetNewClosure()
}

function Set-MyCustomPrompt {
    param (
        [ValidateSet(
            "Original",
            "Standard",
            "Demo"
        )]
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $CustomPrompt
    )

    if (($MyCustomPrompts['Original']) -and ($MyCustomPrompts[$CustomPrompt])) {
        $Function:prompt = $MyCustomPrompts[$CustomPrompt].GetNewClosure()
    } else {
        Write-Error -Message "Aborting: Custom prompt '$CustomPrompt' does not exist"
    }
}

Export-ModuleMember -Variable 'MyCustomPrompts' -Function 'Set-MyCustomPrompt'