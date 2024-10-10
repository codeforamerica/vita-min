require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::Documents::Md502, required_schema: "md" do
  describe ".document" do
    let(:intake) { create(:state_file_md_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "generates a valid xml" do
      expect(build_response.errors).to be_empty
    end

    context "exemptions stuff" do
      context "when there are no exemptions" do
        it "omits the whole exemptions section" do
          [
            :get_dependent_exemption_count,
            :calculate_dependent_exemption_amount
          ].each do |method|
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(method).and_return 0
          end

          expect(xml.document.at("Exemptions")).to be_nil
        end
      end

      context "dependents section" do
        before do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:get_dependent_exemption_count).and_return dependent_count
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_dependent_exemption_amount).and_return dependent_exemption_amount
        end

        context "when there are values" do
          let(:dependent_count) { 2 }
          let(:dependent_exemption_amount) { 6400 }

          it "fills out the dependent exemptions correctly" do
            expect(xml.document.at("Exemptions Dependents Count")&.text).to eq dependent_count.to_s
            expect(xml.document.at("Exemptions Dependents Amount")&.text).to eq dependent_exemption_amount.to_s
          end
        end

        context "when there are no values" do
          let(:dependent_count) { 0 }
          let(:dependent_exemption_amount) { 0 }

          it "omits the whole section" do
            expect(xml.document.at("Exemptions Dependents")).to be_nil
          end
        end
      end

      context "exemption amount" do
        before do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_19).and_return exemption_amount
        end

        context "amount is zero" do
          let(:exemption_amount) { 0 }

          it "omits the node" do
            expect(xml.document.at("ExemptionAmount")).to be_nil
          end
        end

        context "amount is positive" do
          let(:exemption_amount) { 3200 }

          it "fills out the dependent exemptions correctly" do
            expect(xml.document.at("ExemptionAmount")&.text).to eq exemption_amount.to_s
          end
        end
      end
    end
  end
end