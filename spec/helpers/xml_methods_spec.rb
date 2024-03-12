require 'rails_helper'

describe XmlMethods do
  describe "#delete_blank_nodes" do
    it "deletes nodes" do
      content = <<~XML
        <outer>
          <inner1></inner1>
          <inner2>0</inner2>
          <inner3>1</inner3>
          <inner4/>
        </outer>
      XML
      xml = Nokogiri::XML(content)
      Class.new.extend(XmlMethods).delete_blank_nodes(xml)
      result = "<?xml version=\"1.0\"?>\n<outer>\n  <inner3>1</inner3>\n</outer>\n"
      expect(xml.to_xml).to eq result
    end
  end
end
