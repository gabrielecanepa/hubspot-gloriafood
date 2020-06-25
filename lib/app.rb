require "dotenv/load"
require "http"

class GloriafoodToHubspot
  GLORIAFOOD_BASE_API_URL = "https://www.gloriafood.com/api".freeze

  def self.run
    response = HTTP.auth(ENV["GLORIAFOOD_API_KEY"])
                   .post("#{GLORIAFOOD_BASE_API_URL}/stats/clients_list")
    clients = JSON.parse(response)
  end
end
