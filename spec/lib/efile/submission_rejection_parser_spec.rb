require "rails_helper"

describe Efile::SubmissionRejectionParser do
  let(:raw_response) { file_fixture("irs_acknowledgement_rejection.xml").read }

  describe '#to_xml' do
    it 'outputs the raw response to a Nokogiri XML document' do
      obj = Efile::SubmissionRejectionParser.new(raw_response)
      expect(obj.to_xml).to be_an_instance_of Nokogiri::XML::Document
    end
  end

  describe "#errors" do
    it "provides error object responses for each error" do
      obj = Efile::SubmissionRejectionParser.new(raw_response)
      expect(obj.errors.length).to eq 2
      expect(obj.errors.first).to be_an_instance_of Efile::Error
    end
  end
end