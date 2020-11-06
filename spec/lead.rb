class Lead

  attr_accessor :driver, :tdk, :lead_name

  def initialize driver, tdk, lead_name
    @driver = driver
    @tdk = tdk
    @lead_name = lead_name
  end

  def convert data
    @tdk.open "Lead", @lead_name
    @driver.find_element(:css=>"input[title='Convert']").click
    @driver.find_element(:css=>"input#noopptt").send_keys data['Opportunity Name']
    @driver.find_element(:css=>"input#tsk5_fu").send_keys data['Subject']
    @driver.find_elements(:css=>"select#accid option").each do |option|
      if option.text.start_with? "Create New Account:"
        option.click
        break
      end
    end
    @driver.find_element(:css=>"input[title='Convert']").click
  end
end
