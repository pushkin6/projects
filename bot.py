# bot.py
import os
import discord
from discord.ext import commands
from dotenv import load_dotenv

load_dotenv()
TOKEN = os.getenv('DISCORD_TOKEN')
SERVER = os.getenv('DISCORD_SERVER')

intents = discord.Intents.default()
intents.message_content = True
intents.members = True

client = discord.Client(intents=intents)
bot = commands.Bot(command_prefix='!', intents=intents)

@bot.event
async def on_ready():
    for guild in bot.guilds:
        if guild.name == SERVER:
            break

    print(
        f'{bot.user} is connected to the following server:\n'
        f'{guild.name} (id: {guild.id})'
    )

@bot.event
async def on_member_join(member):
    channel = discord.utils.get(member.guild.channels, name='general')
    if channel:
        await channel.send(
            f'Welcome to the server, {member.mention}!\n'
            f'You are one of  #{member.guild.member_count} members.\n'
            f'Head over to #rules and enjoy your stay!'
        )

@bot.command(name='testwelcome')
async def testwelcome(ctx):
    await on_member_join(ctx.author)

bot.run(TOKEN)



#@client.event
#async def on_ready():
#    for guild in client.guilds:
#        if guild.name == SERVER:
#            break

#    print(
#        f'{client.user} is connected to the following server:\n'
#            f'{guild.name} (id: {guild.id})'
#    )

#@client.event
#async def on_member_join(member):
#    channel = discord.utils.get(member.guild.channels, name ='general')

#    if channel:
#        await channel.send(
#            f'Welcome to the server, {member.mention}!\n'
#            f'You are a member #{member.guild.member_count}.\n'
#            f'Head over to #rules and enjoy your stay!'
#        )

#client.run(TOKEN)

