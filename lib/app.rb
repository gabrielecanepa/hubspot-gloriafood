# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Style/StringLiterals

require "dotenv/load"
require "http"

class GloriafoodToHubspot
  GLORIAFOOD_API_BASE = "https://www.gloriafood.com/api".freeze
  GLORIAFOOD_API_CLIENTS = "#{GLORIAFOOD_API_BASE}/stats/clients_list".freeze
  HUBSPOT_API_BASE = "https://api.hubapi.com".freeze
  HUBSPOT_API_CONTACTS = "#{HUBSPOT_API_BASE}/contacts/v1".freeze
  HUBSPOT_API_CREATE_OR_UPDATE_CONTACT = "#{HUBSPOT_API_CONTACTS}/contact/createOrUpdate/email".freeze

  def self.run
    clients = JSON.parse(HTTP.auth(ENV["GLORIAFOOD_API_KEY"]).post(GLORIAFOOD_API_CLIENTS))["rows"]
    contacts = clients.map do |client|
      client = client.map { |k, v| { "#{k.gsub('_', '')}": v } }.reduce(:merge)
      client[:lastorder] = Time.parse(client[:lastorder]).to_i
      client[:name] = client[:client]
      client[:phonenumber] = client[:phone]
      client.delete(:client)
      client.delete(:phone)
      client
    end

    contacts.each do |contact|
      properties = []
      contact.each { |k, v| properties << { property: k, value: v } }
      url = "#{HUBSPOT_API_CREATE_OR_UPDATE_CONTACT}/#{contact[:email]}/?hapikey=#{ENV['HUBSPOT_API_KEY']}"
      HTTP.post(url, body: { properties: properties }.to_json)
    end
  end
end
