require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::NjReturnXml, required_schema: "nj" do
  describe '.build' do
    let(:intake) { create(:state_file_nj_intake) }
    let(:submission) { create(:efile_submission, data_source: intake.reload) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
    let(:build_response) { described_class.build(submission, validate: true) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    after do
      expect(build_response.errors).not_to be_present
    end

    describe "XML schema" do
      context "with JSON data" do
        let(:intake) { create(:state_file_nj_intake, :df_data_mfj) }

        it "fills primary details" do
          expect(xml.document.at('Primary TaxpayerName FirstName').text).to eq("Ernie")
          expect(xml.document.at('Primary TaxpayerName LastName').text).to eq("Muppet")
          expect(xml.document.at('Primary DateOfBirth').text).to eq("1980-01-01")
        end

        it "fills secondary details" do
          expect(xml.document.at('Secondary TaxpayerName FirstName').text).to eq("Bert")
          expect(xml.document.at('Secondary TaxpayerName LastName').text).to eq("Muppet")
          expect(xml.document.at('Secondary DateOfBirth').text).to eq("1990-01-01")
        end
      end

      context "with one dep" do
        let(:intake) { create(:state_file_nj_intake, :df_data_one_dep) }
        it "does not error" do
          builder_response = described_class.build(submission)
          expect(builder_response.errors).not_to be_present
          expect(builder_response.document.at("WagesSalariesTips").text).not_to eq(nil)
          expect(builder_response.document.at("NewJerseyTaxableIncome").text).not_to eq(nil)
        end

        it "fills details from json" do
          expect(xml.document.at('Dependents DependentsName FirstName').text).to eq("Kronos")
          expect(xml.document.at('Dependents DependentsName LastName').text).to eq("Athens")
          expect(xml.document.at('Dependents DependentsSSN').text).to eq("300000029")
          expect(xml.document.at('Dependents BirthYear').text).to eq(Time.now.year.to_s)
        end
      end

      context "with two deps" do
        let(:intake) { create(:state_file_nj_intake, :df_data_two_deps) }
        it "does not error" do
          builder_response = described_class.build(submission)
          expect(builder_response.errors).not_to be_present
        end
      end

      context "with many deps all under 5 yrs old" do
        let(:intake) { create(:state_file_nj_intake, :df_data_many_deps) }

        before do
          five_years = Date.new(MultiTenantService.new(:statefile).current_tax_year - 5, 1, 1)
          intake.synchronize_df_dependents_to_database
          intake.dependents.each do |d| d.update(dob: five_years) end
        end

        it "does not error" do
          builder_response = described_class.build(submission)
          expect(builder_response.errors).not_to be_present
        end
      end

      context "with many w2s" do
        let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }
        it "does not error" do
          builder_response = described_class.build(submission)
          expect(builder_response.errors).not_to be_present
        end
      end

      context "with two w2s" do
        let(:intake) { create(:state_file_nj_intake, :df_data_2_w2s) }
        it "does not error" do
          builder_response = described_class.build(submission)
          expect(builder_response.errors).not_to be_present
        end
      end

    end

    it "generates basic components of return" do
      expect(xml.document.root.namespaces).to include({ "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" })
      expect(xml.document.at('AuthenticationHeader').to_s).to include('xmlns="http://www.irs.gov/efile"')
      expect(xml.document.at('ReturnHeaderState').to_s).to include('xmlns="http://www.irs.gov/efile"')

      expect(build_response.errors).not_to be_present
    end

    it "includes attached documents" do
      expect(xml.document.at('ReturnDataState FormNJ1040 Header')).to be_an_instance_of Nokogiri::XML::Element
    end

    describe "nj 2450" do
      context "with nothing on nj 1040 lines 59 or 61" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
        it "does not include the nj 2450" do
          expect(xml.document.at('FormNJ2450')).to eq(nil)
        end
      end

      context "with excess contributions on line 59" do
        context "mfj with multiple w2s per spouse that individually do not exceed the max and total more than the max for each spouse" do
          let(:intake) { create(:state_file_nj_intake, :df_data_mfj) }
          let(:primary_ssn_from_fixture) { intake.primary.ssn }
          let(:spouse_ssn_from_fixture) { intake.spouse.ssn }
          let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_ui_hc_wd: 100) }
          let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_ui_hc_wd: 101) }
          let!(:w2_3) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_ui_hc_wd: 102) }
          let!(:w2_4) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_ui_hc_wd: 103) }
  
          it "includes two NJ 2450 documents" do
            expect(xml.document.at('FormNJ2450')).to be_an_instance_of Nokogiri::XML::Element
            expect(xml.css('FormNJ2450').count).to eq(2)
          end
        end
      end

      context "with excess contributions on line 61" do
        context "mfj with multiple w2s per spouse that individually do not exceed max and total more than max for each spouse" do 
          let(:intake) { create(:state_file_nj_intake, :df_data_mfj) }
          let(:primary_ssn_from_fixture) { intake.primary.ssn }
          let(:spouse_ssn_from_fixture) { intake.spouse.ssn }
          let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_fli: 100) }
          let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_fli: 101) }
          let!(:w2_3) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_fli: 102) }
          let!(:w2_4) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_fli: 103) }
  
          it "includes two NJ 2450 documents" do
            expect(xml.document.at('FormNJ2450')).to be_an_instance_of Nokogiri::XML::Element
            expect(xml.css('FormNJ2450').count).to eq(2)
          end
        end
      end
    end

    describe "Schedule NJ HCC" do
      context "when user answers no to health insurance question" do
        let(:intake) { create(:state_file_nj_intake, eligibility_all_members_health_insurance: "no") }
        it "does not include the Schedule NJ HCC" do
          expect(xml.document.at('SchNJHCC')).to eq(nil)
        end
      end

      context "when user answers yes to health insurance question" do
        let(:intake) { create(:state_file_nj_intake, eligibility_all_members_health_insurance: "yes") }

        it "includes the Schedule NJ HCC" do
          expect(xml.document.at('SchNJHCC')).to be_an_instance_of Nokogiri::XML::Element
        end

        it "does not error" do
          builder_response = described_class.build(submission)
          expect(builder_response.errors).not_to be_present
        end
      end
    end

    describe "additional dependents PDF" do
      context "when there are more than 4 dependents" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
        let(:nj_return) { described_class.new(submission) }

        before do
          5.times { create :state_file_dependent, intake: intake }
        end

        it "creates an additional dependents pdf" do
          docs = nj_return.send(:supported_documents)
          additional_dependents = docs.select do |d|
            d[:pdf] == PdfFiller::NjAdditionalDependentsPdf
          end
          expect(additional_dependents.present?).to eq true
        end
      end

      context "when there are 4 or fewer dependents" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
        let(:nj_return) { described_class.new(submission) }

        before do
          4.times { create :state_file_dependent, intake: intake }
        end

        it "does not include an additional dependents pdf" do
          docs = nj_return.send(:supported_documents)
          additional_dependents = docs.select do |d|
            d[:pdf] == PdfFiller::NjAdditionalDependentsPdf
          end
          expect(additional_dependents.present?).to eq false
        end
      end
    end

  end
end
