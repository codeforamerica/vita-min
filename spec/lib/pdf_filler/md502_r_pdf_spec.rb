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
      intake.direct_file_data.fed_taxable_pensions = 100
    end

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end
    context "Part 1: Name" do
      let(:primary_ssn) { "100000030" }
      let(:primary_first_name) { "Prim" }
      let(:primary_middle_initial) { "W" }
      let(:primary_last_name) { "Filerton" }

      let(:spouse_ssn) { "100000030" }
      let(:spouse_first_name) { "Rose" }
      let(:spouse_middle_initial) { "B" }
      let(:spouse_last_name) { "Folderton" }

      before do
        intake.primary_first_name = primary_first_name
        intake.primary_middle_initial = primary_middle_initial
        intake.primary_last_name = primary_last_name
        intake.direct_file_data.primary_ssn = primary_ssn

        intake.spouse_first_name = spouse_first_name
        intake.spouse_middle_initial = spouse_middle_initial
        intake.spouse_last_name = spouse_last_name
        intake.direct_file_data.spouse_ssn = spouse_ssn
      end

      it "output correct information" do
        expect(pdf_fields["Your First Name"]).to eq(primary_first_name)
        expect(pdf_fields["Primary MI"]).to eq(primary_middle_initial)
        expect(pdf_fields["Your Last Name"]).to eq(primary_last_name)
        expect(pdf_fields["Your Social Security Number"]).to eq(primary_ssn)

        expect(pdf_fields["Spouses First Name"]).to eq(spouse_first_name)
        expect(pdf_fields["Spouse MI"]).to eq(spouse_middle_initial)
        expect(pdf_fields["Spouses Last Name"]).to eq(spouse_last_name)
        expect(pdf_fields["Spouses Social Security Number"]).to eq(spouse_ssn)
      end
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

      context "Line 9" do
        before do
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_9a).and_return 100
          allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_9b).and_return 200
          allow(Flipper).to receive(:enabled?).and_call_original
          allow(Flipper).to receive(:enabled?).with(:show_md_ssa).and_return(true)
        end

        it "output correct information" do
          expect(pdf_fields["and Tier II See Instructions for Part 5                                   9a"]).to eq("100")
          expect(pdf_fields["9b"]).to eq("200")
        end
      end
    end
  end
end
