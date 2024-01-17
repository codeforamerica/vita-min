require 'rails_helper'

RSpec.describe StateFile::XmlReturnSampleService do
  context 'XML samples must be valid for current schema' do
    schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2023v5.0", "IndividualIncomeTax", "Ind1040", "Return1040.xsd")
    schema = Nokogiri::XML::Schema(File.open(schema_file))
    folder = File.join(Rails.root, "spec", "fixtures", "files")
    Dir.entries(folder).select do |f|
      context "#{f}" do
        it "should have no errors" do
          if f.starts_with?("fed_")
            f = File.join(folder, f)
            if File.file? f
              xml = Nokogiri::XML(File.open(f))
              errors = schema.validate(xml)
              expect(errors).to be_empty
            end
          end
        end
      end
    end
  end
end