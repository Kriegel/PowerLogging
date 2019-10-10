Function Invoke-StreamRecordFilter {
<#
.Synopsis
    Function to Process redirected PowerShell streams and provide a handler for each stream-record Object
.DESCRIPTION
    Function to Process Redirected PowerShell Streams and provide a Handler for each Record Object
    With a Redirection Operator of  *>&1 you can Handle ALL PowerShell Streams in one Function.

    So you can do further Processing of all PowerShell Streams
    for Example you can do any kind of Logging with the Stream Objects

.EXAMPLE
    #log all Stream-Record Objects to "$env:temp\my.log"
    Get-ChildItem 'C:\Windows' -recurse *>&1 | Invoke-StreamRecordFilters -ErrorHandler { $Args[0] | Out-File "$env:temp\my.log" -Append }

.EXAMPLE
    # create helper function to send record objects down the pipeline
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


    #log all ErrorRecord Objects to "$env:temp\my.log"
    New-PsStreamRecordObject *>&1 | Invoke-StreamRecordFilters -AllHandler { $Args[0] | Out-File "$env:temp\my.log" -Append }

.Link
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection

.Notes
    Author: Peter Kriegel
    Version: 1.0.0 26.September.2019 (Inital release)
#>
    [CmdletBinding()]
    param(

        <#
            InputObjects which are NOT type of ErrorRecord or WarningRecord or DebugRecord or VerboseRecord or InformationRecord
            are allways passed thru without any further processing

            If InputObject is type of ErrorRecord or WarningRecord or DebugRecord or VerboseRecord or InformationRecord
            and if you wish to PassThru the InputObject, the handler has to return the Object !
        #>
        [parameter(Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true
        )]
        [Object[]]$InputObject,

            # is invoked if InputObject is type of WarningRecord
        [Scriptblock]$WarningHandler,
            # is invoked if InputObject is type of VerboseRecord
        [Scriptblock]$VerboseHandler,
            # is invoked if InputObject is type of ErrorRecord
        [Scriptblock]$ErrorHandler,
            # is invoked if InputObject is type of DebugRecord
        [Scriptblock]$DebugHandler,
            # is invoked if InputObject is type of InformationRecord
        [Scriptblock]$InformationHandler,
        # is invoked if InputObject is type of ErrorRecord or WarningRecord or DebugRecord or VerboseRecord or InformationRecord
        [Scriptblock]$AllHandler
    )

    Begin{}
    Process{

        ForEach ($Object in $InputObject) {
            switch ($Object)
                {
                {$Object -is [System.Management.Automation.WarningRecord]} {
                    If($WarningHandler) { Invoke-Command -ScriptBlock $WarningHandler -ArgumentList $Object }
                    If($AllHandler) { Invoke-Command -ScriptBlock $AllHandler -ArgumentList $Object }
                }
                {$Object -is [System.Management.Automation.VerboseRecord]} {
                    If($VerboseHandler) { Invoke-Command -ScriptBlock $VerboseHandler -ArgumentList $Object }
                    If($AllHandler) { Invoke-Command -ScriptBlock $AllHandler -ArgumentList $Object }
                }
                {$Object -is [System.Management.Automation.ErrorRecord]} {
                    If($ErrorHandler) { Invoke-Command -ScriptBlock $ErrorHandler -ArgumentList $Object }
                    If($AllHandler) { Invoke-Command -ScriptBlock $AllHandler -ArgumentList $Object }
                }
                {$Object -is [System.Management.Automation.DebugRecord]} {
                    If($DebugHandler) { Invoke-Command -ScriptBlock $DebugHandler -ArgumentList $Object }
                    If($AllHandler) { Invoke-Command -ScriptBlock $AllHandler -ArgumentList $Object }
                }
                {$Object -is [System.Management.Automation.InformationRecord]} {
                    If($InformationHandler) { Invoke-Command -ScriptBlock $InformationHandler -ArgumentList $Object }
                    If($AllHandler) { Invoke-Command -ScriptBlock $AllHandler -ArgumentList $Object }
                }
                default {
                    # InputObject seems to be an Object for the succes stream so allways pass it thru
                    $PSCmdlet.WriteObject($Object)
                }
                }
            }
    }
    End{}
}
