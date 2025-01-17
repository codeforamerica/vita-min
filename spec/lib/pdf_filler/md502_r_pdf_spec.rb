require "rails_helper"

RSpec.describe PdfFiller::Md502RPdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_md_intake, :with_spouse) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe "#hash_for_pdf" do
    let(:file_path) { described_class.new(submission).output_file.path }
    let(:pdf_fields) { filled_in_values(file_path) }

    before do
      intake.direct_file_data.fed_ssb = 100
    end

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "Part 2: Age" do
      let(:primary_birth_date) { Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1) }
      let(:secondary_birth_date) { Date.new(MultiTenantService.statefile.current_tax_year - 64, 1, 1) }

      before do
        intake.primary_birth_date = primary_birth_date
        intake.spouse_birth_date = secondary_birth_date
      end

      it "output correct information" do
        expect(pdf_fields["Your Age 1"]).to eq("65")
        expect(pdf_fields["Spouses Age"]).to eq("64")
      end
    end
  end
end
