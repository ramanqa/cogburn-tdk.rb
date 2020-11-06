require "./lib/sf-api"
require "./lib/sf-element"

module Cogburn

class TDK

    attr_accessor :driver, :credentials, :sf_app_domain, :sfapi

    def initialize driver, credentials, sf_app_domain
      @driver = driver
      @credentials = credentials
      @sf_app_domain = sf_app_domain
      @sfapi = Cogburn::SFAPI.new @credentials, @sf_app_domain
    end

    def create object, data
      @driver.get(@sfapi.object_describe(object)['urls']['uiNewRecord'])
      fill object, data
      form_button("Save").click
    end

    def action object, name, action, data
      open object, name
      form_button(action).click
      fill object, data
      form_button(action).click
    end

    def open object, name
      @driver.get("#{@sf_app_domain}/#{@sfapi.object_key(object)}/o")
      @driver.find_element(:link_text=>name).click
    end

    def fill object, data
      data.each do |key, value|
        SFElement.new(@driver, @sfapi.object_describe(object), object, key).value = value
      end
    end

    def form_button title
      @driver.find_element(:css=>"input[title='#{title}']")
    end
 
end # class

end # module
