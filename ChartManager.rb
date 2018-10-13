require 'HTTParty'
require 'nokogiri'
require 'json'
require 'logger'
require_relative 'JsonFileManager.rb'

class ChartManager

attr_accessor :parse_page
attr_accessor :logger

@@weakness_chart = Hash.new { |hash, key| hash[key] = [] }
@@breakable_chart = Hash.new { |hash, key| hash[key] = [] }
@@charts_exist = false
@@weakness_chart_file = 'Charts/weakness_chart.json'
@@breakable_chart_file = 'Charts/breakable_chart.json'

def initialize(log)
    @logger ||= log
    if File.file?(@@weakness_chart_file) && File.file?(@@breakable_chart_file)
       logger.info( "Charts exist. Loading...")
        @@charts_exist = true
        filemanager = JsonFileManager.new
        @@weakness_chart = filemanager.load_json_file(@@weakness_chart_file)
        @@breakable_chart = filemanager.load_json_file(@@breakable_chart_file)
    elsif
       logger.info( "Charts not found. Creating charts.")
        create_charts
       logger.info( "Charts created. Saving charts.")
       Dir.mkdir('Charts') unless Dir.exist?('Charts')
        filemanager = JsonFileManager.new
        filemanager.write_json_file(@@weakness_chart_file, @@weakness_chart)
        filemanager.write_json_file(@@breakable_chart_file, @@breakable_chart)
       logger.info( "Charts saved.")
    end
end

def create_charts
    doc = HTTParty.get("https://teambrg.com/monster-hunter-world/mhw-monster-elemental-weakness-table/")
    @parse_page ||= Nokogiri::HTML(doc)
    @num_of_columns = table_row_header_container.children.length
    @num_of_rows = table_rows_container.length
    create_weakness_chart
end

def get_weakness_chart
    @@weakness_chart
end

def get_breakable_chart
    @@breakable_chart
end

private
@num_of_columns = 0
@num_of_rows = 0
@@j = 0

def create_weakness_chart
   logger.info( "Creating weakness chart...")
    i = 0
    k = 0
    while @@j < @num_of_rows do
        while i < @num_of_columns do
            if table_rows_container[k].children[i].text == "\n"
                k += 1
            end
            if table_rows_container[@@j].children[k].text.empty?
               logger.info( "Done creating weakness chart. Creating breakable chart...")
                @@j += 1
                create_breakable_chart
               logger.info( "Done creating breakable chart.")
                return
            end
            @@weakness_chart[table_row_header_container[i].text.downcase] << table_rows_container[@@j].children[k].text.downcase.gsub(/\s/,'').gsub('-','')
            i += 1
            k += 1
        end
        i = 0
        k = 0
        @@j += 1
    end
end

def create_breakable_chart
    i = 0
    k = 0
    while @@j < @num_of_rows do
        while i < @num_of_columns do
            if table_rows_container[k].children[i].text == "\n"
                k += 1
            end
            @@breakable_chart[i] << table_rows_container[@@j].children[k].text.downcase
            i += 1
            k += 1
        end
        i = 0
        k = 0
        @@j += 1
    end
end

    def table_row_header_container
        parse_page.css('//*[@id=\"tablepress-116\"]/thead/tr/th')
    end

    def table_rows_container
        parse_page.css('//*[@id="tablepress-116"]/tbody/tr')
    end

end
