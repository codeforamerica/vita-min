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
        expect(xml.document.root.namespaces).to include({"xmlns:efile"=>"http://www.irs.gov/efile", "xmlns"=>"http://www.irs.gov/efile"})
        expect(xml.document.at('AuthenticationHeader').to_s).to include('xmlns="http://www.irs.gov/efile"')
        expect(xml.document.at('ReturnHeaderState').to_s).to include('xmlns="http://www.irs.gov/efile"')
      end
    end

    context "when there are dependents" do
      let(:dob) { 12.years.ago }

      before do
        create(:state_file_dependent, intake: intake, dob: dob, relationship: "DAUGHTER")
      end

      it "translates the relationship to the appropriate AZ XML relationship key" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("DependentDetails RelationShip").text).to eq "CHILD"
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

      context "when there are w2s present" do
        it "w2s are copied from the intake" do
          xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
          expect(xml.css('IRSW2').count).to eq 1
          expect(xml.at("IRSW2 EmployeeSSN").text).to eq "555002222"
        end

        context "when the intake has state_file_w2s" do
          let!(:w2) {
            create(
              :state_file_w2,
              state_file_intake: intake,
              w2_index: 0,
              employer_state_id_num: "00123",
              state_income_tax_amt: "700",
              state_wages_amt: "2000",
              )
          }

          it "prioritises state_file_w2s over w2s from the direct file xml, correctly updates & creates & deletes nodes" do
            xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
            expect(xml.css('IRSW2').count).to eq 1
            w2_from_xml = xml.css('IRSW2')[0]
            expect(w2_from_xml.at("EmployerStateIdNum").text).to eq "00123"
            expect(w2_from_xml.at("StateIncomeTaxAmt").text).to eq "700"
            expect(w2_from_xml.at("StateWagesAmt").text).to eq "2000"
          end
        end

      end
    end

    context "when there is a refund with banking info" do
      let(:intake) { create(:state_file_az_refund_intake, was_incarcerated: "no", ssn_no_employment: "no", household_excise_credit_claimed: "no")}
      it "generates FinancialTransaction xml with correct RefundAmt" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("FinancialTransaction")).to be_present
        expect(xml.at("RefundDirectDeposit Amount").text).to eq "475"
      end
    end

    context "when there is a payment owed with banking info" do
      let(:intake) { create(:state_file_az_owed_intake)}
      it "generates FinancialTransaction xml with correct Amount" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("FinancialTransaction")).to be_present
        expect(xml.at("StatePayment PaymentAmount").text).to eq "5"
      end
    end

    context "new df xml" do
      let(:intake) { create(:state_file_az_intake, raw_direct_file_data: StateFile::XmlReturnSampleService.new.read('az_superman')) }

      it "does not error" do
        # xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        builder_response = described_class.build(submission)
        expect(builder_response.errors).not_to be_present
      end
    end
  end
end