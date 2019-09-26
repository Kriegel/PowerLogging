Function New-PsStreamRecordObject {

    [CmdletBinding()]
    param ()

    Process {

        $InformationPreference = 'Continue'
        $VerbosePreference = 'Continue'
        $DebugPreference = 'Continue'
        $WarningPreference = 'Continue'
        $ErrorPreference = 'Continue'

        $PSCmdlet.WriteInformation('PSCmdlet Information',@('Tag1','Tag2','Tag3'))
        Write-Information 'Write Information' -Tags 'Tag1','Tag2','Tag3'

        $PSCmdlet.WriteVerbose('PSCmdlet Verbose')
        Write-Verbose 'Write Verbose'

        $PSCmdlet.WriteDebug('PSCmdlet Debug')
        Write-Debug 'Write Debug'

        $PSCmdlet.WriteWarning('PSCmdlet Warning')
        Write-Warning 'Write Warning'

        $ErrorRecord = Write-Error 'PSCmdlet Error' 2>&1
        $PSCmdlet.WriteError($ErrorRecord)
        Write-Error 'Write Error'

    }
}