require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::Documents::Md502R, required_schema: "md" do
  describe ".document" do
    let(:intake) { create(:state_file_md_intake, :with_spouse) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "generates a valid xml" do
      expect(build_response.errors).to be_empty
    end

    describe ".document" do
      let(:primary_birth_date) { Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1) }
      let(:secondary_birth_date) { Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1) }

      before do
        intake.primary_birth_date = primary_birth_date
        intake.spouse_birth_date = secondary_birth_date
      end

      it "Age section" do
        expect(xml.at("Form502R PrimaryAge").text.to_i).to eq(65)
        expect(xml.at("Form502R SecondaryAge").text.to_i).to eq(64)
      end
    end
  end
end
