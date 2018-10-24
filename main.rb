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
@voice_bot = nil
@actual_monster_name = ""
bot = Discordrb::Commands::CommandBot.new token: info_hash['token'], client_id: 498586278951124992, prefix: '!'

bot.command(:connect) do |event|
  @voice_bot = bot.voice_connect(@voice_channel_id)
  'Connected to voice channel'
end

bot.message(containing: ['devil', 'Devil', 'deviljho', 'Deviljho']) do |event|
 event.respond 'Devil...?!' 
 @voice_bot.play_file('./Content/deviljhotheme.mp3')
end

bot.command(:stopsound) do |event|
  @voice_bot.stop_playing
end

bot.message(containing: info_hash['curses']) do |event|
  @voice_bot.play_file('./Content/profamity.mp3')
end

bot.message(containing: ['oz', 'Oz', 'Osborne', 'osborne']) do |event|
  event.respond 'You just had to bring him up.'
  #@voice_bot.play_file('./Content/osborne.mp3')
end

bot.message(containing: ['wow', 'Wow', 'WOW']) do |event|
  event.respond 'OH WOW'
  @voice_bot.play_file('./Content/wow.mp3')
end

bot.message(containing: ['jager', 'JAGER', 'Jager']) do |event|
  event.respond 'Did someone say JAGER?'
  event.respond 'WOOOOOOOOOOOO!!!!!!'
end

bot.message(containing: ['purse', 'Purse', 'PURSE']) do |event|
  @voice_bot.play_file('./Content/purse.mp3')
end

bot.message(containing: ['sucks', 'Sucks', 'SUCKS']) do |event|
  @voice_bot.play_file('./Content/sucks.mp3')
end

bot.message(containing: ['do it', 'DO IT', 'Do it', 'Do It']) do |event|
  @voice_bot.play_file('./Content/doit.mp3')
end

bot.message(containing: ['bee', 'BEE', 'Bee']) do |event|
  @voice_bot.play_file('./Content/influxofbees.mp3')
end

bot.command(:answer) do |event, match_index|
  perform_answer(event, match_index)
end

bot.command(:a) do |event, match_index|
  perform_answer(event, match_index)
end

bot.command(:g) do |event, monster_name|
  @expecting_response = false
  event.respond get_weakness_table(monster_name.downcase)
  breakable =  get_breakable_table(monster_name.downcase)
  if breakable and breakable != ""
    event.respond breakable
  end
end

bot.command(:guide) do |event, monster_name|
  @expecting_response = false
  event.respond get_weakness_table(monster_name.downcase)
  if !@expecting_response
    breakable =  get_breakable_table(monster_name.downcase)
    if breakable and breakable != ""
      event.respond breakable
    end
    end
end

def perform_answer(event, match_index)
  if @expecting_response
    result_index= match_index.to_i
    result = get_weakness_table(@name_matches[result_index - 1])
    breakable = get_breakable_table(@name_matches[result_index - 1])
    @expecting_response = false
    @name_matches = ''
    event.respond result
    if breakable and breakable != ""
      event.respond breakable
    end
  end
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
    @actual_monster_name = @weakness_chart['monster'][index_of_monster]
    table = create_weakness_ascii_table(@weakness_chart['monster'][index_of_monster].capitalize, rows)
  else
    return "Cannot find monster name that matches #{monster_name}, ya bish."
  end
end

def get_breakable_table(monster_name)
  rows = []
  indexes_of_matches = @breakable_chart["0"].each_index.select{|i| @breakable_chart["0"][i] == @actual_monster_name}
  if indexes_of_matches and indexes_of_matches.count > 0
    indexes_of_matches.each do |index|
      resulting_row = ""
      (1..@breakable_chart.count - 1).each do |item|
        if item == 1
          resulting_row += @breakable_chart["#{item}"][index] + ":\r\n"
          next
        end
        if @breakable_chart["#{item}"][index] and @breakable_chart["#{item}"][index] != ""
          resulting_row += @breakable_chart["#{item}"][index] + ", "
        end
      end
      resulting_row.chomp!(", ")
      resulting_row += "\r\n"
    rows << resulting_row
    end
    table = create_breakable_ascii_table("Vulnerable #{@actual_monster_name.capitalize} Parts", rows)
    @actual_monster_name = ""
    return table
  else
    @actual_monster_name = ""
    return
  end
end

bot.command(:exit, help_available: false) do |event|
  # This is a check that only allows a user with a specific ID to execute this command. Otherwise, everyone would be
  # able to shut your bot down whenever they wanted.
  break unless event.user.id == 250816303378464770

  bot.send_message(event.channel.id, 'SEE YA BISHES! I\'M OUT!', true)
  exit
end

def create_weakness_ascii_table(title, rows)
  table = "```\r\n" + title + "\r\n------------------------\r\n"
  max_length = 0
  rows.each do |row|
    if max_length < row[0].length
      max_length = row[0].length
    end
  end
  max_length += 5
  rows.each do |row|
    table << row[0] + " " * (max_length - row[0].length) + row[1] + "\r\n"
  end
  table += "```"
  return table
end

def create_breakable_ascii_table(title, rows)
  table = "```" + title + "\r\n------------------------------------\r\n"
  rows.each do |row|
    table << row
  end
  table += "```"
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
