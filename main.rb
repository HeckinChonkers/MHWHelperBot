require 'discordrb'
require 'json'
require 'logger'
require_relative 'ChartManager.rb'
require_relative 'JsonFileManager.rb'

@logger ||= Logger.new(STDOUT)
@expecting_response = false
@name_matches = ''
@channel_id = 414915330419195917
@voice_channel_id = 414915330419195919
json_file_manager = JsonFileManager.new
info_hash = json_file_manager.load_json_file("info.json")
chart_manager = ChartManager.new(@logger)
@weakness_chart = chart_manager.get_weakness_chart
@breakable_chart = chart_manager.get_breakable_chart

bot = Discordrb::Commands::CommandBot.new token: info_hash['token'], client_id: 498586278951124992, prefix: '!'

bot.command(:connect) do |event|
  bot.voice_connect(@voice_channel_id)
  'Connected to voice channel'
end

bot.message(containing: ['devil', 'Devil', 'deviljho', 'Deviljho']) do |event|
  voice_bot = event.voice
  voice_bot.play_file('Content/deviljhotheme.mp3')
end

bot.message(containing: ['jager', 'JAGER', 'Jager']) do |event|
  event.respond 'Did someone say JAGER?'
  event.respond 'WOOOOOOOOOOOO!!!!!!'
end

bot.command(:answer) do |event, match_index|
  if @expecting_response
    result_index= match_index.to_i
    result = get_weakness_table(@name_matches[result_index - 1])
    @expecting_response = false
    @name_matches = ''
    event.respond result
  end
end

bot.command(:guide) do |event, monster_name|
  event.respond get_weakness_table(monster_name.downcase)
end

def get_weakness_table(monster_name)
  rows = []
  if !monster_name
    return "Please supply a monster name to match"
  end
  index_of_monster = find_index_of_monster(@weakness_chart['monster'], monster_name)
  if index_of_monster
    if !index_of_monster.is_a? Integer 
      if index_of_monster.include?("Multiple matches found.")
        @expecting_response = true
        return index_of_monster
      end
    end
    @name_matches = ''
    @weakness_chart.each do |item|
      if item[0] == 'monster'
        next
      end
      rows << [item[0].capitalize, item[1][index_of_monster].capitalize]
    end
    table = create_ascii_table(@weakness_chart['monster'][index_of_monster].capitalize, rows)
  else
    return "Cannot find monster name that matches #{monster_name}, ya bish."
  end
end

bot.command(:exit, help_available: false) do |event|
  # This is a check that only allows a user with a specific ID to execute this command. Otherwise, everyone would be
  # able to shut your bot down whenever they wanted.
  break unless event.user.id == 250816303378464770

  bot.send_message(event.channel.id, 'SEE YA BISHES! I\'M OUT!', true)
  exit
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

def find_index_of_monster(monster_names, name)
  if monster_names.include?(name)
    @name_matches = name
  elsif monster_names.any? { |str| str.include?(name) }
    @name_matches = monster_names.select{ |str| str.include?(name) }
  end

  if @name_matches.is_a?(Enumerable)
    if @name_matches.count > 1
      message = "`Multiple matches found. Which one do you want?`\r\n"
      @name_matches.each do |str|
      message += "`#{@name_matches.index(str) + 1}: #{str}`\r\n"
      end
    return message
    end
  return monster_names.index(@name_matches[0])
  end

  match = monster_names.index(@name_matches)
  if match == -1
    return nil
  else
    return match
  end
end

bot.run
