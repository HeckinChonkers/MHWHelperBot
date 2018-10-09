::RBNACL_LIBSODIUM_GEM_LIB_PATH = "C:\Libsodium\Win32\Release\v120\dynamic\libsodium.dll"
require 'discordrb'
require 'json'
require_relative 'ChartManager.rb'
require_relative 'JsonFileManager.rb'

$stdout.puts "Starting..."

jsonfilemanager = JsonFileManager.new
info_hash = jsonfilemanager.load_json_file("info.json")
chartManager = ChartManager.new

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
