# PowerLogging
Universal approach to PowerShell event Logging

Iam an simple minded Windowes Administrator and I like simply logging to a file very much. 
Since the first release of PowerShell 2.0 I searched an universal, non module approach to simple log PowerShell events.

Because it is not allways possible to transport and load a module with a script,
non Mudule means that I want to use PowerShell buildin processing instead of loading an additional module.
IMy desire is to (re)use the events created by the Write-xxx cmdlets to do a simple Logfile or other consumer.

Now I think I found one. Ugly but needful for daily use in quick n dirty admin scripts.

## Logging

In computing, a logfile (or simply log) is a file that records either the events which happen while an operating system or other software runs. (Excerpt: http://en.wikipedia.org/wiki/Logfile)

Logging can even be done with Databases or other Log-Event consumer like Unix / Linux syslog, Rsyslog, Windows Event Log or on Apple McOs the unified logging system.

## Parts of a data log-entry

A log message without context information is often as useful as no log message at all!
The properties of an log-entry should answer the following questions: What? , When? , Where?, Who?, Importance?
So every log-entry consist of common parts

- Text description of the event ; called Message
- weighting of the event (importance) ; called severity
- Time and date ; called TimeStamp
- Locality ; called Source

## Further logging needs

- A log-entry MUST logged persistence and collected to go back in History
- A log-entry must be able to send to different consumers (listener)
- A log-entry needs a Record medium (write target)
- A log-entry needs an uniform structure and format of the data
- the structure and format of the data should be human AND machine readable
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

#### Inconsistent object design!

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

Look into my Tee-StreamRecord.ps1 Function and you get a clou how Powerfull redirection is.

Tee-StreamRecord can be used in the middle of the Pipeline or at the End.
It can be used to filter Stream Objects, Log them to annywhere or do ANY other processing to them!

# A special Out-Logfile function

The Story goes then on with the Out-Logfile.ps1 Function ;-)

Export the stream record object into a Text Logfile in various formats

- Plain (Text message only)
- VerbosePlain
- Trace32 or CMTrace
- JSON
- XML

Put the Out-Logfile on top of your script instead of loading a module and by happy with Textfile Logging.

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
