require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::NjReturnXml, required_schema: "nj" do
  describe '.build' do
    let(:intake) { create(:state_file_nj_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
    let(:xml) { Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml) }

    describe "XML schema" do

      context "with one dep" do
        let(:intake) { create(:state_file_nj_intake, municipality_code: "0101", raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_zeus_one_dep')) }
        it "does not error" do
          builder_response = described_class.build(submission)
          expect(builder_response.errors).not_to be_present
        end
      end

      context "with two deps" do
        let(:intake) { create(:state_file_nj_intake, municipality_code: "0101", raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_zeus_two_deps')) }
        it "does not error" do
          builder_response = described_class.build(submission)
          expect(builder_response.errors).not_to be_present
        end
      end

      context "with many deps" do
        let(:intake) { create(:state_file_nj_intake, municipality_code: "0101", raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_zeus_many_deps')) }
        it "does not error" do
          builder_response = described_class.build(submission)
          expect(builder_response.errors).not_to be_present
        end
      end

      context "with many w2s" do
        let(:intake) { create(:state_file_nj_intake, municipality_code: "0101", raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_zeus_many_w2s')) }
        it "does not error" do
          builder_response = described_class.build(submission)
          expect(builder_response.errors).not_to be_present
        end
      end

      context "with two w2s" do
        let(:intake) { create(:state_file_nj_intake, municipality_code: "0101", raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml('nj_zeus_two_w2s')) }
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
    end

    it "includes attached documents" do
      expect(xml.document.at('ReturnDataState FormNJ1040 Header')).to be_an_instance_of Nokogiri::XML::Element
    end
  end
end
