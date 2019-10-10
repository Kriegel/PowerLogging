# PowerLogging

Universal approach to PowerShell event Logging

I am an simple minded Windows Administrator and I like the simple approach to log events to a file very much. 

Because it is not allways possible to transport and load a module with a script,
Since the first release of PowerShell 2.0 I searched an universal, non module approach to simple log PowerShell events.

Non Module means that I want to use PowerShell build in processing, instead of loading an additional module.
My desire is to (re)use the events, created by the Write-xxx cmdlets and the Writexxx Methods to write to a simple Logfile or to log to other consumer.

Now I think I found one solution,
with redirection of the PowerShell Streams to the success Stream and then Filter and process the different Objects produced by the Write-xxxx cmdlets / methods to the Streams.

Ugly but needful for daily use, in quick and dirty admin scripts.

## Logging

The term 'Logging' (or simply to log) in Computer sciences refers to the automated process in which information about an events an single action or simply one change of a single state is gathered from systems, processes and routines, and in which the information gathered is recorded to a store for a shorter or longer period as a list of items.

The data of the Logging can also be simply written to a secondary Interface which a Human is monitoring. The recorded list of items during Logging is called 'log' . A single item inside this log is called a 'log-entry' or 'log message' .

The process of Logging contains minimum a data source which initiates the Logging and generates and sends a message, and a data sink (destination) which receives and records the message data to the log store.
Source and sink can be the same device such as a Data logger.

In computing, a logfile is a data sink as a file that records the events.

Logging can even be done with Databases or other Log-Event consumer like Unix / Linux syslog or Rsyslog, Windows Event Log or on Apple macOS the unified logging system.

This Loggin approach addresses Windows, Unix / Linux and macOS.

## Parts of a data log-entry

A log message without context information is often as useful as no log message at all!
The properties of an log-entry should answer the following questions: What? , When? , Where?, Who?, Importance?
So every log-entry should consist of common data fields.

- Text description of the event ; called Message
- weighting of the event (importance) ; called severity
- Time and date ; called TimeStamp (in UTC string Format!)
- Locality ; called Source

### Other context parts of a log-entry

A developer has the need to debug or trace application events,
in computer security forensic the needs are other,
Monitoring or tracing may have the need to view or analyse the logged data in near real time.
So the parts of a log-entry may vary.
A log-entry cannot satisfy all demands and should be consistent.

For PowerShell events, reasonable additional data fields are:

- Computername (full DNS Name)
- Username (full DNS Name)
- ProcessName
- Path to processing Executeable
- Process ID
- ProcessThread ID
- PowerShell Command Name (from InvocationInfo Object)
- PowerShell ScriptPath Name (fullpath from InvocationInfo Object)
- PowerShell ScriptLineNumber (from InvocationInfo Object)
- PowerShell Offset in ScriptLine (from InvocationInfo Object)

most of this data fields can be processed into one event source path like so:

ComputerName\UserName\ScriptPath\CommandName\ScriptLineNumber\OffsetInLine\Processname\ProcessID\TreadID\ExecuteablePath

### Excursion : TimeStamp

Even if it call TimeStamp it contains Date and Time.
International enterprises have servers spread across multiple timezones.
So all your event timestamps MUST be transported in UTC time (as String)
This UTC MUST be calculated by the sender system and cannot be calculated by the receiver system.
Because only the sender knows his locale timezone setting and dailight savings
create the time as UTC formated string (Trace32 / CMTrace format)

I am using the UTC DateTime format of HH:mm:ss.mmm-+<UtcOffset.TotalMinutes>
Which can be created by PowerShell like so:

```powershell
$Now = Get-Date
"$($Now.ToString('HH:mm:ss.fff'))$([System.TimeZoneInfo]::Local.GetUtcOffset($Now).TotalMinutes.ToString('+0;-#'))"
```

## Further logging needs

- A log-entry MUST logged persistence and collected to go back in History (can be send simultaneously to an display to Monitor the event)
- A log-entry must be able to send to different consumers (listener)
- A log-entry needs a Record medium (write target)
- A log-entry needs an uniform structure and format of the data
- the structure and format of the data should be human AND machine readable (XML, JSON, other ...)
- the structure and format of the data must support filter helpers

## Creating events to log

### Message, Severity, Source and (Timestamp) with the PowerShell Write-xxx cmdlets

PowerShell has to offer the following the following cmdlets for different Severity levels.

- Write-Error
- Write-Warning
- Write-Debug
- Write-Verbose
- Write-Host
- Write-Progress
- Write-Output
- Write-Information (since PowerShell 5.0)

#### No Logging for Write-Output and Write-Progress at this time

Write-Output
If an operation is successful, Write-Output writes the normal Output to the stdOut Stream
Which is  the normal output.
This is tProcessed be every PowerShell cmdlet in the pipeline.
So you can do Logging with it very easy and many Cmdlets.
So Write-Output is not in Focus to this logging approach.

Write-Progress
Because Write-Progress cannot be catched easely and produces large amount of output,
Write-Progress is no cadidate for this logging aproach.

## Streams

The legacy processes and the shell CMD, and Unix shells like Bash, Ksh etc only deal with three streams: standard in (stdin), standard out  (stdout) and standard error (stderr) for Input, Ouput and Error output respectively.
Windows PowerShell has to offer the following streams which can be addressed by a Number:

|Number|Description|Introduced in|
|--------|-----------|-------------|
|1|Success Stream|PowerShell 2.0|
|2|Error Stream|PowerShell 2.0|
|3|Warning Stream|PowerShell 3.0|
|4|Verbose Stream|PowerShell 3.0|
|5|Debug Stream|PowerShell 3.0|
|6|Information Stream|PowerShell 5.0|
|*|All Streams|PowerShell 3.0|

The PowerShell input stream is bound to the stdin or to the scriptfile and is not considered here.

PowerShell is pushing data into these streams in 3 different ways:

- using the Cmdlets:  Write-Error, Write-Warning Write-Debug, Write-Verbose, Write-Host, Write-Progress, Write-Output
- Inside an advanced function which is using of the [Cmdletbinding()] attribute, the $PSCmdlet automatic variable exist as an object which has a type of  System.Management.Automation.PSScriptCmdlet. With this object you can use the following methods to push messages to the corresponding streams:

  - $PSCmdlet.WriteDebug()
  - $PSCmdlet.WriteError()
  - $PSCmdlet.WriteObject()
  - $PSCmdlet.WriteProgress()
  - $PSCmdlet.WriteVerbose()
  - $PSCmdlet.WriteWarning()

- All other Cmdlets developd in a .NET Language, can use their corresponding internal .writeXxxx() methods

### Objects in Streams

The success Stream can transport every type of .NET object.

The other streams are transporting only one type of .NET object.
Called the xxxRecord Objects.

|Stream Name|.NET Object Type of|
|-----------|-------------|
|Error Stream|System.Management.Automation.ErrorRecord|
|Warning Stream|System.Management.Automation.WarningRecord|
|Verbose Stream|System.Management.Automation.VerboseRecord|
|Debug Stream|System.Management.Automation.DebugRecord|
|Information Stream|System.Management.Automation.InformationRecord|

#### Inconsistent object design

WarningRecord, VerboseRecord, and DebugRecord are transporting only a String Message and
a InvocationInfo Object.
The InvocationInfo Object can be used to detekt the source of the event.

ErrorRecord is transporting an rich Object with many informations about

Sadly there is no DateTime into this Record Objects, to easy log the TimeStamp an event is occured.

InformationRecord has such a DateTime Stamp
And it Transports an Object as MessageData
And has other useful properties for logging.

InformationRecord has a Source as String which points to the running script.
Sadly InformationRecord has no InvocationInfo Object which has more useful Informations about the event source.

Sadly an inconsistent Object design ....
But we can tackle this.

## Redirect and catch the PowerShell streams

To process the stream-record objects by our self, we have to redirect the stream of our desire or all streams together to the success stream.

Therefor the PowerShell Team gave us the Redirection Operators.
See: about_Redirection
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection

# Log all PowerShell Streams with one Function

If you use the redirection Operator `*>&1` in combination with `Invoke-StreamRecordFilter`

Look into my 'Invoke-StreamRecordFilter.ps1' Function and you get a clou how Powerfull redirection is.

The Function can be used to filter the record stream Objects and to execute an scriptblock for each type of record Object so you can Log them to annywhere or do ANY other processing to them!

# A special Out-Logfile function

The Story goes then on with the `Out-Logfile` Function

If you use the redirection Operator `*>&1` with in combination with `Out-Logfile` it will export the stream record objects into a Text Logfile

 `Out-Logfile` supports various structured Text formats for the export

- Plain (Text message only)
- VerbosePlain
- Trace32 or CMTrace
- JSON
- XML

Put the `Out-Logfile` on top of your script instead of loading a module.
Call `| *>&1 Out-Logfile` at the end of your script and by happy with Textfile Logging.

Example to use Out-Logfile:

```powershell
# Sript to run
# Put it into curly brackets and add & Operator to run the script
& {
    Write-Output good
    Write-Error bad
    Write-Warning problematic
    Write-Verbose palaver -Verbose
    Write-Information NotImportand -InformationAction Continue

# Call to Out-Logfile after closing curly bracket with with redirection operator into pipeline
} *>&1 | Out-LogFile -FilePath 'C:\Logs\MyLogFile.log' -MessageFormat 'JSON' -NoStreamReWriting -Append
```

## See Also

about_Logging_Windows
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logging_windows

about_Logging_Non-Windows
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logging_non-windows

On Linux, PowerShell logs to syslog and rsyslog.conf For more information, see:
https://en.wikipedia.org/wiki/Syslog#Internet_standard_documents
https://www.rsyslog.com/doc/master/index.html

On macOS, the os_log logging system is used. For more information, see
https://developer.apple.com/documentation/os/logging
