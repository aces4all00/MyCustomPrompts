$null = if (($Function:prompt) -and ($null -eq $Global:OriginalPrompt)) {
    $nv = @{
        Name = 'OriginalPrompt'
        Description = "Default prompt scriptblock as string"
        Scope = 'Global'
        Option = 'Constant'
        Value = $Function:prompt.ToString()
    }
    New-Variable @nv
    $nv.Clear()
} else {
    $null
}

$null = if ($null -eq $Global:ShortPSVersion) {
    $nv = @{
        Name = 'ShortPSVersion'
        Scope = 'Global'
        Option = 'Constant'
        Value = & {'{0}.{1}' -f @(
            $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor
        )}
    }
    New-Variable @nv
    $nv.Clear()
} else {
    $null
}

$null = if ($null -eq $Global:IsAdmin) {
    $nv = @{
        Name = 'IsAdmin'
        Scope = 'Global'
        Option = 'Constant'
        Value = & {
            if ($IsWindows) {
                $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
                $principal = [Security.Principal.WindowsPrincipal]$identity
                $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            } else {$false}
        }
    }
    New-Variable @nv
    $nv.Clear()
} else {
    $null
}

$MyCustomPrompts = @{
    Standard = {
        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($isAdmin) {'[ADMIN]'}
        ) -join ''
        
        $body = @(
            '[PS{0}]' -f $Global:ShortPSVersion
            $PWD.Path
        ) -join ' '
        
        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix} "
    }

    Demo = {
        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($isAdmin) {'[ADMIN]'}
            '[Demo]'
        ) -join ''
        
        $body = @(
            '[PS{0}]' -f $Global:ShortPSVersion
            $PWD.Path
        ) -join ' '
        
        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix} "
    }

    Dev = {
        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($isAdmin) {'[ADMIN]'}
            '[Dev]'
        ) -join ''
        
        $body = @(
            '[PS{0}]' -f $Global:ShortPSVersion
            $PWD.Path
        ) -join ' '
        
        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix} "
    }

    Jobs = {
        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($isAdmin) {'[ADMIN]'}
            '[Jobs]'
        ) -join ''
        
        $body = @(
            '[PS{0}]' -f $Global:ShortPSVersion
            $PWD.Path
        ) -join ' '
        
        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix} "
    }

    Log = {
        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($isAdmin) {'[ADMIN]'}
            '[Log]'
        ) -join ''
        
        $body = @(
            '[PS{0}]' -f $Global:ShortPSVersion
            $PWD.Path
        ) -join ' '
        
        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix} "
    }

    Project = {
        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($isAdmin) {'[ADMIN]'}
            '[Proj]'
        ) -join ''
        
        $body = @(
            '[PS{0}]' -f $Global:ShortPSVersion
            $PWD.Path
        ) -join ' '
        
        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix} "
    }
}

function Set-MyCustomPrompt {
    param (
        [ValidateSet(
            'Standard',
            'Demo',
            'Dev',
            'Jobs',
            'Log',
            'Project'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $CustomPrompt
    )

    if ($MyCustomPrompts[$CustomPrompt]) {
        $Function:prompt = $MyCustomPrompts[$CustomPrompt].GetNewClosure()
    } else {
        Write-Error -Message "Aborting: Custom prompt '$CustomPrompt' does not exist"
    }
}

function Reset-ToOriginalPrompt {
    param ()
    $originalSB = [scriptblock]::Create($Global:OriginalPrompt)
    $Function:prompt = $originalSB
}

Export-ModuleMember -Variable @(
    'MyCustomPrompts'
) -Function @(
    'Set-MyCustomPrompt'
    'Reset-ToOriginalPrompt'
)