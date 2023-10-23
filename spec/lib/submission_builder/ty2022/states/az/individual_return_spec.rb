require 'rails_helper'

describe SubmissionBuilder::Ty2022::States::Az::IndividualReturn do
  describe '.build' do
    let(:intake) { create(:state_file_az_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }

    before do
      intake.dependents.create(dob: dob)
    end

    context "when there are dependents" do
      let(:dob) { 12.years.ago }

      context "when a dependent is under 17" do
        it "marks DepUnder17 checkbox as checked" do
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
          under_17_node = xml.at("DepUnder17")
          expect(under_17_node).to be_present
          expect(under_17_node.text).to eq('X')
          expect(xml.at("Dep17AndOlder")).to_not be_present
        end
      end

      context "when a dependent is over 17" do
        let(:dob) { 19.years.ago }

        it "marks Dep17AndOlder checkbox as checked" do
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
          over_17_node = xml.at("Dep17AndOlder")
          expect(over_17_node).to be_present
          expect(over_17_node.text).to eq('X')
          expect(xml.at("DepUnder17")).to_not be_present
        end
      end
    end
  end
end