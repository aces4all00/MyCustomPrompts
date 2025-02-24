$null = if (($Function:prompt) -and ($null -eq $OriginalPrompt)) {
    $nv = @{
        Name = 'OriginalPrompt'
        Description = "Default prompt scriptblock as string"
        Option = 'ReadOnly'
        Value = $Function:prompt.ToString()
    }
    New-Variable @nv -Option ReadOnly
    $nv.Clear()
} else {
    $null
}

$null = if ($null -eq $ShortPSVersion) {
    $nv = @{
        Name = 'ShortPSVersion'
        Option = 'ReadOnly'
        Value = & {'{0}.{1}' -f @(
            $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor
        )}
    }
    New-Variable @nv
    $nv.Clear()
} else {
    $null
}

$null = if ($null -eq $IsAdmin) {
    $nv = @{
        Name = 'IsAdmin'
        Option = 'ReadOnly'
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

$DtmFmt = @{
    Full = 'yyyy-MM-dd HH:mm:ss'
    Date = 'yyyy-MM-dd'
    ShortDate = 'MM-dd'
    Year = 'yyyy'
    Month = 'MM'
    MonthName = 'MMMM'
    MonthShort = 'MMM'
    Day = 'dd'
    DayName = 'dddd'
    DayShort = 'ddd'
    Time = 'HH:mm:ss'
    TimeExt = 'HH:mm:ss.fff'
    TimeShort = 'HH:mm'
    Timestamp = 'yyyyMMddHHmmssfff'
}

$DynPrmpt = @{
    CfgPth = '.\DynamicPrompt.cfg'
    Cfg = $null
    LstPth = [string]::Empty
}

$MyCustomPrompts = @{
    Std = {
        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($isAdmin) {'[ADMIN]'}
        ) -join ''

        $body = @(
            "[PS $ShortPSVersion]"
            $PWD.Path
        ) -join ' '

        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix} "
    }

    Dem = {
        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($isAdmin) {'[ADMIN]'}
            '[Demo]'
        ) -join ''

        $body = @(
            "[PS $ShortPSVersion]"
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
            "[PS $ShortPSVersion]"
            $PWD.Path
        ) -join ' '

        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix} "
    }

    Job = {
        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($isAdmin) {'[ADMIN]'}
            '[Jobs]'
        ) -join ''

        $body = @(
            "[PS $ShortPSVersion]"
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
            "[PS $ShortPSVersion]"
            $PWD.Path
        ) -join ' '

        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix} "
    }

    Prj = {
        $prefix = @(
            if (Test-Path variable:/PSDebugContext) {'[DBG]'}
            if ($isAdmin) {'[ADMIN]'}
            '[Proj]'
        ) -join ''

        $body = @(
            "[PS $ShortPSVersion]"
            $PWD.Path
        ) -join ' '

        $suffix = ([string[]]@('>') * ($NestedPromptLevel + 1)) -join ''

        "${prefix}${body}${suffix} "
    }

    Dyn = {
        if (Test-Path -Path $DynPrmpt.CfgPth) {
            $DynPrmpt.Cfg ??= Get-Content -Path $DynPrmpt.CfgPth | ConvertFrom-Json
            if ($DynPrmpt.LstPth -ne $PWD.Path) {
                $dtm = [datetime]::Now
                $utc = [datetime]::UtcNow
                $DynPrmpt.LstPth = $PWD.Path
                & {Clear-Host}
                $msg = @(
                    if ($DynPrmpt.Cfg.ShowName) {"Name: $($DynPrmpt.Cfg.Name)"}
                    if ($DynPrmpt.Cfg.ShowMode) {"Mode: $($DynPrmpt.Cfg.Mode)"}
                    if ($DynPrmpt.Cfg.ShowDate) {"Date: $($dtm.ToString($DtmFmt.Date))"}
                    if ($DynPrmpt.Cfg.ShowTime) {"Time: $($dtm.ToString($DtmFmt.Time))"}
                    if ($DynPrmpt.Cfg.ShowUTC) {"UTC : $($utc.ToString($DtmFmt.Full))"}
                )
                Write-Information -MessageData "$($msg -join "`n")`n" -InformationAction Continue
            }
            $prefix = @(
                if (Test-Path variable:/PSDebugContext) {'[DBG]'}
                if ($isAdmin) {'[ADMIN]'}
                "[$($DynPrmpt.Cfg.Mode)]"
            ) -join ''
        } else {
            $DynPrmpt = @{
                CfgPth = '.\DynamicPrompt.cfg'
                Cfg = $null
                LstPth = [string]::Empty
            }

            $prefix = @(
                if (Test-Path variable:/PSDebugContext) {'[DBG]'}
                if ($isAdmin) {'[ADMIN]'}
            ) -join ''
        }

        "${prefix}PS $($PWD.Path)" + (">" * ($NestedPromptLevel +1))
    }
}

function Set-MyCustomPrompt {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param (
        [ValidateSet(
            'Std',
            'Dem',
            'Dev',
            'Job',
            'Log',
            'Prj',
            'Dyn'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $CustomPrompt
    )

    if ($MyCustomPrompts[$CustomPrompt]) {
        if ($PSCmdlet.ShouldProcess(
            'PowerShell prompt',
            "Sets PowerShell prompt to custom '$CustomPrompt' prompt"
        )) {
            $Function:prompt = $MyCustomPrompts[$CustomPrompt].GetNewClosure()
        }
    } else {
        Write-Error -Message "Aborting: Custom prompt '$CustomPrompt' does not exist"
    }
}

function Reset-ToOriginalPrompt {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param ()
    $originalSB = [scriptblock]::Create($OriginalPrompt)
    if($PSCmdlet.ShouldProcess(
        'PowerShell prompt',
        "Sets PowerShell prompt to back to original"
    )) {
        $Function:prompt = $originalSB
    }
}

Export-ModuleMember -Variable @(
    'MyCustomPrompts'
    'OriginalPrompt'
    'ShortPSVersion'
    'IsAdmin'
    'DtmFmt'
    'DynPrmpt'
) -Function @(
    'Set-MyCustomPrompt'
    'Reset-ToOriginalPrompt'
)