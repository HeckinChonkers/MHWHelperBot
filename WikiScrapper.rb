::RBNACL_LIBSODIUM_GEM_LIB_PATH = "C:\Libsodium\Win32\Release\v120\dynamic\libsodium.dll"
require 'discordrb'
require 'json'

file = File.read('info.json')
info_hash = JSON.parse(file)
monsters = info_hash['Monsters']

bot = Discordrb::Commands::CommandBot.new token: info_hash['token'], client_id: 498586278951124992, prefix: '~'

bot.message(with_text: 'Ping') do |event|
  event.respond 'Hello'
end

bot.command(:play) do |event|
  
end

bot.run