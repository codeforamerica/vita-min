require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::Documents::Md502R, required_schema: "md" do
  describe ".document" do
    let(:intake) { create(:state_file_md_intake, :with_spouse) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    after do
      expect(build_response.errors).to be_empty
    end

    describe "Age section" do
      let(:primary_birth_date) { Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1) }
      let(:secondary_birth_date) { Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1) }

      before do
        intake.primary_birth_date = primary_birth_date
        intake.spouse_birth_date = secondary_birth_date
      end

      it "should show ages of the filers" do
        expect(xml.at("Form502R PrimaryAge").text.to_i).to eq(65)
        expect(xml.at("Form502R SecondaryAge").text.to_i).to eq(64)
      end
    end

    context "show_retirement_ui" do
      before do
        allow(Flipper).to receive(:enabled?).and_call_original
        allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
      end

      context "disability" do
        context "filers are disabled" do
          before do
            allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_primary_disabled).and_return "X"
            allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_spouse_disabled).and_return "X"
          end

          it "outputs all relevant values" do
            expect(xml.at("Form502R PriTotalPermDisabledIndicator").text).to eq("X")
            expect(xml.at("Form502R SecTotalPermDisabledIndicator").text).to eq("X")
          end
        end

        context "filers are not disabled" do
          it "outputs no values for disabled indicator" do
            expect(xml.at("Form502R PriTotalPermDisabledIndicator")).to be_nil
            expect(xml.at("Form502R SecTotalPermDisabledIndicator")).to be_nil
          end
        end
      end

      context "SourceRetirementIncome section" do
        context "with income" do
          before do
            allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_1a).and_return 100
            allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_1b).and_return 200
            allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_7a).and_return 500
            allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_7b).and_return 333
            allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_8).and_return 1133
          end

          it "outputs all relevant values" do
            expect(xml.at("Form502R SourceRetirementIncome PrimaryTaxPayer EmployeeRetirementSystem").text).to eq("100")
            expect(xml.at("Form502R SourceRetirementIncome PrimaryTaxPayer OtherAndForeign").text).to eq("500")
            expect(xml.at("Form502R SourceRetirementIncome SecondaryTaxPayer EmployeeRetirementSystem").text).to eq("200")
            expect(xml.at("Form502R SourceRetirementIncome SecondaryTaxPayer OtherAndForeign").text).to eq("333")
            expect(xml.at("Form502R SourceRetirementIncome TotalPensionsIRAsAnnuities").text).to eq("1133")
          end
        end

        context "without income" do
          it "should have empty nodes for this section" do
            expect(xml.at("Form502R SourceRetirementIncome PrimaryTaxPayer EmployeeRetirementSystem").text).to eq("0")
            expect(xml.at("Form502R SourceRetirementIncome PrimaryTaxPayer OtherAndForeign").text).to eq("0")
            expect(xml.at("Form502R SourceRetirementIncome SecondaryTaxPayer EmployeeRetirementSystem").text).to eq("0")
            expect(xml.at("Form502R SourceRetirementIncome SecondaryTaxPayer OtherAndForeign").text).to eq("0")
            expect(xml.at("Form502R SourceRetirementIncome TotalPensionsIRAsAnnuities").text).to eq("0")
          end
        end
      end

      context "PriMilLawEnforceIncSub and SecMilLawEnforceIncSub" do
        before do
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_10a).and_return 33
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_10b).and_return 66
        end

        it "should have empty nodes for this section" do
          expect(xml.at("Form502R PriMilLawEnforceIncSub").text).to eq("33")
          expect(xml.at("Form502R SecMilLawEnforceIncSub").text).to eq("66")
        end
      end
    end

    context "show_md_ssa" do
      before do
        allow(Flipper).to receive(:enabled?).and_call_original
        allow(Flipper).to receive(:enabled?).with(:show_md_ssa).and_return(true)
      end

      context "Line 9" do
        before do
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_9a).and_return 100
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_9b).and_return 200
        end
        it "outputs all relevant values" do
          expect(xml.at("Form502R PriSSecurityRailRoadBenefits").text.to_i).to eq(100)
          expect(xml.at("Form502R SecSSecurityRailRoadBenefits").text.to_i).to eq(200)
        end
      end
    end
  end
end
