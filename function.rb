require "net/http"
require 'json'

METRO_ENDPOINT = "https://api.tokyometroapp.jp/api/v2"

def get_line_info(line_name = nil)
    q = {
        "rdf:type": "odpt:TrainInformation",
        "acl:consumerKey": ENV["TOKYO_METRO_ACCESS_KEY"]
    }
    q["odpt:railway"] = line_name if line_name

    uri = URI.parse(METRO_ENDPOINT + "/datapoints")
    uri.query = URI.encode_www_form(q)

    JSON.parse(Net::HTTP.get(uri))
end