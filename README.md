# Simplified Miscreated Server Setup
This simplified startup process will prompt you for some basic server variables (server name, max number of players, RCON password, and whether or not to enable the whitelist), store the variables for later use, download `steamcmd.exe` from Valve, use `steamcmd.exe` to download and install the Miscreated server, download upnpc from the MiniUPnP Project to automatically open the requisite firewall ports, and finally start the server process using the configure variables.

This script has only been tested on Windows 10 v1809 and v1903. If you're running an earlier version you may need to first manually install [curl for 64 bit](https://curl.haxx.se/windows/).

### Configurable options
When the script is run, it will prompt you to set the following values:
* Server name
* Maximum players supported by the server
* Default base game port
* RCON password
* Enable/Disable the whitelist option
* Enable/Disable automatic firewall port forwarding
* Enable/Disable automatic granting of all guides to players having joined since the last restart

### Extras
* `join_local_server.cmd` - This script is created to facilitate joining your new local server.
* `remove_upnp.cmd` - This script may be used to manually remove UPnP forwards created by the `start_server.cmd` script.

## Scary stuff
The script (see below) will download executable binaries *from the Internet*. These include:
 * `steamcmd.exe`, from [Valve](https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip)
 * `sqlite3`, from the [SQLite Consortium](https://www.sqlite.org/download.html)
 * `upnpc`, from the [MiniUPnP Project](http://miniupnp.tuxfamily.org/files/download.php?file=upnpc-exe-win32-20150918.zip)

`steamcmd.exe` is used to download and update the Miscreated server. `sqlite3` is used optionally to grant all guides to all players upon each server restart. `upnpc` is used to automatically forward firewall ports to your Miscreated server instance.

The script also leverages PowerShell to unzip the executables downloaded.

## Installation steps
1. Save this script to your system: [start_server.cmd](https://github.com/Spafbi/simplified-miscreated-server-setup/releases/download/v1.2b/start_server.cmd)
1. Create a folder where you would like to download and install the Miscreated server. It's best to keep the path to where you want to install the server short, with no spaces, and using only ASCII characters. Example: `C:\Games\MiscreatedServer`
1. Copy and paste the `start_server.cmd` file you downloaded to the folder you created in the preceding step.
1. Run the `start_server.cmd` file and answer any prompts which may appear. Necessary downloads will occur and the server will automatically start using the values you specified in the prompts. The server will automatically restart in the event it was shut down.

## Starting the server
Any time you wish to start the server after the first time, just execute the `start_server.cmd` file. It will use your previously entered values and start right up.

> Note:
> The server is ready for players to join once the ```[VoIP_Plugin] Starting VoIP Server 0.0.0.0 : 64093``` message is displayed

## Changing your original setup choices
The first time you started the server using the `start_server.cmd` the values you entered were saved in respective files in the `scriptvars` folder. If you wish to change any of the values, you may either edit the file directly, or delete the file. For example, to change your server's name, edit or delete the `scriptvars\server_name.txt` file.

## Firewall ports
The server in this configuration uses a default port range of 64090-64094. This script makes use of UPnP features available on most routers and *should* automatically forward the correct ports to your server, but only if you choose to allow it. If you do not choose to allow automatic port forwarding then you will need to manually forward firewall ports to your server. If using the default ports, you will need to forward 64090-64094 for both TCP and UDP, otherwise forward your chosen base port number through base port number + 4.

## Connecting to your server to play
A few minutes after starting up you should be able to see your server in the Miscreated server browser. If you cannot see your server it is likely a local network configuration is not fully compatible with UPnP.

If the ports were not automatically opened for you, then you will need to figure out how to open them if you wish for others to be able to play on your server. If you don't care about this and just want to play by yourself, a `join_local_server.cmd` script was created which you can execute to join your local server. This will open Steam and you will need to confirm you want to join the server.

### But what if server is on another computer on my network and my ports were't forwarded?
In that case, you will need to launch Miscreated using the +connect switch. To do this, you will need to locate your Miscreated.exe binary. Press WIN+R (Windows key and R at the same time) to open the run dialog. Use `Browse` to locate the Miscreated.exe executable; this is often located in `C:\Program Files\Steam\steamapps\common\Miscreated`, but may be located elsewhere on your system. Once you find the executable, select it and click `Open`. The full path to the Miscreated.exe file will now be listed on the `Open` line of the run dialog. After `Miscreated.exe` add ` +connect 192.168.1.103`. The `Open` line should now look similar to this:
```
C:\Program Files\Steam\steamapps\common\Miscreated\Miscreated.exe +connect 192.168.1.103
```
Be sure to change `192.168.1.103` to the internal network IP address of the computer running the Miscreated server.

***NOTICE*** if you have changed the base port number from the default you will need to add ` 12345` to the end of your connect string, substituting your base port number for the 12345 value.

## Manually removing the UPnP port mappings
If you wish to ensure the UPnP port mappings are removed after closing your server, execute the `remove_upnp.cmd` file which was automatically created in the same directory as the `start_server.cmd` file.
