# Simplified Miscreated Server Setup
This simplified startup process will prompt you for some basic server variables (server name, max number of players, RCON password, and whether or not to enable the whitelist), store the variables for later use, download `steamcmd.exe` from Valve, use `steamcmd.exe` to download and install the Miscreated server, download upnpc from the MiniUPnP Project to automatically open the requisite firewall ports, and finally start the server process using the configure variables.

This script has only been tested on Windows 10 v1809
## Scary stuff
The script (see below) will download executable binaries *from the Internet*. These include:
 * `steamcmd.exe`, from [Valve](https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip)
 * `upnpc`, from the [MiniUPnP Project](http://miniupnp.tuxfamily.org/files/download.php?file=upnpc-exe-win32-20150918.zip)

`steamcmd.exe` is used to download and update the Miscreated server. `upnpc` is used to automatically forward firewall ports to your Miscreated server instance.

The script also leverages PowerShell to unzip the executables downloaded.

## Installation steps
1. Right-mouse-click and save this script to your system (*Save link as...*): [start_server.cmd](https://raw.githubusercontent.com/Spafbi/MyGameSettings/master/Miscreated/start_server.cmd)
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
The server in this configuration uses a port range of 64090-64094. This script makes use of UPnP features available on most routers and *should* automatically forward the correct ports to your server, but only if you choose to allow it. If you do not choose to allow automatic port forwarding then you will need to manually forward firewall ports to your server. You will need to forward 64090-64094 for both TCP and UDP.

## Connecting to your server to play
A few minutes after starting up you should be able to see your server in the Miscreated server browser. If you cannot see your server it is likely a local network configuration is not fully compatible with UPnP.

If the ports were not automatically opened for you, then you will need to figure out how to open them if you wish for others to be able to play on your server. If you don't care about this and just want to play by yourself, then you will need to launch Miscreated using the +connect switch. To do this, you will need to locate your Miscreated.exe binary. Press WIN+R (Windows key and R at the same time) to open the run dialog. Use `Browse` to locate the Miscreated.exe executable; this is often located in `C:\Program Files\Steam\steamapps\common\Miscreated`, but may be located elsewhere on your system. Once you find the executable, select it and click `Open`. The full path to the Miscreated.exe file will now be listed on the `Open` line of the run dialog. After `Miscreated.exe` add ` +connect 127.0.0.1`. The `Open` line should now look similar to this:
```
C:\Program Files\Steam\steamapps\common\Miscreated\Miscreated.exe +connect 127.0.0.1
```
Click `OK` and you will join to your local server.
### But what if server is on another computer on my network and my ports were't forwarded?
In that case, you would simply need to change `127.0.0.1` in the above example to the IP address of other computer running the server. If the other computer's IP address is `192.168.1.103`, then you would change the above example to look like this:
```
C:\Program Files\Steam\steamapps\common\Miscreated\Miscreated.exe +connect 192.168.1.103
```
## Manually removing the UPnP port mappings
If you wish to ensure the UPnP port mappings are removed after closing your server, execute the `remove_upnp.cmd` file which was automatically created in the same directory as the `start_server.cmd` file.
