require "./lib/tdk"
require "./spec/lead"
require "selenium-webdriver"
require "yaml"
require "rest-client"

describe "In CRM Application" do

  before :all do

    @credentials = YAML.load_file "./spec/credentials.yaml"

    @browser = Selenium::WebDriver.for :remote, desired_capabilities: :chrome, url: "http://172.21.16.1:4444/wd/hub"
    @browser.manage.timeouts.implicit_wait = 10
    @tdk = Cogburn::TDK.new @browser, @credentials, "https://ap15.salesforce.com"
    
    # launch and login to sf
    @browser.get "https://ap15.salesforce.com"
    @browser.find_element(:css=>"input#username").send_keys "ramankhural@gmail.com"
    @browser.find_element(:css=>"input#password").send_keys "$KaaYoT3"
    @browser.find_element(:css=>"input#Login").click

  end

  after :all do 
    @browser.quit
  end

  context "Create Lead" do

    before :all do
      @lead_data = YAML.load_file "./spec/lead_testdata.yaml"
      @tdk.create "Lead", @lead_data
    end
    
    it "creates a new lead with provided details" do
      @tdk.open "Lead", "#{@lead_data['Last Name']}, #{@lead_data['First Name']}"
    end
    
    context "Convert Lead" do
    
      before :all do
        @lead_data = YAML.load_file "./spec/lead_testdata.yaml"
        @lead_convert_data = YAML.load_file "./spec/lead_convert_testdata.yaml"
        Lead.new(@browser, @tdk, "#{@lead_data['Last Name']}, #{@lead_data['First Name']}")
          .convert(@lead_convert_data)
      end

      it "creates a new opportunity with lead details" do
        @tdk.open "Opportunity", "#{@lead_convert_data['Opportunity Name']}"
      end

      it "creates a new business contact from lead information" do
        @tdk.open "Contact", "#{@lead_data['Last Name']}, #{@lead_data['First Name']}"
      end

      it "created a new business account from company details in lead information" do
        @tdk.open "Account", "#{@lead_data['Company']}"
      end

    end
  end
end
