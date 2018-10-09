require 'json'

class JsonFileManager

def load_json_file(filename)
  file = File.read(filename)
  return JSON.parse(file)
end

def write_json_file(filename, content)
  File.open(filename, "w") do |f|
    f.write(JSON.pretty_generate(content))
  end
end

end
