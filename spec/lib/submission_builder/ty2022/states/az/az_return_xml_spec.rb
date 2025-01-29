require 'rails_helper'

describe SubmissionBuilder::Ty2022::States::Az::AzReturnXml, required_schema: "az" do
  describe '.build' do
    let(:intake) { create(:state_file_az_intake) }
    let(:submission) { create(:efile_submission, data_source: intake.reload) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
    let(:instance) { described_class.new(submission) }
    let(:build_response) { instance.build }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "generates basic components of return" do
      expect(xml.document.root.namespaces).to include({ "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" })
      expect(xml.document.at('AuthenticationHeader').to_s).to include('xmlns="http://www.irs.gov/efile"')
      expect(xml.document.at('ReturnHeaderState').to_s).to include('xmlns="http://www.irs.gov/efile"')

      expect(build_response.errors).not_to be_present
    end

    it "includes the SpecialProgram node in the RetrunHeaderState" do
      expect(xml.document.at('ReturnHeaderState SpecialProgram').text).to eq "Direct File"
    end

    context "married filing jointly" do
      let(:intake) { create(:state_file_az_intake, filing_status: :married_filing_jointly) }

      it "generates xml" do
        expect(xml.at("FilingStatus").text).to eq('MarriedJoint')
        expect(xml.document.root.namespaces).to include({ "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" })
        expect(xml.document.at('AuthenticationHeader').to_s).to include('xmlns="http://www.irs.gov/efile"')
        expect(xml.document.at('ReturnHeaderState').to_s).to include('xmlns="http://www.irs.gov/efile"')
      end
    end

    context "head of household" do
      let(:intake) do
        create(
          :state_file_az_intake,
          filing_status: :head_of_household,
          raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('az_alexis_hoh'),
          raw_direct_file_intake_data: StateFile::DirectFileApiResponseSampleService.new.read_json('az_alexis_hoh')
        )
      end

      describe '#xml_hoh_qualifying_person' do
        it 'should return nil when there is no matching element' do
          expect(instance.send(:xml_hoh_qualifying_person)).to be_nil
        end

        # TODO: Write tests for when xml exists, when they exist
      end

      describe "#json_xml_qualifying_person" do
        it 'should return a hash when there is a matching json element' do
          response = instance.send(:json_hoh_qualifying_person)
          expect(response).to be_kind_of(Hash)
          expect(response.keys).to eq [:first_name, :last_name]
        end

        it 'should return nil when there is no json' do
          intake.update(raw_direct_file_intake_data: {})
          response = instance.send(:json_hoh_qualifying_person)

          expect(response).to be_nil
        end
      end

      it 'should create the QualChildDependentName' do
        expect(xml.at('QualChildDependentName')).to be_present
        expect(xml.at('QualChildDependentName FirstName').text).to eq 'Axel'
      end
    end

    context "when there are dependents" do
      let(:dob) { 12.years.ago }

      before do
        create(:state_file_dependent, intake: intake, dob: dob, relationship: "biologicalChild")
      end

      it "translates the relationship to the appropriate AZ XML relationship key" do
        expect(xml.at("DependentDetails RelationShip").text).to eq "CHILD"
      end

      context "when a dependent is under 17" do
        it "marks DepUnder17 checkbox as checked" do
          under_17_node = xml.at("DepUnder17")
          expect(under_17_node).to be_present
          expect(under_17_node.text).to eq('X')
          expect(xml.at("Dep17AndOlder")).to_not be_present
        end
      end

      context "when a dependent is over 17" do
        let(:dob) { 19.years.ago }

        it "marks Dep17AndOlder checkbox as checked" do
          over_17_node = xml.at("Dep17AndOlder")
          expect(over_17_node).to be_present
          expect(over_17_node.text).to eq('X')
          expect(xml.at("DepUnder17")).to_not be_present
        end
      end

      context "when a dependent is over 65 and a qualifying parent or grandparent" do
        let(:dob) { MultiTenantService.statefile.end_of_current_tax_year - 65.years }

        before do
          create :state_file_dependent,
                 intake: intake,
                 first_name: "Grammy",
                 last_name: "Grams",
                 dob: dob,
                 ssn: "111111111",
                 needed_assistance: "yes",
                 relationship: "parent",
                 months_in_home: 12
        end

        it "claims dependent in QualParentsAncestors" do
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
              state_income_tax_amount: "700",
              state_wages_amount: "2000",
            )
          }

          it "prioritises state_file_w2s over w2s from the direct file xml, correctly updates & creates & deletes nodes" do
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
      let(:intake) { create(:state_file_az_refund_intake, was_incarcerated: "no", household_excise_credit_claimed: "no") }

      before do
        allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_79).and_return 500
      end

      it "generates FinancialTransaction xml with correct RefundAmt" do
        expect(xml.at("FinancialTransaction")).to be_present
        expect(xml.at("RefundDirectDeposit Amount").text).to eq "500"
      end
    end

    context "when there is a payment owed with banking info" do
      let(:intake) { create(:state_file_az_owed_intake) }

      it "generates FinancialTransaction xml with correct Amount" do
        expect(xml.at("FinancialTransaction")).to be_present
        expect(xml.at("StatePayment PaymentAmount").text).to eq "5"
      end
    end

    context "new df xml" do
      let(:intake) { create(:state_file_az_intake, raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('az_alexis_hoh')) }

      it "does not error" do
        expect(build_response.errors).not_to be_present
      end
    end

    context "when they have made AZ-321 contributions" do
      let(:intake) { create(:state_file_az_intake, :with_az321_contributions) }

      it "generates XML with AZ-321 contributions information" do
        expect(xml.css('Form321').count).to eq 1
        expect(xml.css('CharityInfo').count).to eq 4
        expect(xml.css('ContinuationPages').count).to eq 1

        expect(xml.at('CharityInfo QualCharityContrDate').text).to eq "#{Rails.configuration.statefile_current_tax_year}-08-22"
        expect(xml.at('CharityInfo QualCharityCode').text).to eq '22345'
        expect(xml.at('CharityInfo QualCharity').text).to eq 'Heartland'
        expect(xml.at('CharityInfo QualCharityAmt').text).to eq '506'

        expect(xml.at('TotalCharityAmtContSheet').text).to eq '235'
        expect(xml.at('TotalCharityAmt').text).to eq '1211'
        expect(xml.at('AddCurYrCrAmtTotCshCont').text).to eq '1211'
        expect(xml.at('TxPyrsStatus').text).to eq '470'
        expect(xml.at('TotCshContrFostrChrty').text).to eq '470'
        expect(xml.at('CurrentYrCr').text).to eq '470'
        expect(xml.at('TotalAvailCr').text).to eq '470'
        expect(xml.at('DeductionAmt CreditsFromAZ301').text).to eq '470'
      end
    end

    context "when there are az322s present" do
      let(:intake) { create(:state_file_az_intake, :with_az322_contributions) }

      it "generates XML with contributions data" do
        expect(xml.css('SContribMadeTo').count).to eq 5
        expect(xml.at('SContribMadeTo SchoolContrDate').text).to eq "#{Rails.configuration.statefile_current_tax_year}-03-04"
        expect(xml.at('SContribMadeTo CTDSCode').text).to eq '123456789'
        expect(xml.at('SContribMadeTo SchoolName').text).to eq 'School A'
        expect(xml.at('SContribMadeTo SchoolDist').text).to eq 'District A'
        expect(xml.at('SContribMadeTo Contributions').text).to eq '100'

        expect(xml.at('ContinuationPages')).to be_present
        expect(xml.at('TotalContributionsContSheet').text).to eq '900'
        expect(xml.at('TotalContributions').text).to eq '1500'
        expect(xml.at('SubTotalAmt').text).to eq '1500'
        expect(xml.at('SingleHOH').text).to eq '200'
        expect(xml.at('CurrentYrCr').text).to eq '200'
        expect(xml.at('TotalAvailCr').text).to eq '200'
        expect(xml.at('DeductionAmt CreditsFromAZ301').text).to eq '200'
      end
    end

    context "subtractions" do
      let(:intake) { create(:state_file_az_intake, :df_data_1099_int) }

      it "fills in the lines correctly" do
        intake.direct_file_json_data.interest_reports.first&.interest_on_government_bonds = "2.00"
        expect(xml.css("Subtractions IntUSObligations").text).to eq "2"
      end
    end
  end
end
