require 'rails_helper'

describe SubmissionBuilder::Ty2022::States::Az::IndividualReturn do
  describe '.build' do
    let(:intake) { create(:state_file_az_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }

    context "married filing jointly" do
      let(:intake) { create(:state_file_az_intake, filing_status: :married_filing_jointly) }

      it "generates xml" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("FilingStatus").text).to eq('MarriedJoint')
      end
    end

    context "when there are dependents" do
      let(:dob) { 12.years.ago }

      before do
        intake.dependents.create(dob: dob)
      end

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

      context "when a dependent is over 65 and a qualifying parent or grandparent" do
        let(:dob) { MultiTenantService.statefile.end_of_current_tax_year - 65.years }

        before do
          intake.dependents.create(
            first_name: "Grammy",
            last_name: "Grams",
            dob: dob,
            ssn: "111111111",
            needed_assistance: "yes",
            relationship: "PARENT",
            months_in_home: 12
          )
        end

        it "claims dependent in QualParentsAncestors" do
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
          qual_ancestors = xml.at("QualParentsAncestors")
          expect(qual_ancestors).to be_present
          expect(qual_ancestors.at("Name FirstName").text).to eq "Grammy"
          expect(qual_ancestors.at("Name LastName").text).to eq "Grams"
          expect(qual_ancestors.at("DependentSSN").text).to eq "111111111"
          expect(qual_ancestors.at("RelationShip").text).to eq "PARENT"
          expect(qual_ancestors.at("NumMonthsLived").text).to eq "12"
          expect(qual_ancestors.at("IsOverSixtyFive").text).to eq "X"
          expect(qual_ancestors.at("DiedInTaxYear")).to_not be_present
        end
      end
    end
  end
end