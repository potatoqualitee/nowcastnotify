<#
.SYNOPSIS
This command creates a NotifyIcon which displays the current nowcast from Nate Silver/ESPN's fivethirtyeight.com

.DESCRIPTION
By default, this program will poll fivethirtyeight.com every 10 minutes and displays a popup if (and only if) there is a change in percentage.
	
.PARAMETER Interval
Interval check in minutes

.PARAMETER ShowWindow
Keep the PowerShell Window open. Use it with Verbose.
	
.NOTES 
Copyright (C) 2016 Chrissy LeMaire
Version 0.0.3

.LINK
https://github.com/ctrlbold/nowcastnotify

.EXAMPLE
.\Show-NowCast

Creates a popup to which displays the current election nowcast for the President of the United States. Note that the PowerShell window will disappear.

Checks fivethirtyeight.com every 10 minutes and displays a popup if (and only if) there is a change in percentage.

.EXAMPLE
.\Show-NowCast -Interval 60

Creates a popup to which displays the current election nowcast for the President of the United States. Note that the PowerShell window will disappear.

Checks fivethirtyeight.com every 60 minutes and displays a popup if (and only if) there is a change in percentage.

.EXAMPLE   
.\Show-NowCast -Verbose -ShowWindow

Shows what is happening in the background

#>
[CmdletBinding()]
Param ([switch]$ShowWindow,
	[int]$Interval = 10)

BEGIN
{
	try { Add-Type -AssemblyName PresentationFramework, System.Windows.Forms }
	catch { throw "Failed to load Windows Presentation Framework assemblies." }
	
	function New-Runspace
	{
		$scriptblock = {
			
			#  to prevent errors with Invoke-WebRequest after a few successful times ¯\_(?)_/¯ 
			[System.GC]::Collect()
			
			try
			{
				$html = Invoke-WebRequest -Uri "http://projects.fivethirtyeight.com/2016-election-forecast/"
				
				$polldate = ($html.ParsedHtml.getElementsByTagName('h5') | Where-Object { $_.className -eq 'poll-group-date' } | Select-Object -First 1).innerText
				$clinton = ($html.ParsedHtml.getElementsByTagName('span') | Where-Object { $_.className -eq 'candidate D' } | Select-Object -First 1).innerText
				$trump = ($html.ParsedHtml.getElementsByTagName('span') | Where-Object { $_.className -eq 'candidate R' } | Select-Object -First 1).innerText
			}
			catch
			{
				Write-Verbose $_
				return
			}
			
			$results = [PSCustomObject]@{
				PollDate = $polldate # Couldn't figure out where to put it.
				Clinton = $clinton -Replace 'Clinton '
				Trump = $trump -Replace 'Trump '
				Popuptext = "$clinton   $trump"
			}
			return $results
		}
		
		$runspace = [PowerShell]::Create()
		$null = $runspace.AddScript($scriptblock)
		return $runspace
	}
	
	function Get-Results
	{
		Write-Verbose "Cleaning some garbage"
		#  to prevent errors with Invoke-WebRequest after a few successful times ¯\_(?)_/¯ 
		[System.GC]::Collect()
		
		Write-Verbose "Creating runspace"
		$runspace = New-Runspace
		$status = $runspace.BeginInvoke()
		
		Write-Verbose "Waiting for runspace to complete"
		while ($status.IsCompleted -ne $true) { }
		
		$date = Get-Date
		Write-Verbose "Runspace complete at $date"
		$tempnew = $runspace.EndInvoke($Status)
		$runspace.Dispose()
		
		# Sometimes it breaks -- actually, not so much since garbage collection
		if ($tempnew.Popuptext -eq $null)
		{
			Write-Verbose "The request did not complete."
			return
		}
		
		Write-Verbose $tempnew.Popuptext
		
		Write-Verbose "Setting variables"
		$script:old = $script:new
		$script:new = $tempnew
		$script:popuptext = $tempnew.Popuptext
		
		if ($script:old -ne $null)
		{
			if ($script:new.Clinton -eq $script:old.Clinton)
			{
				Write-Verbose "No change"
			}
			else
			{
				Write-Verbose "There's been a change"
				
				if ($script:new.Clinton -gt $script:old.Clinton)
				{
					$oldpercent = $script:old.Clinton -replace '\%'
					$newpercent = $script:new.Clinton -replace '\%'
					$edge = [math]::round($newpercent - $oldpercent, 2)
					$title = "Clinton edged up by $edge%"
				}
				
				if ($script:new.Trump -gt $script:old.Trump)
				{
					$oldpercent = $script:old.Trump -replace '\%'
					$newpercent = $script:new.Trump -replace '\%'
					$edge = [math]::round($newpercent - $oldpercent, 2)
					$title = "Trump edged up by $edge%"
				}
				
				Write-Verbose "Showing popup with title $title"
				$notifyicon.ShowBalloonTip($null, $title, $tempnew.Popuptext, [System.Windows.Forms.ToolTipIcon]"None")
			}
		}
	}
}

PROCESS
{
	Write-Output "Please wait one moment while we perform the initial population of data"
	Write-Output "
  |* * * * * * * * * * OOOOOOOOOOOOOOOOOOOOOOOOO|
  | * * * * * * * * *  OOOOOOOOOOOOOOOOOOOOOOOOO|
  |* * * * * * * * * * OOOOOOOOOOOOOOOOOOOOOOOOO|
  | * * * * * * * * *  OOOOOOOOOOOOOOOOOOOOOOOOO|
  |* * * * * * * * * * OOOOOOOOOOOOOOOOOOOOOOOOO|
  | * * * * * * * * *  OOOOOOOOOOOOOOOOOOOOOOOOO|
  |* * * * * * * * * * OOOOOOOOOOOOOOOOOOOOOOOOO|
  |OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|
  |OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|
  |OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|
  |OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|
  |OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|
  |OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|
  |OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|

"
	Get-Results
	
	# Create a streaming image by streaming the base64 string to a bitmap streamsource
	$base64 = "iVBORw0KGgoAAAANSUhEUgAAABIAAAAPCAIAAABm5AhFAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAHBhaW50Lm5ldCA0LjAuNWWFMmUAAAEnSURBVDhPlZHNasJAEID3UXr1B4ngxVNzMWDjwR6kKPakIh6q0EvFXgIGchZ8hF4KpVAofao2uzO7Wa+duEFNY0iFb5dhZmc+hmVXN0EeL4zlEbfd+19ZKL/bbs+w2Rzb7rzP2+cP9+ndeXy7fng1bUrJPSglIgKAAOBaRwVtOgj0eh2tVmqxkJOJHAyw2y220WCtVRQZISCSTfzD5vva86LlUs3ncjyW/f5fWxbKn+xGqsxueajZTE2ncjSSwyH2etjpgOMkNjo0gPMfzkMhQppHU2mNU4yHqkRio0O/wctlUa+LZhNsG1otaLfRdWk83RTHGdumqmg0UrYw/DbstYnZQLFJmgdpW6l0pFrltZqwrNhvWRTzSuVQOm8rJGW7gIPtYhj7BXRB0Q6rANe7AAAAAElFTkSuQmCC"
	$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
	$bitmap.BeginInit()
	$bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64)
	$bitmap.EndInit()
	$bitmap.Freeze()
	
	# Convert the bitmap into an icon
	$image = [System.Drawing.Bitmap][System.Drawing.Image]::FromStream($bitmap.StreamSource)
	$icon = [System.Drawing.Icon]::FromHandle($image.GetHicon())
	
	# Create notifyicon, and right-click -> Exit menu
	$notifyicon = New-Object System.Windows.Forms.NotifyIcon
	$menuitem = New-Object System.Windows.Forms.MenuItem
	$menuitem.Text = "Exit"
	$notifyicon.Icon = $icon
	
	$contextmenu = New-Object System.Windows.Forms.ContextMenu
	$notifyicon.ContextMenu = $contextmenu
	$notifyicon.contextMenu.MenuItems.AddRange($menuitem)
	
	# When Exit is clicked, close everything and kill the PowerShell process
	$menuitem.add_Click({
			$notifyicon.Visible = $false
			Stop-Process $pid
		})
	
	# Show window when the notifyicon is clicked with the left mouse button
	# Recall that the right mouse button brings up the contextmenu
	$notifyicon.add_Click({
			if ($_.Button -eq [Windows.Forms.MouseButtons]::Left)
			{
				Start-Process "http://projects.fivethirtyeight.com/2016-election-forecast/"
			}
		})
	
	$notifyicon.add_BalloonTipClicked({
			Start-Process "http://projects.fivethirtyeight.com/2016-election-forecast/"
		})
	
	$notifyicon.Text = $script:popuptext
	$notifyicon.Visible = $true
	$notifyicon.ShowBalloonTip($null, "538 Nowcast - Who will be President?", $script:popuptext, [System.Windows.Forms.ToolTipIcon]"None")
	
	$timer = New-Object System.Windows.Forms.Timer
	$timer.Interval = $Interval * 60 * 1000
	$timer.add_Tick({
			Get-Results
			$notifyicon.Text = $script:popuptext
		})
	
	if ($ShowWindow -eq $false)
	{
		# Make PowerShell Disappear
		$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
		$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
		$null = $asyncwindow::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 0)
	}
	
	# Force garbage collection just to start slightly lower RAM usage.
	[System.GC]::Collect()
	$timer.start()
	
	# Create an application context for it to all run within.
	$appContext = New-Object System.Windows.Forms.ApplicationContext
	[void][System.Windows.Forms.Application]::Run($appContext)
}