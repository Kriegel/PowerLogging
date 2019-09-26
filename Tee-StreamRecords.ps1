Function Tee-StreamRecords {

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
        [Object]$InputObject,
        
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

        switch ($InputObject)
         {
            {$InputObject -is [System.Management.Automation.WarningRecord]} {
               If($WarningHandler) { Invoke-Command $WarningHandler -ArgumentList $InputObject }
               If($AllHandler) { Invoke-Command $AllHandler -ArgumentList $InputObject }
            }
            {$InputObject -is [System.Management.Automation.VerboseRecord]} {
                If($VerboseHandler) { Invoke-Command $VerboseHandler -ArgumentList $InputObject }
                If($AllHandler) { Invoke-Command $AllHandler -ArgumentList $InputObject }
            }
            {$InputObject -is [System.Management.Automation.ErrorRecord]} {
                If($ErrorHandler) { Invoke-Command $ErrorHandler -ArgumentList $InputObject }
                If($AllHandler) { Invoke-Command $AllHandler -ArgumentList $InputObject }
            }
            {$InputObject -is [System.Management.Automation.DebugRecord]} {
                If($DebugHandler) { Invoke-Command $DebugHandler -ArgumentList $InputObject }
                If($AllHandler) { Invoke-Command $AllHandler -ArgumentList $InputObject }
            }
            {$InputObject -is [System.Management.Automation.InformationRecord]} {
                If($InformationHandler) { Invoke-Command $InformationHandler -ArgumentList $InputObject }
                If($AllHandler) { Invoke-Command $AllHandler -ArgumentList $InputObject }
            }
            default {
               # InputObject seems to be an Object for the succes stream so allways pass it thru
                $PSCmdlet.WriteObject($InputObject)
            }
         }
    }
    End{}
}

# log all ErrorRecord Objects to "$env:temp\my.log"
Get-ChildItem 'C:\Windows' -recurse *>&1 | Tee-StreamRecords -ErrorHandler { $Args[0] | Out-File "$env:temp\my.log" }