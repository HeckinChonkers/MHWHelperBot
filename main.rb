::RBNACL_LIBSODIUM_GEM_LIB_PATH = "C:\Libsodium\Win32\Release\v120\dynamic\libsodium.dll"
require 'discordrb'
require 'json'

channel_id = 414915330419195916
file = File.read('info.json')
info_hash = JSON.parse(file)
monsters = info_hash['monsters']

bot = Discordrb::Commands::CommandBot.new token: info_hash['token'], client_id: 498586278951124992, prefix: '!'

bot.message(with_text: 'Ping') do |event|
  event.respond 'Pong'
end

bot.command(:guide) do |event, monsterName|
  monsters[monsterName].each do |filename|
    event.send_file(File.open('content\\' + filename, 'r'))
  end
end

bot.run
