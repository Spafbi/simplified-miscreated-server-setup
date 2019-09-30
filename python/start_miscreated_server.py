import argparse
import click
import inspect
import json
import msvcrt
import os
import random
import sqlite3
import subprocess
import sys
import time
import urllib.request as grabfile
import zipfile
from colorama import Fore, Back, Style, init, deinit
from pprint import pprint
from sortedcontainers import SortedDict


class MiscreatedServer():
    def __init__(self, **kwargs):
        # These are variables passed to the class
        self.bind = kwargs.get("bind", False)
        self.debug = kwargs.get("debug", False)
        self.grantguides = kwargs.get("grantguides", False)
        self.map = kwargs.get("map", False)
        self.maxplayers = kwargs.get("maxplayers", 36)
        self.path = kwargs.get("thisPath", './')
        self.port = kwargs.get("port", False)
        self.servername = kwargs.get("servername", False)
        self.serverPrefix = kwargs.get("serverPrefix", "server")
        self.whitelist = kwargs.get("whitelist", False)

        # These are derived variables
        srvPath = "{}/Servers".format(self.path)
        self.configsDir = "{}/Configs".format(self.path)

        self.mcDir = "{}/{}/MiscreatedServer". \
                     format(srvPath, self.serverPrefix)
        self.mcBinary = "{}/{}".format(self.mcDir,
                                       "Bin64_dedicated/MiscreatedServer.exe")

        self.steamDir = "{}/{}/SteamCMD".format(srvPath, self.serverPrefix)
        self.steamCmd = "{}/steamcmd.exe".format(self.steamDir)

        self.tempDir = "{}/temp".format(self.path)

        self.provision()

    def checkDirs(self):

        mcDirs = [self.configsDir, self.mcDir, self.steamDir, self.tempDir]

        for dir in mcDirs:
            self.createDirs(dir)

    def checkServerInstall(self):
        if not os.path.exists(self.mcBinary):
            self.installMiscreated()

    def checkSteam(self):
        if not os.path.exists(self.steamCmd):
            self.getSteamCMD()

    def createDirs(self, directory=False):
        if directory and not os.path.exists(directory):
            string = "{GREEN}Creating directory: [{WHITE}{DIR}{GREEN}]"
            displayDir = directory.replace('/', '\\')
            thisDict = {"DIR": displayDir}
            self.mcPrint(string, thisDict)
            os.makedirs(directory)

    def getSteamCMD(self):
        # This method simply installs steamcmd
        self.mcPrint("{GREEN}Downloading steamcmd...")
        url = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
        thisZip = "{0}/steamcmd.zip".format(self.tempDir)
        grabfile.urlretrieve(url, thisZip)
        with zipfile.ZipFile(thisZip, 'r') as tmpZip:
            tmpZip.extractall(self.steamDir)

    def installMiscreated(self):
        '''
        This method installs and updates the Miscreated server installation.
        It will be called on the first run of the application, and optionally
        each time the server is restarted.
        '''
        thisCmd = '"{STEAMCMD}" +login anonymous +force_install_dir ' \
                  '"{MCDIR}" +app_update 302200 validate +quit'
        thisCmd = thisCmd.format(STEAMCMD=self.steamCmd,
                                 MCDIR=self.mcDir).replace('/', '\\')
        thisCmd = thisCmd.split(' ')
        # This next line fixes steam passing each cmd arg w/o spacing
        thisCmd = [s + ' ' for s in thisCmd]
        subprocess.run(args=[thisCmd])

    def mcPrint(self, message, thisDict=dict()):
        colors = getColors()
        thisDict = {**colors, **thisDict}
        if self.debug:
            # init() and deinit() are called for colorizing output.
            init()
            print((message + Fore.RESET).format(**thisDict))
            deinit()


    def provision(self):
        # Create our running directories
        self.checkDirs()

        # Grab steamcmd if needed
        self.checkSteam()

        # Grab install the server if needed
        self.checkServerInstall()

def loadJSON(file=False):
    if not file or not os.path.exists(file):
        return dict()
    with open(file) as jsonFile:
        data = json.load(jsonFile)
    return data


def assignRandomizedServerName():
    randomPaddedInt = str(random.randint(1, 9999999)).zfill(7)
    servername = "Miscreated self-hosted server #{}".format(randomPaddedInt)
    return servername


def getDefaultConfig():
    config = {"baserules": 1,
              "bind": None,
              "debug": False,
              "grantguides": False,
              "map": "islands",
              "maxplayers": 36,
              "noupnp": False,
              "port": 64090,
              "prefix": "server",
              "rconpassword": None,
              "servername": assignRandomizedServerName(),
              "serverpassword": None,
              "whitelist": False
              }
    return config

def pressAnyKey(message='Huh...', timeout=5):
    # Returns true if any key is pressed.
    inp = None
    startTime = time.time()

    print(message)
    while True:
        if msvcrt.kbhit():
            inp = msvcrt.getch()
            break
        elif time.time() - startTime > timeout:
            break

    if inp:
        return True
    else:
        return False


# def getYN_old(**kwargs):
#     default = kwargs.get('default','n')
#     message = kwargs.get('message','n')
#     yn = "y/n".replace(default, default.upper())
#     try:
#             print('Would you like to change your answer? [{}]'.format(yn))
#             foo = raw_input()
#             return foo
#     except:
#             # timeout
#             return

def main():
    filename = inspect.getframeinfo(inspect.currentframe()).filename
    path = os.path.dirname(os.path.abspath(filename))
    path = path.replace('\\', '/')
    description = "Spafbi's Simplied Server Management Utility: All of the " \
                  "options below are optional as defaults will be used if " \
                  "not specified."
    parser = argparse.ArgumentParser(filename, description=description)
    parser.add_argument('--bind',
                        metavar='<x.x.x.x>',
                        type=str,
                        help="This is the IP address to which the server will "
                             "bind. NOTE: Almost all users will NOT need to "
                             "specify this unless they are hosting on multi-"
                             "homed systems and wish to specify on which "
                             "address the server will listen. TIP: If you "
                             "have to look up the meaning of 'multi-homed "
                             "system' then this option is probably not for "
                             "you.",
                        default=None)
    parser.add_argument('--baserules',
                        metavar='<int>',
                        type=int,
                        help='Defines basebuilding rules. 0=no bases, '
                             '1=normal build rules, 2=build anywhere - '
                             'default=1')
    parser.add_argument('--debug',
                        action='store_true',
                        help="Turns on debugging for this script.")
    parser.add_argument('--grantguides',
                        action='store_true',
                        help="Grant all crafting guides to new and existing "
                             "players. New players will need to rejoin to see "
                             "all crafting options.")
    parser.add_argument('--map',
                        metavar='<map_name>',
                        type=str,
                        help="The map name which to load - default: islands")
    parser.add_argument('--maxplayers',
                        metavar='<max_players>',
                        type=int,
                        help="The max number of players supported by this "
                             "server - max 50, default 36")
    parser.add_argument('-p', '--port',
                        metavar='<base_port>',
                        type=int,
                        help="The base game port of the server. It should be "
                             "noted the server will use that port in addition "
                             "to the next four. If you are running multiple "
                             "servers on the same network only then will you "
                             "want to change this value from the default. "
                             "Valid base ports are from 1024 through 65531 - "
                             "default 64090")
    parser.add_argument('--prefix',
                        metavar='<server_prefix>',
                        type=str,
                        required=False,
                        help="This will be used as a prefix for running "
                             "multiple servers. If running multiple servers "
                             "this option *must* be specified.")
    parser.add_argument('--rconpassword',
                        metavar='<rcon_password>',
                        type=str,
                        required=False,
                        help="The password for use with RCON",
                        default=None)
    parser.add_argument('-s', '--servername',
                        metavar='<server_name>',
                        type=str,
                        required=False,
                        help="This defines the name as seen by players in the"
                             "server browser")
    parser.add_argument('--serverpassword',
                        metavar='<server_password>',
                        type=str,
                        required=False,
                        help="The server password users will need to add to "
                             "their user.cfg to be able to join the server.",
                        default=None)
    parser.add_argument('--noupnp',
                        action='store_true',
                        help="By default UPnP will be used to automaticall "
                             "map ports from your network's gateway; use this "
                             "switch to disable use of UPnP")
    parser.add_argument('-w', '--whitelist',
                        action='store_true',
                        help="Whitelist the server requiring each player's "
                             "steamID64 to be added to the server's whitelist "
                             "prior to the user being able to join the server")

    args = parser.parse_args()

    cliConfig = dict()
    cliConfig['servername'] = args.servername
    cliConfig['bind'] = args.bind
    cliConfig['port'] = args.port
    cliConfig['map'] = args.map
    cliConfig['maxplayers'] = args.maxplayers
    cliConfig['rconpassword'] = args.rconpassword
    cliConfig['baserules'] = args.baserules
    cliConfig['debug'] = args.debug
    cliConfig['grantguides'] = args.grantguides
    cliConfig['noupnp'] = args.noupnp
    cliConfig['prefix'] = args.prefix
    cliConfig['serverpassword'] = args.serverpassword
    cliConfig['whitelist'] = args.whitelist

    # Load default config
    defaultConfig = getDefaultConfig()

    if cliConfig['prefix'] is not None:
        prefix = cliConfig['prefix']
    else:
        prefix = defaultConfig.get('prefix')

    # Load custom config
    svrConfig = loadJSON("{PATH}/Configs/{PREFIX}.json".format(PATH=path,
                                                               PREFIX=prefix))

    if svrConfig.get('firstrun', True):
        svrConfig['firstrun'] = True

    settings = reconcileSettings(cliConfig, defaultConfig, svrConfig)

    if cliConfig['debug']:
        print("\nCLI config settings:")
        pprint(cliConfig)
        print("\nDefault config settings:")
        pprint(defaultConfig)
        print("\nThis server's config settings "
              "(determined by the provided prefix):")
        pprint(svrConfig)
        print("\nReconciled settings:")
        pprint(settings)

    doAThing(settings)
    # printSettings(settings)

    # import tkinter as tk
    # root = tk.Tk()
    # root.title("Spafbi's Simplified Miscreated Server Utility")
    #
    # w = tk.Label(root, text=settings)
    #
    # icon = getIcon(path)
    #
    # root.iconbitmap(r'{}'.format(icon))
    # w.pack()
    #
    # root.mainloop()


def doAThing(settings=dict()):
    configStuff = {
        "baserules": {
            "desc": "Base-building rules",
            "type": "int",
            "values": {"0": "No bases",
                       "1": "Normal build rules",
                       "2": "Build anywhere"}
        },
        "bind": {
            "desc": "IP Binding",
            "type": "str"
        },
        "grantguides": {
            "desc": "Grant all guides",
            "type": "bool"
        },
        "map": {
            "desc": "Map",
            "type": "str"
        },
        "maxplayers": {
            "desc": "Max players",
            "type": "int"
        },
        "noupnp": {
            "desc": "Disable UPnP",
            "type": "bool"
        },
        "port": {
            "desc": "Base server port",
            "type": "int"
        },
        "prefix": {
            "desc": "Installation directory",
            "type": "str"
        },
        "rconpassword": {
            "desc": "RCON password",
            "type": "str"
        },
        "servername": {
            "desc": "Server name",
            "type": "str"
        },
        "serverpassword": {
            "desc": "Server password",
            "type": "str"
        },
        "whitelist": {
            "desc": "Enable whitelist",
            "type": "bool"
        }
    }
    for key, value in settings.items():
        info = configStuff.get(key)
        if info is None:
            continue
        desc = info.get("desc")
        valueDict = info.get("values", False)
        if valueDict:
            value = valueDict.get(str(value))
        color = "{LBLUE}"
        if value is None:
            value = "<unset>"
            color = "{GRAY}"
        value = "{COLOR}{VALUE}".format(COLOR=color, VALUE=value)
        value = value.format(**getColors())
        print("{DESC}: {VALUE}{RESET}". \
              format(DESC=desc, VALUE=value, **getColors()))


def buildAnywhereSettings(default=1):
    descDict = {0: "No bases",
                1: "Normal build rules",
                2: "Build anywhere"}
    description = "Base building rules may be set to one of the following\n" \
                  "  {LYELLOW}0{RESET} - No bases\n" \
                  "  {LYELLOW}1{RESET} - Normal build rules\n" \
                  "  {LYELLOW}2{RESET} - build anywhere".format(**getColors())
    current = "Base building rules: {LYELLOW}({DEF}) {YELLOW}{DESC}{RESET}". \
              format(DEF=default, DESC=descDict[default], **getColors())
    return description, current


def genericSettings(descDict, description, message, current):
    descDict = {0: "No bases",
                1: "Normal build rules",
                2: "Build anywhere"}
    description = "Base building rules may be set to one of the following\n" \
                  "  {LYELLOW}0{RESET} - No bases\n" \
                  "  {LYELLOW}1{RESET} - Normal build rules\n" \
                  "  {LYELLOW}2{RESET} - build anywhere".format(**getColors())
    current = "Base building rules: {LYELLOW}({DEF}) {YELLOW}{DESC}{RESET}". \
              format(DEF=default, DESC=descDict[default], **getColors())
    return description, current


def getColors():
    colors = {"BLACK": Fore.BLACK,
              "BLUE": Fore.BLACK,
              "CYAN": Fore.CYAN,
              "GRAY": Fore.LIGHTBLACK_EX,
              "GREEN": Fore.GREEN,
              "LBLUE": Fore.LIGHTBLUE_EX,
              "LCYAN": Fore.LIGHTCYAN_EX,
              "LGREEN": Fore.LIGHTGREEN_EX,
              "LMAGENTA": Fore.LIGHTMAGENTA_EX,
              "LRED": Fore.LIGHTRED_EX,
              "LWHITE": Fore.LIGHTWHITE_EX,
              "LYELLOW": Fore.LIGHTYELLOW_EX,
              "MAGENTA": Fore.MAGENTA,
              "RED": Fore.RED,
              "RESET": Fore.RESET,
              "WHITE": Fore.WHITE,
              "YELLOW": Fore.YELLOW}
    return colors


def getIcon(path=False):
    if not getIcon:
        return
    url = "https://miscreated.spafbi.com/favicon.ico"
    thisIcon = "{0}/favicon.ico".format(path)
    if not os.path.exists(thisIcon):
        grabfile.urlretrieve(url, thisIcon)
    return thisIcon


def mcPrint(message, thisDict=dict()):
    colors = getColors()
    thisDict = {**colors, **thisDict}
    # init() and deinit() are called for colorizing output.
    init()
    print((message + Fore.RESET).format(**thisDict))
    deinit()


# def printSettings(settings):
#     baseDesc = settings.get("bind", None)
#     if settings.get("bind", None) is None:
#         baseDesc = "{GRAY}<unset>{RESET}"
#     else:
#         baseDesc = "{LYELLOW}".settings.get("bind", None)."{RESET}"
#     baseSettings = {"description": "IP binding: {LYELLOW}{BIND}{RESET}",
#
#
#     }
#     baserules = buildAnywhereSettings()
#     baserules = genericSettings()
#     mcPrint(baserules[1])

 #    descriptions = {"baserules": ""}
 #    {'baserules': 1,
 # 'bind': False,
 # 'debug': True,
 # 'firstRun': True,
 # 'grantguides': False,
 # 'map': 'islands',
 # 'maxplayers': 36,
 # 'noupnp': False,
 # 'port': 64090,
 # 'prefix': 'server',
 # 'rconpassword': None,
 # 'servername': 'Miscreated self-hosted server #2527290',
 # 'serverpassword': None,
 # 'whitelist': False}

# prompt_with_timeout()

    #
    # defaultSvrName = cliConfig.get('servername', False) and \
    #                  svrConfig.get('servername', False)
    # if not defaultSvrName:
    #     print("Your server name is currently: {}".format(defaultConfig.get('servername')))

    # KEEPRUNNING = True
    # while KEEPRUNNING:
    #     # init() and deinit() are called for colorizing output.
    #     init()
    #     thisServer = MiscreatedServer(debug=cliConfig['debug'],
    #                                   serverPrefix=prefix,
    #                                   thisPath=path)
    #     KEEPRUNNING = False

def reconcileSettings(cli=dict(), default=dict(), svr=dict()):
    settings = dict()
    for cliKey, cliValue in cli.items():
        thisValue = cliValue
        if cliValue in (None, False):
            thisValue = svr.get(cliKey, "<novalue>")
        if thisValue == "<novalue>":
            thisValue = default.get(cliKey, None)
        settings[cliKey] = thisValue
    for defaultKey, defaultValue in default.items():
        if settings.get(defaultKey, '<novalue>') == '<novalue>':
            settings[defaultKey] = defaultValue
    for svrKey, svrValue in svr.items():
        if settings.get(svrKey, '<novalue>') == '<novalue>':
            settings[svrKey] = svrValue
    return settings


@click.command()
def hello():
    click.echo('Hello World!')


if __name__ == '__main__':
    hello()


# "D:\git\simplified-miscreated-server-setup\MiscreatedServer\Bin64_dedicated\MiscreatedServer.exe"  -sv_port 64090 +sv_maxplayers 36 +map islands +sv_servername "My Test Server" +http_startserver
# subprocess.run(args=['D:\\git\\simplified-miscreated-server-setup\\MiscreatedServer\\Bin64_dedicated\\MiscreatedServer.exe', '-sv_port', '64095', '+sv_maxplayers 33', '+map islands', '+sv_servername My Test Server', '+http_startserver'])
# Find local path
# set build-anywhere [bool]
# clean mods dir (os)
# create local join script
# create upnp undo script
# download steamcmd if needed
# download upnp helper (or use python equivalent)
# grant all guides (sql)
# set RCON password


#
#
#
#
# ══════════════════════════════════════════════════════════════════════════════
#                 The servername will be: My Test Server
#  The maximum number of players will be: 36
#      The base game server port will be: 64090
#
#              NOTICE: Your RCON port is: 64094
#
#  ► Guides will be granted to all players
#  ► Base building is enabled: build-anywhere
#  ► Firewall ports will not be automatically forwarded
#  ► The server will not be whitelisted
# ══════════════════════════════════════════════════════════════════════════════
#
#
# Starting the Miscreated server
#   command: "D:\git\simplified-miscreated-server-setup\MiscreatedServer\Bin64_dedicated\MiscreatedServer.exe"  -sv_port 64090 +sv_maxplayers 36 +map islands +sv_servername "My Test Server" +http_startserver
