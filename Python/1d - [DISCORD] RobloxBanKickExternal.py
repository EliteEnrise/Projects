# This makes it possible to kick/ban/unban from Discord, this can be improved a lot. I made this for personal use, which is the main reason it is NOT the BEST code.

import requests
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import discord
from dotenv import load_dotenv
from discord.ext import commands
intents = discord.Intents.all()
import os
        
file = {
  "CENSORED"
}
load_dotenv()
TOKEN = os.environ['DISCORD-TOKEN']
client = commands.Bot(command_prefix="!", intents=intents, case_insensitive=True)

login = credentials.Certificate(file)
firebase_admin.initialize_app(login)

database = firestore.client()
whitelisted_users = {}

def Set(Message, UserID, Reason, Banned):
        reference = database.collection(u"bans").document(UserID)
        reference.set({
                u"Banned": Banned,
                u"Reason": Reason
        })
def SetKick(Message, UserID, Reason):
        reference = database.collection(u"bans").document(UserID+"_kick")
        reference.set({
                u"Kicked": True,
                u"Reason": Reason
        })

def filter(string):
        final = string
        final = final.replace("@","")
        final = final.replace("<","")
        final = final.replace(">","")
        return final
        
@client.event
async def on_message(message):
        print("Received message")
        if message.author.id == 774922209772175370:
                if message.content.startswith("$addadmin"):
                        id = filter(message.content.split(" ")[1])
                        print(id)
                        whitelisted_users[id] = True
                        embedsuc = discord.Embed(
                                title = "Added new administrator to Database",
                                description = "Successfully added "+id+" to the database of admins. User is now able to use discord commands.",
                                color = 0xff0000
                        )
                        embedsuc.set_footer(text="Flooded Area | Game Moderation | Created by Enrise")
                        await message.channel.send(content="<action: $addadmin>", embed=embedsuc)
                elif message.content.startswith("$removeadmin"):
                        id = filter(message.content.split(" ")[1])
                        print(id)
                        embedsuc = discord.Embed(
                                title = "Removed administrator from Database",
                                description = "Successfully removed "+id+" to the database of admins. User is no longer able to use discord commands.",
                                color = 0xff0000
                        )
                        embedsuc.set_footer(text="Flooded Area | Game Moderation | Created by Enrise")
                        whitelisted_users[id] = False
                        await message.channel.send(content="<action: $removeadmin>", embed=embedsuc)
        if message.content and str(message.author.id) in whitelisted_users:
                Message = message.content
                if Message.startswith("$pban"):
                        print("[LOG] Called Permanent Ban")
                        embedg = discord.Embed(
                                title = "Failed to append to Database",
                                description = "Missing arguments: Reason/UserID. Make sure you specify them and split by spacebar.\n\n**CORRECT FORMAT:** ```diff\n+> Command: $pban\n+> $pban <integer/number: UserID> <string: Reason>```",
                                color = 0xff0000
                        )
                        embedg.set_footer(text="Flooded Area | Game Moderation | Created by Enrise")
                        Split = Message.split(" ")
                        try:
                                test = Split[1]
                                test2 = Split[2]
                        except:
                                await message.channel.send(embed=embedg)
                                return
                        ID = Split[1]
                        
                        Reason = ""
                        for i, _ in enumerate(Split):
                                if i >= 2:
                                        Reason = Reason + Split[i] + " "
                        Set(message, ID, Reason, True)
                        embedv = discord.Embed(
                                title = "Successfully Banned",
                                color = 0xff0000
                        )
                        embedv.set_footer(text="Flooded Area | Game Moderation | Created by Enrise")
                        Data = requests.get(
                                url = f"https://api.roblox.com/users/{ID}"
                        )
                        print(Data.json())
                        Data = Data.json()
                        embedv = discord.Embed(
                                title = "Successfully Banned",
                                color = 0xff0000
                        )
                        embedv.add_field(
                                name = "Username",
                                value = Data["Username"],
                                inline = False
                        )
                        embedv.add_field(
                                name = "UserID",
                                value = ID,
                                inline = False
                        )
                        embedv.add_field(
                                name = "Reason",
                                value = Reason,
                                inline = False
                        )
                        embedv.add_field(
                                name = "Status",
                                value = "User was banned from the game with success.",
                                inline = False
                        )
                        embedv.set_thumbnail(url=f"https://www.roblox.com/headshot-thumbnail/image?userId={ID}&width=420&height=420&format=png")
                        await message.channel.send(embed=embedv)
                elif Message.startswith("$unban"):
                        print("[LOG] Called Unban")
                        embedg = discord.Embed(
                                title = "Failed to append to Database",
                                description = "Missing arguments: UserID. Make sure you specify it and split by spacebar.\n\n**CORRECT FORMAT:** ```diff\n+> Command: $unban\n+> $unban <integer/number: UserID>```",
                                color = 0xff0000
                        )
                        embedg.set_footer(text="Flooded Area | Game Moderation | Created by Enrise")
                        Split = Message.split(" ")
                        try:
                                test = Split[1]
                        except:
                                await message.channel.send(embed=embedg)
                                return
                        ID = Split[1]
                        
                        Reason = ""
                        for i, _ in enumerate(Split):
                                if i >= 2:
                                        Reason = Reason + Split[i] + " "
                        Set(message, ID, Reason, False)
                        Data = requests.get(
                                url = f"https://api.roblox.com/users/{ID}"
                        )
                        print(Data.json())
                        Data = Data.json()
                        embedv = discord.Embed(
                                title = "Successfully Unbanned",
                                color = 0xff0000
                        )
                        embedv.add_field(
                                name = "Username",
                                value = Data["Username"],
                                inline = False
                        )
                        embedv.add_field(
                                name = "UserID",
                                value = ID,
                                inline = False
                        )
                        embedv.add_field(
                                name = "Status",
                                value = "User was unbanned from the game with success.",
                                inline = False
                        )
                        embedv.set_thumbnail(url=f"https://www.roblox.com/headshot-thumbnail/image?userId={ID}&width=420&height=420&format=png")
                        embedv.set_footer(text="Flooded Area | Game Moderation | Created by Enrise")
                        await message.channel.send(embed=embedv)
                elif message.content.startswith("$kick"):
                        split = message.content.split(" ")
                        embedg = discord.Embed(
                                title = "Failed to append to Database",
                                description = "Missing arguments: UserID. Make sure you specify it and split by spacebar.\n\n**CORRECT FORMAT:** ```diff\n+> Command: $kick\n+> $kick <integer/number: UserID> <string: Reason>```",
                                color = 0xff0000
                        )
                        embedg.set_footer(text="Flooded Area | Game Moderation | Created by Enrise")
                        try:
                                test = split[1]
                                test = split[2]
                        except:
                                await message.channel.send(embed=embedg)
                                return
                        ID = split[1]
                        Reason = ""
                        for i, _ in enumerate(split):
                                if i >= 2:
                                        Reason = Reason + split[i] + " "
                        SetKick(message, ID, Reason)
                        Data = requests.get(
                                url = f"https://api.roblox.com/users/{ID}"
                        )
                        print(Data.json())
                        Data = Data.json()
                        embedv = discord.Embed(
                                title = "Successfully Kicked",
                                color = 0xff0000
                        )
                        embedv.add_field(
                                name = "Username",
                                value = Data["Username"],
                                inline = False
                        )
                        embedv.add_field(
                                name = "UserID",
                                value = ID,
                                inline = False
                        )
                        embedv.add_field(
                                name = "Reason",
                                value = Reason,
                                inline = False
                        )
                        embedv.add_field(
                                name = "Status",
                                value = "User was kicked from the game with success.",
                                inline = False
                        )
                        embedv.set_thumbnail(url=f"https://www.roblox.com/headshot-thumbnail/image?userId={ID}&width=420&height=420&format=png")
                        embedv.set_footer(text="Flooded Area | Game Moderation | Created by Enrise")
                        await message.channel.send(embed=embedv)
                        

@client.event
async def on_ready():
        print("[LOG] Connection Initialized")
                        

client.run(TOKEN)
