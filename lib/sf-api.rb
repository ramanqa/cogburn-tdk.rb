require "restclient"
require "json"
require "./lib/sf-element"

module Cogburn

class SFAPI

    attr_accessor :credentials
    attr_accessor :sf_app_domain
    attr_accessor :path, :token

    def initialize credentials, sf_app_domain
        @credentials = credentials
        @credentials.transform_keys!(&:to_sym)
        @sf_app_domain = sf_app_domain
        @path = @sf_app_domain + version
        @token = new_token
    end

    def new_token
      response = RestClient.post @sf_app_domain + "/services/oauth2/token", 
          {
            "grant_type":"password",
            "client_id":@credentials[:client_id],
            "client_secret":@credentials[:client_secret],
            "username":@credentials[:username],
            "password":"#{@credentials[:password]}#{@credentials[:security_token]}"
          }, headers={"Content-Type":"application/x-www-form-urlencoded"}
      JSON.parse(response.body)['access_token']
    end

    def version
      response = RestClient.get @sf_app_domain + "/services/data/", headers={"Content-Type": "application/json"}
      JSON.parse(response.body).last['url']
    end

    def object_key object
      response = RestClient.get @path + "/sobjects/" + object,
          headers={
            "Authorization":"Bearer #{@token}",
            "Content-Type":"application/json"
          }
      JSON.parse(response.body)["objectDescribe"]["keyPrefix"]
    end

    def object_describe object
      response = RestClient.get @path + "/sobjects/" + object + "/describe",
        headers={
            "Authorization":"Bearer #{@token}",
            "Content-Type":"application/json"
          }
      JSON.parse(response.body)
    end

    def create driver, object, data
      driver.get("#{@sf_app_domain}/#{object_key(object)}/e")
      fill driver, object, data
      driver.find_element(:css=>"input[title='Save']").click
    end

    def fill driver, object, data
      data.each do |key, value|
        SFElement.new(driver, object_describe(object), object, key).value = value
      end
    end

end # class

end # module
