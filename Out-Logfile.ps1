Function Out-LogFile {
<#
.Synopsis
   The Out-LogFile function sends a text with additional metadata for loggin purposes as output to a logfile to the file system.
   This function uses the Out-File Cmdlet internally so the behavior is mostly similar to the origin Microsoft.PowerShell.Utility\Out-File cmdlet.

.DESCRIPTION
   The Out-LogFile function sends a text with additional metadata for loggin purposes as output to a logfile to the file system.
   This function uses the Out-File Cmdlet internally so the behavior is mostly similar to the origin Microsoft.PowerShell.Utility\Out-File cmdlet.

   In computing, a logfile (or simply log) is a file that records a text-message which reports /describes the effect of a single event an single action or simply a change of a single state.
   The act of keeping a logfile is called logging.
   Logging should help to retrieve an event that was happen in the past.
   So the message needs metadata to recover the event.
   This Metadata should be:

    Time, When did the event occur?
      The time is added automatically to the message, during the write process as an UTC formated string.
      HH:mm:ss.mmmm-+<UtcOffset.TotalMinutes>

    Place, What has triggered the event?
      Provide this information to the -EventSource parameter.

    importance; What impact has the event?
      Provide this information to the -Severity parameter.

.PARAMETER Message
  The text-message which reports / describes the effect of a the event or action or the change of a state.

.PARAMETER EventSource
  The event source indicates what logs the event.
  The event source is the name of the script, software or part of the software that was the source of the event.
  It is often the name of the application or the name of a subcomponent of the application if the application is large.

  If no Eventsource is given the default is the path of the MyInvocation.MyCommand.Path ($PSVersionTable.PSVersion.Major -ge 3) { "hallo!"}) of the script that runs this function.

.PARAMETER Severity
    The severity level defines the intensity of the event that occur.
    A event can have one of the the following severity level, in the decreasing order of severity:

    'Critical' or 'Fatal' or 'Error' or 'Err'
      Critical runtime errors that might cause severe/unexpected results. or other runtime errors.
      The message is also written to the PowerShell-Error stream with the Write-Error Cmdlet by default (see -NoStreamWriting parameter)

    'Warning' or 'Warn'
      Warning about events that might result in an error or can interfere the process.
      The message is also written to the PowerShell-Warning stream with the Write-Warning Cmdlet by default (see -NoStreamWriting parameter)

    'Information' or 'Info' or 'Verbose' or 'Verb'
      Information about general events that is not an error or a warning.
      The message is also written to the PowerShell-Verbose stream with the Write-Verbose Cmdlet by default (see -NoStreamWriting parameter)

    'Debug' or 'Dbg'
      Detailed (verbose) information about the event during debugging.
      The message is also written to the PowerShell-Debug stream with the Write-Debug Cmdlet by default (see -NoStreamWriting parameter)

    The message format for the Trace32.exe / CMTrace.exe are support only a subset of the severity levels.
    Trace32.exe / CMTrace.exe format is using numbers for the severity level.
    The severity levels for the Trace32.exe / CMTrace.exe format are mapped like so:

    'Fatal' or 'Error' or 'Err' are resulting in the severity level of 3
    'Warning' or 'Warn' are resulting in the severity level of 2
    'Information' or 'Info' or 'Verbose' or 'Verb' or 'Debug' are resulting in the severity level of 1

    the default Severity is 'Information'

.PARAMETER Ident
  number of spaces for indentation depth of the text to write.

  the default is 0

.PARAMETER MessageFormat
  This parameter dictates in which format the message and the coresponding metadata is written to.
  The following formats are avaiable with this function:

  'Plain'
    only the message string is written to the file with indentation depth

  'VerbosePlain' (default)
    The message string is written to the file with indentation depth and additional metadata such as:
    (The  squared brackets are also written to the file to separate the informations)

        indentation [MM-dd-yyyy TimeUTC] [Severity] [Message] [EventSource]

  'Trace32' or 'CMTrace'
     The message string is written to the file with CMTrace compatible format:
          indentation <![LOG[Message]LOG]!><time="TimeUTC"date="M-d-yyyy"component="EventSource"context="UserID"type="SeverityNumber"thread="CurrentThread"file="">

.PARAMETER NoStreamWriting
  use this parameter if you do not want to rewrite the message to the PowerShell streams.
  By default the text ot the -Message parameter is written to one of the PowerShell streams.
  The -Severity parameter dictate to which stream the message is written, see documentation of the -Severity parameter.

.PARAMETER Append
  Adds the output to the end of an existing file, instead of replacing the file contents.

.PARAMETER Encoding
  Specifies the type of character encoding used in the file. The acceptable values for this parameter are:

  - Unknown
  - String
  - Unicode
  - BigEndianUnicode
  - UTF8
  - UTF7
  - UTF32
  - ASCII
  - Default
  - OEM

  Unicode is the default.

  Default uses the encoding of the system's current ANSI code page.
  OEM uses the current original equipment manufacturer code page identifier for the operating system.

.PARAMETER FilePath
  Specifies the path to the output file.
  If no file path or literal path is given, the default file path is $env:Temp\PowerShellWriteLog.log

.PARAMETER Force
  Allows the cmdlet to overwrite an existing read-only file. Even using the Force parameter, the cmdlet cannot override security restrictions.

.PARAMETER NoClobber
  Will not overwrite (replace the contents) of an existing file. By default, if a file exists in the specified path, Out-LogFile overwrites the file without warning. If both Append and NoClobber are used, the output is appended to the existing file.

.PARAMETER Width
  Specifies the number of characters in each line of output. Any additional characters are truncated, not wrapped. If you omit this parameter, the width is determined by the characteristics of the host. The default for the Windows PowerShell console is 80 (characters).

.PARAMETER LiteralPath
  Specifies the path to the output file. Unlike FilePath, the value of the LiteralPath parameter is used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters as escape sequences.
  If no file path or literal path is given, the default file path is $env:Temp\PowerShellWriteLog.log

.PARAMETER Confirm
  Prompts you for confirmation before running the cmdlet.

.PARAMETER WhatIf
  Shows what would happen if the cmdlet runs. The cmdlet is not run.

.EXAMPLE
    
    Running a script and Log all stream record Objects as JSON formatted log-entrys
    
    
    # Sript to run
    # Put it into curly brackets and add & Operator to run the script
    & {
        Write-Output good
        Write-Error bad
        Write-Warning problematic
        Write-Verbose palaver -Verbose
        Write-Information NotImportand -InformationAction Continue

    # Call to Out-Logfile after closing curly bracket with with redirection operator into pipeline
    } *>&1 | Out-LogFile -FilePath 'C:\Temp\MyLogFile.log' -MessageFormat 'JSON' -NoStreamReWriting -Append


.NOTES
  Author: Peter Kriegel

  Version: 1.1.1 From: 10.October.2019
        Minor Bugfix, Example added
    1.1.0 From: 23.September.2019 (Initial relaese)

  Credits:

  Code for Trace32.exe / CMTrace.exe compatibility taken from:
  Log-ScriptEvent Function by Ian Farr [MSFT]
  http://gallery.technet.microsoft.com/scriptcenter/Log-ScriptEvent-Function-ea238b85

#>

  [CmdletBinding(DefaultParameterSetName='ByPath', SupportsShouldProcess=$true, ConfirmImpact='Medium')]
  param(
    [Parameter(ParameterSetName='ByPath',Position=0)]
    [String]$FilePath,

    [Parameter(ParameterSetName='ByLiteralPath', ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath')]
    [string]$LiteralPath,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('unknown','string','unicode','bigendianunicode','utf8','utf7','utf32','ascii','default','oem')]
    [string]$Encoding = 'ascii',

    [ValidateRange(2, 2147483647)]
    [Int]$Width,

    [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
    [PSObject]$InputObject,

    [Parameter()]
    [Alias('Component')]
    [String]$EventSource,

    [Parameter()]
    [ValidateSet('Critical','Fatal','Error','Err','Warning','Warn','Information','Info','Debug','Dbg','Verbose','Verb')]
    [Alias('Level')]
    [String]$Severity = 'Information',

    [Parameter()]
    [ValidateRange(0,32767)]
    [Int16]$Indent = 0,

    # TODO: Syslog format
    [Parameter()]
    [ValidateSet('Plain', 'VerbosePlain', 'Trace32', 'CMTrace','JSON','XML')]
    [String]$MessageFormat = 'VerbosePlain',

    [Parameter()]
    [String[]]$Tags,

    [Parameter()]
    [Alias('Silent')]
    [Switch]$NoStreamReWriting,

    [Switch]$Append,

    [Switch]$Force,

    [Alias('NoOverwrite')]

    [Switch]$NoClobber

    )

  Begin {

        # get all names of the parameters out of the origin command
        # you must use the full path to the command here because there can exist already a proxy of that command!
        $OriginParamList = (Get-Command -Name 'Microsoft.PowerShell.Utility\Out-File').Parameters.Keys

        # create an parameter-dictionary to clone from $PSBoundParameters
        # we have to clone $PSBoundParameters because if you remove a pararameter from $PSBoundParameters,
        # further splatting actions by use of $PSBoundParameters will go wrong
        $OriginCommandParameters = New-Object -TypeName 'System.Collections.Generic.Dictionary[[System.String],[System.Object]]'
   }



  Process {

    # logging should never ever break the main process
    # so we do a catch all approach here
    try {

      # get date and time of event first of all processing
      # we calculate it as an UTC formated string later
      $Now = Get-Date

      # hash to collect the logging data into one bag
      $LogHash = @{
        Message = '' # (as String)
        ComputerName = [System.Net.Dns]::GetHostByName($env:computerName).HostName # FQDN !!
        EventSource = $EventSource.Trim()
        MyCommand = $MyInvocation.MyCommand.Name #(InvocationInfo.MyCommand)
        ScriptName = $MyInvocation.ScriptName  #(InvocationInfo.ScriptName)
        ScriptLineNumber = $MyInvocation.ScriptLineNumber #(InvocationInfo.ScriptLineNumber)
        OffsetInLine = $MyInvocation.OffsetInLine #(InvocationInfo.OffsetInLine)
        DateGenerated = $Now.ToString('yyyy-MM-dd')
        TimeGenerated = $Now.ToString('HH:mm:ss.fff')
        Severity = $Severity  #(ListOf[String])
        Tags = $Tags #(ListOf[String])
        User = "$env:UserName.$env:UserDnsDomain" # FQDN or NT [System.Security.Principal.WindowsIdentity]::GetCurrent()
        ProcessName = [System.Diagnostics.Process]::GetCurrentProcess().Name
        ProcessPath = [System.Diagnostics.Process]::GetCurrentProcess().Path
        ProcessId = [System.Diagnostics.Process]::GetCurrentProcess().Id
        NativeThreadId = $Null  #(pInvoke)???
        ManagedThreadId = [Threading.Thread]::CurrentThread.ManagedThreadId
      }

        # FilePath and LiteralPath are not mandatory we set the default here
        If([String]::IsNullOrEmpty(($FilePath).Trim()) -and [String]::IsNullOrEmpty(($LiteralPath).Trim())) {
          # create the Logfilepath (Fullname) to the path of the current Script and current scriptname + extension .log
          # Powershell version shim
          If($PSVersionTable.PSVersion.Major -ge 3) {
            # using the $PSCommandPath which is introduced with PowerShell 3.0
            $LogFileName = "$(Split-Path -Path $PSCommandPath -Leaf).log" # get current scriptname + extension .log
            $LogFilePath = $PSScriptRoot # get current script path
          } Else {
            # using PowerShell 2.0 alternative
            $LogFileName = "$(Split-Path -Path $MyInvocation.PSCommandPath).log" # get current scriptname + extension .log
            $LogFilePath = (Split-Path -parent $MyInvocation.MyCommand.Definition) # get current script path
          }

          $PSBoundParameters.FilePath =  Join-Path -Path $LogFilePath -ChildPath $LogFileName
        }

        # process the Inputobject by type
        switch ($InputObject) {

          {$InputObject -is [System.Management.Automation.ErrorRecord]} {
            $LogHash.Severity = 'Error'
            $LogHash.Message = $InputObject.Exception.Message
            $LogHash.ScriptName = $InputObject.InvocationInfo.ScriptName
            $LogHash.ScriptLineNumber = $InputObject.InvocationInfo.ScriptLineNumber
            $LogHash.OffsetInLine = $InputObject.InvocationInfo.OffsetInLine

            # add new key value pair to $LogHash
            $LogHash['ErrorID'] = $InputObject.FullyQualifiedErrorId

            # if user has not given an event source
            # set the eventsource with source of the ErrorRecord Object
            If(([String]::IsNullOrEmpty($LogHash.EventSource)) -and (-Not [String]::IsNullOrEmpty(($InputObject.InvocationInfo.ScriptName).Trim()))){
              $LogHash.EventSource = $InputObject.InvocationInfo.ScriptName
            }
            break
          }

          {$InputObject -is [System.Management.Automation.InformationRecord]} {

            $LogHash.Severity = 'Information'
            $LogHash.Message = $InputObject.MessageData.ToString()
            $LogHash.ScriptName = $InputObject.InvocationInfo.ScriptName
            $LogHash.ScriptLineNumber = $InputObject.InvocationInfo.ScriptLineNumber
            $LogHash.OffsetInLine = $InputObject.InvocationInfo.OffsetInLine

            # add new key value pair to $LogHash
            $LogHash['Tags'] = $InputObject.MessageData.Tags -join ','

            $LogHash.ComputerName = $InputObject.Computer
            $LogHash.ManagedThreadId = $InputObject.ManagedThreadId
            $LogHash.NativeThreadId = $InputObject.NativeThreadId
            $LogHash.ProcessId = $InputObject.ProcessId
            $LogHash.User = $InputObject.User

            # if user has not given an event source -and source ist not text of 'Write-Information'
            # set the Eventsource with source of InformationRecord Object
            If((-Not [String]::IsNullOrEmpty(($EventSource).Trim())) -and ($InputObject.Source -ine 'Write-Information')){
              $LogHash.ScriptName = $InputObject.Source
            }

            # adopt the datetime from the InformationRecord object
            $Now = $InputObject.TimeGenerated
            break
          }

          {$InputObject -is [System.Management.Automation.WarningRecord]} {

            $LogHash.Severity = 'Warning'
            $LogHash.Message = $InputObject.Message
            $LogHash.ScriptName = $InputObject.InvocationInfo.ScriptName
            $LogHash.ScriptLineNumber = $InputObject.InvocationInfo.ScriptLineNumber
            $LogHash.OffsetInLine = $InputObject.InvocationInfo.OffsetInLine

            # add new key value pair to $LogHash
            $LogHash['WarningID'] = $InputObject.FullyQualifiedWarningId
            break
          }



          {$InputObject -is [System.Management.Automation.VerboseRecord]} {

            $LogHash.Severity = 'Verbose'
            $LogHash.Message = $InputObject.Message
            $LogHash.ScriptName = $InputObject.InvocationInfo.ScriptName
            $LogHash.ScriptLineNumber = $InputObject.InvocationInfo.ScriptLineNumber
            $LogHash.OffsetInLine = $InputObject.InvocationInfo.OffsetInLine

            break
          }

          {$InputObject -is [System.Management.Automation.DebugRecord]} {

            $LogHash.Severity = 'Debug'
            $LogHash.Message = $InputObject.Message
            $LogHash.ScriptName = $InputObject.InvocationInfo.ScriptName
            $LogHash.ScriptLineNumber = $InputObject.InvocationInfo.ScriptLineNumber
            $LogHash.OffsetInLine = $InputObject.InvocationInfo.OffsetInLine

            break
          }

          # by default we convert the InputObject to a string because output is a text file
          # user can choose
          Default {

            # using the .ToString() Method of the Object
            $LogHash.Message = $InputObject.ToString()
          }
        }

        <#
          if you have servers spread across multiple timezones,
          all your event timestamps MUST be transported in UTC time (as String)
          this UTC MUST be calculated by the sender system and
          cannot be calculated by the receiver system.
          Because only the sender knows his locale timezone setting
          create the time as UTC formated string (Trace32 / CMTrace format)
        #>
        $UtcOffset = [System.TimeZoneInfo]::Local.GetUtcOffset($Now)

        # create UTC time string
        IF($UtcOffset -lt 0 ) {
          $LogHash.TimeGenerated = '{0}{1}{2}' -f $Now.ToString('HH:mm:ss.fff'), '-', $UtcOffset.TotalMinutes
        } Else {
          $LogHash.TimeGenerated = '{0}{1}{2}' -f $Now.ToString('HH:mm:ss.fff'), '+', $UtcOffset.TotalMinutes
        }

        # create Date String
        $LogHash.DateGenerated = $Now.ToString('yyyy-MM-dd')

        <#
          Trace32.exe and CMTrace.exe are using Numbers for the $Severity
          Numbers are easier to maintain, so we map $Severity to Numbers

          LevelNumber
            1 - Information
            2 - Warning
            3 - Error
        #>
        $SeverityNumber = 0

        switch ($LogHash.Severity) {
          {($_ -like 'Err*') -or ($_ -eq 'Fatal') -or ($_ -eq 'Critical')} {$SeverityNumber = 3 ; Break}
          {$_ -like 'Warn*' } {$SeverityNumber = 2 ; Break}
          {($_ -like 'Info*') -or ($_ -eq 'Verbose') -or ($_ -eq 'Debug') -or ($_ -eq 'Dbg')}   {$SeverityNumber = 1}
        }

        # to give severity words like 'Fatal' or 'Critical' and other, the possibility to use the Write-xxx cmdlets
        # we (re)write the Message to the PowerShell Streams, with help of the Write-xxx cmdlets here
        if (-not $NoStreamReWriting.IsPresent) {
          switch ($SeverityNumber) {
            3 {
                If ($InputObject -is [System.Management.Automation.InformationRecord]) {
                  Write-Error -ErrorRecord $InputObject
                } Else {
                  Write-Error -Message $LogHash.Message
                }
                Break
              }
            2 {Write-Warning $Message ; Break}
            {($_ -eq 1) -and (($LogHash.Severity -eq 'Debug') -or ($LogHash.Severity -eq 'Dbg'))} {Write-Debug $Message -Debug ; Break}
            {($_ -eq 1) -and ($LogHash.Severity -eq 'Verbose')} {Write-Verbose $Message -Verbose ; Break}
            {($_ -eq 1) -and ($LogHash.Severity -like 'Info*')} {
              If($InputObject -is [System.Management.Automation.InformationRecord]) {
                # using the Write-Information cmdlet which is intoduced with PowerShell 5.0
                Write-Information -MessageData $InputObject.MessageData -Tags $InputObject.Tags
              } Else {
                # using Write-Host to output
                Write-Host -Object $Message
              }
            }
          }
        }

        # if the Eventsource is empty we create it as an string like an path to the eventsource
        If ([String]::IsNullOrEmpty(($LogHash.EventSource).Trim())) {
          $LogHash.EventSource = "$($LogHash.User)\$($LogHash.ComputerName)\$($LogHash.ScriptName)\$($LogHash.MyCommand)\$($LogHash.ScriptLineNumber)\$($LogHash.OffsetInLine)"
        }

        # create the output as string by choosen outputformat
        switch($MessageFormat) {

          'Plain' {$Msg = '{0}{1}' -f (' ' * $Indent),$LogHash.Message}

          'VerbosePlain' {$Msg = '{0}[{1}T{2}] [{3}] [{4}] [{5}]' -f (' ' * $Indent), $LogHash.DateGenerated, $LogHash.TimeGenerated, $LogHash.Severity, $LogHash.Message, $LogHash.EventSource}

          {$_ -eq 'Trace32' -or $_ -eq 'CMTrace'} {

            $LogLineArr = (' ' * $Indent),
                          "<![LOG[$($LogHash.Message)]LOG]!>",
                          "<time=`"$($LogHash.TimeGenerated)`" ",
                          "date=`"$($Now.ToString('M-d-yyyy'))`" ",
                          "component=`"$($LogHash.Eventsource)`" ",
                          "context=`"$($LogHash.User)`" ",
                          "type=`"$SeverityNumber`" ",
                          "thread=`"$($LogHash.ManagedThreadId)`" ",
                          "file=`"`">"

            $Msg = $LogLineArr -join ''

          }

          'JSON' {
            If($PSVersionTable.PSVersion.Major -lt 3) {
              $PSCmdlet.WriteError("JSON only Supported since PowerShell Version 3.0 you are Using PowerShell Version $($PSVersionTable.PSVersion.ToString())")
            } Else {
              $Msg = ConvertTo-Json -InputObject (New-Object -TypeName 'System.Management.Automation.PSObject' -ArgumentList $LogHash)
            
            }
          }

          'XML' {
            $Msg = ConvertTo-Xml -NoTypeInformation -As 'String' -InputObject (New-Object -TypeName 'System.Management.Automation.PSObject' -Property $LogHash) 
          }

        }

      # clone $PSBoundParameters and add only the parameters from the origin command, to prevent parameter not known errors
      $OriginCommandParameters.Clear()
      ForEach($Key in $PSBoundParameters.Keys) {
          # test if the parameter name is a member of the origin command
          If($OriginParamList -contains $Key) {
              # parameter is member of the origin command
              # add parameter to the parameter-dictionary clone
              $OriginCommandParameters.Add($Key,$PSBoundParameters.$Key)
          }
      }

      # replce the inputObject with the text to write
      $OriginCommandParameters['InputObject'] = $Msg
      $OriginCommandParameters.ErrorAction = 'Stop'

      Microsoft.PowerShell.Utility\Out-File @OriginCommandParameters

    } catch {
      $PSCmdlet.WriteError(($Error[0]))
    }
  }

  End {}
}
