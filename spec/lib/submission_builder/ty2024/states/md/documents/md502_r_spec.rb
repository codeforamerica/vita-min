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

      context "Line 9" do
        before do
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_9a).and_return 100
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_9b).and_return 200
          allow(Flipper).to receive(:enabled?).and_call_original
          allow(Flipper).to receive(:enabled?).with(:show_md_ssa).and_return(true)
        end
        it "outputs all relevant values" do
          expect(xml.at("Form502R PriSSecurityRailRoadBenefits").text.to_i).to eq(100)
          expect(xml.at("Form502R SecSSecurityRailRoadBenefits").text.to_i).to eq(200)
        end
      end
    end
  end
end
