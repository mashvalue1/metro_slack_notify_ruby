require "net/http"
require 'json'
require "yaml"

METRO_ENDPOINT = "https://api.tokyometroapp.jp/api/v2"
LINE_PARAMS = YAML.load_file(File.join(__dir__, "./line_params.yml"))
LINE_NAMES = YAML.load_file(File.join(__dir__, "./line_names.yml"))

def lambda_handler(event:, context:)
  line_name = ENV["TARGET_LINE"]
  line_info = get_line_info(line_name)
  data = line_info.map do |line|
    "#{LINE_NAMES[line['odpt:railway']]} : #{line['odpt:trainInformationText']}"
  end.join("\n")

  uri = URI.parse(ENV["SLACK_URL"])
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.post(uri.path, { text: data }.to_json)
end

def get_line_info(line_name = nil)
  q = {
      "rdf:type": "odpt:TrainInformation",
      "acl:consumerKey": ENV['TOKYO_METRO_ACCESS_KEY']
  }

  if LINE_PARAMS.keys.include? line_name
    q["odpt:railway"] = LINE_PARAMS[line_name]
  end

  uri = URI.parse(METRO_ENDPOINT + "/datapoints")
  uri.query = URI.encode_www_form(q)
  JSON.parse(Net::HTTP.get(uri))
end