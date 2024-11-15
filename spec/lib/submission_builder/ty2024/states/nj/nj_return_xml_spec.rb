require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::NjReturnXml, required_schema: "nj" do
  describe '.build' do
    let(:intake) { create(:state_file_nj_intake) }
    let(:submission) { create(:efile_submission, data_source: intake.reload) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
    let(:build_response) { described_class.build(submission) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

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
          expect(xml.document.at('Dependents DependentsName FirstName').text).to eq("KRONOS")
          expect(xml.document.at('Dependents DependentsName LastName').text).to eq("ATHENS")
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
  end
end
