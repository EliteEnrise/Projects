# IMPORT #
import discord;
import time;
import re;
import requests;
import random;
import asyncio;

# FROM IMPORT #
from discord.ext import commands;
from dotenv import load_dotenv;
from flask import Flask;
from threading import Thread;
from discord.ui import view;

print(random.randrange(0, 1))

# IP GET #
URL_1 = "https://api.ipify.org/";
xsrf = requests.get(
        url = URL_1
);
IP = xsrf.text;
print("Init IP : " + IP);

# BOT STUFF #
Intents = discord.Intents.all();
Token = "CENSORED";

# VARIABLES #
Guild = None;

# FUNCTIONS #
async def get_info(CTX):
        Info = {
                "content": CTX.message.content,
                "message": CTX.message,
                "author": CTX.message.author,
                "guild": CTX.message.guild,
                "split": CTX.message.content.split(" ")
        }
        return Info

async def convert(Duration):
        FinalMessage = "0 **hours** 0 **minutes** 0 **seconds**"
        if Duration <= 0:
                return "giveaway has **ended** or something went horribly wrong"
        Hours = int(Duration / 3600)
        if Hours <= 0:
                Hours = "s";
        Minutes = int((Duration % 3600) / 60)
        if Minutes <= 0:
                Minutes = "s";
        Seconds = int((Duration % 3600) % 60)
        if Seconds <= 0:
                Seconds = "s";
        if Hours == "s" and Minutes != "s" and Seconds != "s":
                FinalMessage = str(Minutes) + " **minutes** " + str(Seconds) + " **seconds**"
                return FinalMessage;
        elif Hours == "s" and Minutes == "s" and Seconds != "s":
                FinalMessage = str(Seconds) + " **seconds**"
                return FinalMessage;
        elif Hours == "s" and Minutes != "s" and Seconds == "s":
                FinalMessage = str(Minutes) + " **minutes**"
                return FinalMessage;
        elif Hours != "s" and Minutes == "s" and Seconds == "s":
                FinalMessage = str(Hours) + " **hours**"
                return FinalMessage;
        elif Hours != "s" and Minutes != "s" and Seconds == "s":
                FinalMessage = str(Hours) + " **hours** " + str(Minutes) + " **minutes**"
                return FinalMessage;
        elif Hours != "s" and Minutes == "s" and Seconds != "s":
                FinalMessage = str(Hours) + " **hours** " + str(Seconds) + " **seconds**"
                return FinalMessage;
        elif Hours == "s" and Minutes == "s" and Seconds == "s":
                FinalMessage = "giveaway has **ended** or something went wrong"
                return FinalMessage;
        else:
                FinalMessage = str(Hours) + " **hours** " + str(Minutes) + " **minutes** " + str(Seconds) + " **seconds**"
                return FinalMessage;

async def sync_create_embed_for_giveaway(New_Desc, Prize, Winners, Content):
        Embed = discord.Embed(
                title = Prize,
                color = 0xff0000
        )
        Embed.add_field(
                name = "Instructions",
                value = "React with :tada: to enter the giveaway",
                inline = False
        )
        Embed.add_field(
                name = "Time Remaining",
                value = New_Desc,
                inline = False
        )
        Embed.add_field(
                name = "Winners",
                value = Winners == 1 and "1 winner" or str(Winners) + " winners",
                inline = False
        )
        Embed.add_field(
                name = "Giveaway Host",
                value = "Hosted by <@"+str(Content["author"].id)+">",
                inline = False
        )
        return Embed;
        

# INIT #
Client = commands.Bot(
        command_prefix = ".",
        intents = Intents,
        case_insensitive = True
)

# EVENTS #
@Client.event
async def on_ready():
        print("READY")
        Embed = discord.Embed(
                title = "Nuce try",
                description = "This is a troll",
                color = 0xff0000
        );
        n = 0;
        while True:
                n = n + 1
                if n == 4:
                        n = 1;
                if n == 1:
                        await Client.change_presence(activity=discord.Activity(type=discord.ActivityType.watching, name="qirxis's anorexic toes"))
                elif n == 2:
                        await Client.change_presence(activity=discord.Activity(type=discord.ActivityType.watching, name="config trying to get a job"))
                elif n == 3:
                        await Client.change_presence(activity=discord.Activity(type=discord.ActivityType.watching, name="lilzom pull 50 girls"))
                await asyncio.sleep(10);

# COMMANDS #
@Client.command()
async def say(CTX):
        Content = await get_info(CTX);
        if Content["author"].id == 1009460118607376404:
                print("Yes")
                await Content["guild"].get_channel(1007043316782731355).send("yo");

@Client.command()
async def giveaway(CTX):
        if CTX.message.author.id != 1009460118607376404:
                await CTX.message.reply("hey babe u dont have access >3")
                return;
        Content = await get_info(CTX);
        if len(Content["split"]) <= 3:
                await Content["message"].reply("wrong format cutie. correct format is .giveaway <time> <winners> <prize> babe")
                return;
        Time_ = Content["split"][1];
        Time = 0;
        if "d" in Time_:
                Time_ = Time_.replace("d", "");
                Time = int(Time_) * 86400;
        elif "h" in Time_:
                Time_ = Time_.replace("h", "");
                Time = int(Time_) * 3600;
        elif "m" in Time_:
                Time_ = Time_.replace("m", "");
                Time = int(Time_) * 60;
        elif "s" in Time_:
                Time_ = Time_.replace("s", "");
                Time = int(Time_);
        else:
                try:
                        Time = int(Time_);
                except:
                        await Content["message"].reply("something went wrong babe try not being dumb next time");
                        return;
        Winners = Content["split"][2];
        if Winners.find("w") or Winners.find("W"):
                Winners = Winners.replace("w", "");
                Winners = Winners.replace("W", "");
        Content["split"].pop(0);
        Content["split"].pop(0);
        Content["split"].pop(0);
        Prize = " ".join(Content["split"]);
        ConvertedTime = await convert(Time);
        Embed = await sync_create_embed_for_giveaway(ConvertedTime, Prize, Winners, Content);
        Message = await Content["message"].channel.send(embed=Embed);
        await Message.add_reaction("🎉");
        Winner = 0;
        FK_THE_LOOP = False;
        while True:
                Time = Time - 5;
                Converted = await convert(Time);
                new_embed = await sync_create_embed_for_giveaway(Converted, Prize, Winners, Content);
                await Message.edit(embed=new_embed);
                if Time <= 0:
                        msg = await Content["message"].channel.fetch_message(Message.id);
                        Reactors = msg.reactions[0];
                        Num = 0;
                        Count = 0;
                        Users = {};
                        async for user in Reactors.users():
                                if user.id != 1010901536467062784:
                                        Num = Num + 1;
                        Winner = random.randrange(0, Num);
                        print(Winner);
                        async for user in Reactors.users():
                                if Count == Winner:
                                        if user.id == 1010901536467062784:
                                                if Winner == 0:
                                                        n = 0;
                                                        async for user2 in Reactors.users():
                                                                if n == Winner+1:
                                                                        await Content["message"].reply("<@"+str(user2.id)+"> has won the giveaway babe");
                                                                n = n+1;
                                                        FK_THE_LOOP = True;
                                                        break;
                                                else:
                                                        n = 0;
                                                        async for user2 in Reactors.users():
                                                                if n == Winner-1:
                                                                        await Content["message"].reply("<@"+str(user2.id)+"> has won the giveaway babe");
                                                                n = n+1;
                                                        FK_THE_LOOP = True;
                                                        break;
                                                continue;
                                        await Content["message"].reply("<@"+str(user.id)+"> has won the giveaway babe");
                                        FK_THE_LOOP = True;
                                        break;

                if FK_THE_LOOP:
                        break;
                await asyncio.sleep(5);

@Client.command()
async def gayrate(CTX):
        Len = len(CTX.message.content.split(" "))
        if Len == 1:
                Embed = discord.Embed(
                title = "gay rate for the cutie " + CTX.message.author.name,
                description = "You are about " + str(random.randrange(0, 100)) + "% gay",
                color = 0xffc0cb
        )
                await CTX.message.reply(embed=Embed)
        else:
                Embed = discord.Embed(
                title = "gay rate for the cutie " + CTX.message.mentions[0].name,
                description = CTX.message.mentions[0].name + " is about " + str(random.randrange(0, 100)) + "% gay",
                color = 0xffc0cb
        )
                await CTX.message.reply(embed=Embed)
        

# MAIN #
Client.run(Token);
