param (
	[switch]$Start,
	[switch]$End,
	[string]$Step,
	[switch]$Initial,
	[switch]$Final,
	[switch]$SaveChart
)
$oTSEnv = New-Object -ComObject Microsoft.SMS.TSEnvironment

If (Test-Path ('{0}\Durations.json' -f $oTSEnv.Value("LogPath")))
{
    $oDurations = Get-Content ('{0}\Durations.json' -f $oTSEnv.Value("LogPath")) | ConvertFrom-Json
} else {
    $oDurations = New-Object psobject
}

$iOffset = "{0:zz}" -f (get-date)
$sLogFile = $oTSEnv.Value("LogPath") + "\Durations.log"
$dtCurrentTimeUTC = (Get-Date).ToUniversalTime()

If ($Initial)
{
	$sCurrentTime = ($dtCurrentTimeUTC).AddHours($iOffset)
	$sFormattedDate = get-date $sCurrentTime -f "dd-MM-yyyy @ hh:mm:ss"
	$oTSEnv.Value("StopwatchInitial") = $sCurrentTime

	Add-Content -Path $sLogFile -Value "*******************************************************************"
	Add-Content -Path $sLogFile -Value ('Start Time Stamp: {0}' -f $sCurrentTime)
	Add-Content -Path $sLogFile -Value ('Starting the "{0}" Task Sequence...' -f $oTSEnv.Value("TaskSequenceName"))
	$oDurations | Add-Member @{ts_start = $sFormattedDate;comp_name = $oTSEnv.Value("OSDComputerName");}
	$oDurations | ConvertTo-Json | Out-File ('{0}\Durations.json' -f $oTSEnv.Value("LogPath"))
}
If ($Start)
{
	$sCurrentTime = ($dtCurrentTimeUTC).AddHours($iOffset)
	$oTSEnv.Value("StopwatchStart") = $sCurrentTime
}
If ($End)
{
	$sCurrentTime = ($dtCurrentTimeUTC).AddHours($iOffset)
	$sFormattedDate = get-date $sCurrentTime -f "dd-MM-yyyy @ hh:mm:ss"
	$sFormattedStartTime = get-date $oTSEnv.Value("StopwatchStart") -f "dd-MM-yyyy @ hh:mm:ss"
	$sTimeDiffSeconds = [math]::Round((New-TimeSpan -Start $oTSEnv.Value("StopwatchStart") -End $sCurrentTime).TotalSeconds,2)
	$sTimeDiffMinutes = [math]::Round($sTimeDiffSeconds/60,2)
	$oDurations
	$aStepContent = @{
		$Step = @{
			start_time = $sFormattedStartTime;
			end_time = $sFormattedDate;
			duration_in_secs = $sTimeDiffSeconds;
			duration_in_mins = $sTimeDiffMinutes;
		}
	}
	$oDurations | Add-Member $aStepContent
	Add-Content -Path $sLogFile -Value ('**Finished the "{0}" task in {1} minutes...' -f $Step, $sTimeDiffMinutes)
	$oDurations | ConvertTo-Json | Out-File ('{0}\Durations.json' -f $oTSEnv.Value("LogPath"))
}
If ($Final)
{
	$sCurrentTime = ($dtCurrentTimeUTC).AddHours($iOffset)
	$sFormattedDate = get-date $sCurrentTime -f "dd-MM-yyyy @ hh:mm:ss"
	$sTimeDiffSeconds = [math]::Round((New-TimeSpan -Start $oTSEnv.Value("StopwatchInitial") -End $sCurrentTime).TotalSeconds)
	$sTimeDiffMinutes = [math]::Round($sTimeDiffSeconds/60,2)
	$oTSEnv.Value("StopwatchTotalMinutes") = $sTimeDiffMinutes

	Write-Host ('Not an Error: Finished the "{0}" task sequence in {1} minutes...' -f $oTSEnv.Value("TaskSequenceName"), $sTimeDiffMinutes)
	Add-Content -Path $sLogFile -Value ('Finished the "{0}" task sequence in {1} minutes...' -f $oTSEnv.Value("TaskSequenceName"), $sTimeDiffMinutes)
	Add-Content -Path $sLogFile -Value ('End Time Stamp: {0}' -f $sCurrentTime)
	Add-Content -Path $sLogFile -Value "*******************************************************************"
	$oDurations | Add-Member @{ts_duration_in_mins = $sTimeDiffMinutes;ts_duration_in_secs = $sTimeDiffSeconds;ts_end = $sFormattedDate}
	$oDurations | ConvertTo-Json | Out-File ('{0}\Durations.json' -f $oTSEnv.Value("LogPath"))

	If ($SaveChart)
	{
		$tmp = @{}
		$oDurations = Get-Content ('{0}\Durations.json' -f $oTSEnv.Value("LogPath")) | ConvertFrom-Json
		$i = 0
		$oDurations.psobject.Properties |
		? { $_.TypenameOfValue -eq "System.Management.Automation.PSCustomObject" } |
			% { 
				$tmp.Add($_.Name,$_.value.duration_in_mins)
				$i += $_.value.duration_in_mins
			}
		$per = $oDurations.ts_duration_in_mins-$i
		$tmp.add("Other", $per)

		Add-Type -AssemblyName System.Windows.Forms
		Add-Type -AssemblyName System.Windows.Forms.DataVisualization

		$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
		$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
		$Series = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
		$ChartTypes = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]

		$Series.ChartType = $ChartTypes::Pie
		$Chart.Series.Add($Series)
		$Chart.ChartAreas.Add($ChartArea)
		$Chart.Series['Series1'].Points.DataBindXY($tmp.Keys,$tmp.Values)
		$Chart.Width = 700
		$Chart.Height = 400
		$Chart.Left = 10
		$Chart.Top = 10
		$Chart.BackColor = [System.Drawing.Color]::White
		$Chart.BorderColor = 'Black'
		$Chart.BorderDashStyle = 'Solid'

		$ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
		$ChartTitle.Text = ('Duration Breakdown in Minutes for {0}' -f $oDurations.comp_name)
		$Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','14', [System.Drawing.FontStyle]::Bold)
		$ChartTitle.Font =$Font
		$Chart.Titles.Add($ChartTitle)
		
		$ChartTitle2 = New-Object System.Windows.Forms.DataVisualization.Charting.Title
		$ChartTitle2.Text = ('Total Deployment: {0} mins' -f $oDurations.ts_duration_in_mins)
		$Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','12', [System.Drawing.FontStyle]::Bold)
		$ChartTitle2.Font =$Font
		$Chart.Titles.Add($ChartTitle2)

		$Chart.Series['Series1']['PieLineColor'] = 'Black'
		$Chart.Series['Series1']['PieLabelStyle'] = 'Outside'
		$Chart.Series['Series1'].Label = "#VALX (#VALY)"

		$ChartArea.Area3DStyle.Enable3D=$True
		$ChartArea.Area3DStyle.Inclination = 50

		$Chart.SaveImage(('{0}\Durations.png' -f $oTSEnv.Value("LogPath")), 'png')
	}
}