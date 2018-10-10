::RBNACL_LIBSODIUM_GEM_LIB_PATH = "C:\Libsodium\Win32\Release\v120\dynamic\libsodium.dll"
require 'discordrb'
require 'json'
require_relative 'ChartManager.rb'
require_relative 'JsonFileManager.rb'

@channel_id = 414915330419195917
json_file_manager = JsonFileManager.new
info_hash = json_file_manager.load_json_file("info.json")
chart_manager = ChartManager.new
weakness_chart = chart_manager.get_weakness_chart
breakable_chart = chart_manager.get_breakable_chart

bot = Discordrb::Commands::CommandBot.new token: info_hash['token'], client_id: 498586278951124992, prefix: '!'

bot.message(with_text: 'Ping') do |event|
  event.respond 'Pong'
end

bot.command(:guide) do |event, monster_name|
  rows = []
  #index of monster across all hashes. For now, it is 0 for Great Jagras
  index_of_monster = 0
  weakness_chart.each do |item|
    if item[0] == 'Monster'
      next
    end
    rows << [item[0], item[1][index_of_monster]]
  end
  table = create_ascii_table(weakness_chart['Monster'][index_of_monster], rows)
  event.respond table
end

def create_ascii_table(title, rows)
  table = "`" + title + "`\r\n`------------------------`\r\n"
  max_length = 0
  rows.each do |row|
    if max_length < row[0].length
      max_length = row[0].length
    end
  end
  max_length += 5
  rows.each do |row|
    table << "`" + row[0] + " " * (max_length - row[0].length) + row[1] + "`\r\n"
  end
  return table
end

def bot_alive(bot)
  bot.send_message(@channel_id, 'I LIVE, BISHES!!')
end

def bot_die(bot)
  bot.send_message(@channel_id, 'Aww bish....I\'m dead.')
end


task = bot.run
