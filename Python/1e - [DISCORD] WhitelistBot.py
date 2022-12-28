# This is a bot i made for an anticheat i previously created, for the sole purpose of having a secure and easy to maintain whitelist. This demonstrates my skills to work with external apis and discord bots.

# RISE BOT #
# LIBRARIES IMPORT #
import requests;
import firebase_admin;
import discord;
import os;
import random;
import string;

# LIBRARIES FROM IMPORT #
from firebase_admin import credentials;
from firebase_admin import firestore;
from dotenv import load_dotenv;
from discord.ext import commands;

# ENV LOAD #
load_dotenv();

# DECLARING VARIABLES #
Intents = discord.Intents.all();
Token = os.getenv("DISCORD-TOKEN");

# MAIN INITIALIZER #
Client = commands.Bot(
        command_prefix = "rise$",
        intents = Intents,
        case_insensitive = True
);

# FIRESTORE PRIVATE KEY #
Private_Key = {
  "type": "service_account",
  "project_id": "CENSORED",
  "private_key_id": "CENSORED",
  "private_key": "CENSORED",
  "client_email": "CENSORED",
  "client_id": "105303688335706869463",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "CENSORED"
};

# FIRESTORE INITIALIZER #
Login_Init = credentials.Certificate(Private_Key);
App = firebase_admin.initialize_app(Login_Init);
DataBase = firestore.client();

# FUNCTIONS #
async def blacklist_license(License, Reason, bool):
        if bool == "True":
                bool = True
        else:
                bool = False
        Ref = DataBase.collection(u"whitelist").document(License)
        if Ref:
                Ref.update(
                        {
                                u"blacklisted": bool,
                                u"blacklistedR": Reason
                        }
                )

# EVENTS #
@Client.event
async def on_ready():
        print("[RISE] Initialized bot successfully.");

# COMMANDS #
@Client.command()
async def blacklist(ctx, message, bool):
        License = message;
        FullMessage = ctx.message.content;
        Reason = "";
        SplitMessage = FullMessage.split(" ");
        SplitMessage.pop(0);
        SplitMessage.pop(0);
        SplitMessage.pop(0);
        Reason = " ".join(SplitMessage);
        await blacklist_license(License, Reason, bool);
        blacklisted_embed = discord.Embed(
                title = "Rise Blacklist",
                color = 0xff0000
        );
        blacklisted_embed.set_image(url="https://media.discordapp.net/attachments/851807767370268693/1006214768023052390/standard_1.gif?width=540&height=216");
        blacklisted_embed.set_footer(text = "Rise Anti-Exploit | Bot created by Enrise", icon_url = "https://cdn.discordapp.com/attachments/851807767370268693/1006215853915783270/standard_2.gif");
        blacklisted_embed.add_field(
                name = "License ID",
                value = License,
                inline = True
        );
        blacklisted_embed.add_field(
                name = "Blacklist Reason",
                value = Reason,
                inline = True
        );
        blacklisted_embed.add_field(
                name = "Blacklist Status",
                value = str(bool),
                inline = True
        );
        await ctx.message.reply(embed = blacklisted_embed)

@Client.command()
async def linkplace(ctx, License, id):
        print("call")
        id = int(id)
        Ref = DataBase.collection("whitelist").document(License).update(
                {
                        "linkedPlaces": firestore.ArrayUnion(
                                [
                                        id
                                ]
                        )
                }
        )
        await ctx.message.reply(f"Successfully linked {str(id)} to License {License}.")

@Client.command()
async def unlinkplace(ctx, License, id):
        id = int(id)
        Ref = DataBase.collection("whitelist").document(License).update(
                {
                        "linkedPlaces": firestore.ArrayRemove(
                                [
                                        id
                                ]
                        )
                }
        )
        await ctx.message.reply(f"Successfully unlinked {str(id)} from License {License}.")

@Client.command()
async def setname(ctx, License, name):
        Ref = DataBase.collection("whitelist").document(License).update(
                {
                        "name": name
                }
        )
        await ctx.message.reply(f"Successfully linked name {name} to License {License}.")

@Client.command()
async def newlicense(ctx):
        License =  "".join(random.choice(string.ascii_letters) for i in range(20)) + "-RISE";
        Ref = DataBase.collection("whitelist").document(License).set(
                {
                        "blacklisted": False,
                        "blacklistedR": "None",
                        "linkedPlaces": {
                                696969
                        },
                        "name": "NotSet"
                }
        )
        await ctx.message.reply(License);

Client.run(Token);
