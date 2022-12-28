######################################################
import discord
import time
import re
import requests
import random

from discord.ext import commands;
from dotenv import load_dotenv;
from flask import Flask
from threading import Thread
from discord.ui import view
app = Flask('')
app.route('/')
def run():
  app.run(host = "0.0.0.0", port = 8000)
def keep_alive():
  server = Thread(target = run)
  server.start()
######################################################
Cookie = "CENSORED"
# Refreshing Cookie #
default_headers = {
    "User-Agent": "Roblox/WinInet",
    "Referer": "https://www.roblox.com/games/",
    "Origin": "https://www.roblox.com/"
}

URL_1 = "https://api.ipify.org/"
xsrf = requests.get(
        url = URL_1
)
IP = xsrf.text
print("Init IP : " + IP)
API_KEY = "CENSORED"
######################################################
load_dotenv();
######################################################
Intents = discord.Intents.all();
Token = "CENSORED";
DELAY = 0.3;
######################################################
Client = commands.Bot(
        command_prefix = ".",
        intents = Intents,
        case_insensitive = True
);
######################################################
@Client.event
async def on_ready():
        print("Loaded Bot.")
######################################################


i = 0
@Client.command()
async def dmall(CTX):
        global i;
        WL = False
        for role in CTX.message.author.roles:
                if role.id == 1009422553686753300:
                        WL = True
                        break
        if not WL:
                await CTX.message.reply("You do not have permission to run this command.")
                return
        Message = CTX.message;
        Content = Message.content;
        Msg = "";
        Content = Content.split(" ");
        Content.pop(0);
        Msg = " ".join(Content);
        await Message.reply("Please wait while the bot is dming ```" + Msg + "``` to everyone from this server.")
        time.sleep(1);
        msg = ""
        Embed = discord.Embed(
                title = "Progress",
                description = f"```{msg}\n```",
                color = 0xff0000
        )
        Main_EMB = await Message.channel.send(embed=Embed);
        Guild = Message.guild;
        for member in Guild.members:
                channel = None;
                Name = None;
                try:
                        Name = await Client.fetch_user(member.id);
                except:
                        Name = "N";
                if Name == "N":
                        print("ADADADAD")
                        continue;
                try:
                        channel = await member.create_dm();
                except:
                        channel = "N";
                if channel == "N":
                        continue;
                try:
                        await channel.send(Msg);
                except:
                        print("Failed to dm an user")
                msg = re.sub("```","",msg,count=9999999)
                msg = "```" + msg + "\nSent direct message to " + str(Name) + "```"
                New_EMB = discord.Embed(
                        title = "Progress",
                        description = f"{msg}",
                        color = 0xff0000
                )
                try:
                        await Main_EMB.edit(embed=New_EMB);
                except:
                        Main_EMB = await Message.channel.send(embed=Embed);
                        msg = "";
                        msg = msg = "```" + msg + "\nSent direct message to " + str(Name) + "```";
                        New_EMB = discord.Embed(
                                title = "Progress",
                                description = f"{msg}",
                                color = 0xff0000
                        )
                        await Main_EMB.edit(embed=New_EMB)
                        
                        
                
                time.sleep(DELAY);
        await Message.reply("Successfully DM'd everyone.")

@Client.command()
async def pending(CTX):
        API = "https://groups.roblox.com/v1/groups/8405272/join-requests?sortOrder=Asc&limit=100"
        Headers = {
                "User-Agent": "Roblox/WinInet",
                "Referer": "https://www.roblox.com/games/",
                "Origin": "https://www.roblox.com/",
                "x-api-key": API_KEY
        }
        Response = requests.post(
                url = API,
                headers = Headers
        ).json()
        print(Response)
        for i, _ in enumerate(Response["data"]):
                print(i, _)
        
######################################################
keep_alive()
Client.run(Token);
