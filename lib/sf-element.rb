module Cogburn

class SFElement

  attr_accessor :driver, :sobject_describe, :sfobject, :label, :locator, :field

  def initialize driver, sfobject_describe, sfobject, label
    @driver = driver
    @sfobject_describe = sfobject_describe
    @sfobject = sfobject
    @label = label
    @field = Hash.new
    @field['type'] = '~detect'
    begin
      sfobject_describe['fields'].each do |field|
        if(field['label'] == @label)
          @field = field
        end
      end
    rescue
    end
  end

  def value=(value)
    label_elements = @driver.find_elements(:css=>"table.detailList td.labelCol")
    index = 0
    label_elements.each_with_index do |label_element, label_index|
      if(label_element.text.end_with? @label)
        index = label_index 
      end
    end
    field_container = @driver.find_elements(:css=>"table.detailList td.dataCol")[index]
    case @field['type']
    when "string"
      field_container.find_element(:css=>"input").send_keys value
    when "picklist"
      field_container.find_element(:css=>"option[value='#{value}']").click
    when "~detect"
      field_container.find_element(:css=>"input").send_keys value
    end
  end

end # class

end # module
