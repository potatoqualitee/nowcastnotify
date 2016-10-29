# Show-Nowcast
This command creates a NotifyIcon which displays the current nowcast from Nate Silver/ESPN's [fivethirtyeight.com](https://fivethirtyeight.com)

By default, the NotifyIcon will poll fivethirtyeight.com every 10 minutes and displays a popup if (and only if) there is a change in percentage.

You can change the default polling by specifying -Interval (in minutes).

If you click on the icon, it will bring you directly to the fivethirtyeight nowcast page.

I also compiled the script into an .exe if you're interested. Check the .bin directory.

Screenshots
--------------
When you start the command from PowerShell, you get a lil splash screenshots/executable

![starting](https://github.com/ctrlbold/nowcastnotify/blob/master/screenshots/starting.png?raw=true)

Then, the PowerShell window will disappear and you'll see a toast popup telling you the current nowcast.

![initialpopup](https://github.com/ctrlbold/nowcastnotify/blob/master/screenshots/initialpopup.png?raw=true)

If you hoover over at any time, you can be reminded of the nowcast.

![hoover](https://github.com/ctrlbold/nowcastnotify/blob/master/screenshots/hoover.png?raw=true)

Was there a change in percentage in the last 10 minutes? The popup will let you know!

![changepopup](https://github.com/ctrlbold/nowcastnotify/blob/master/screenshots/changepopup.png?raw=true)

Examples
--------------
This is a script so just run it like a script (.\Show-NowCast or .\Show-NowCast.ps1). Note that the PowerShell window will disappear but the PowerShell process will still be running.


    .\Show-NowCast

The above example creates a popup to which displays the current election nowcast for the President of the United States. Note that the PowerShell window will disappear.

Checks fivethirtyeight.com every 10 minutes and displays a popup if (and only if) there is a change in percentage.


    .\Show-NowCast -Interval 60

The above example creates a popup to which displays the current election nowcast for the President of the United States. Note that the PowerShell window will disappear.

Checks fivethirtyeight.com every 60 minutes and displays a popup if (and only if) there is a change in percentage.
  
    .\Show-NowCast -Verbose -ShowWindow

The above example keeps the PowerShell window open and shows what is happening in the background

To Quit
--------------
Right click, Exit

Bonus
--------------
Don't want to execute PowerShell? Whatever, here's an exe compiled directly from the ps1 using PowerShell Studio.

![executable](https://github.com/ctrlbold/nowcastnotify/blob/master/screenshots/executable.png?raw=true)
