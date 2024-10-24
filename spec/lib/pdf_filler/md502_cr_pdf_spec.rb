require "rails_helper"

RSpec.describe PdfFiller::Md502CrPdf do
  include PdfSpecHelper
  let(:birth_date) { Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1) }
  let(:intake) { create(:state_file_md_intake, :with_spouse, primary_birth_date: birth_date, spouse_birth_date: birth_date) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe "#hash_for_pdf" do
    before do
      intake.direct_file_data.fed_agi = 100
      intake.direct_file_data.fed_credit_for_child_and_dependent_care_amount = 10
    end
    let(:file_path) { described_class.new(submission).output_file.path }
    let(:pdf_fields) { filled_in_values(file_path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map { |k| k.to_s.gsub("'", "&apos;").to_s } - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    describe "filing status" do
      context 'single' do
        describe 'ssn and names' do
          it "sets correct value for the single filer and leaves it empty for spouse" do
            expect(pdf_fields["Text Field 1"]).to eq(intake.primary.ssn)
            expect(pdf_fields["Text Field 2"]).to eq(intake.spouse.ssn)
            expect(pdf_fields["Text Field 3"]).to eq(intake.primary.first_name)
            expect(pdf_fields["Text Field 4"]).to eq(intake.primary.middle_initial)
            expect(pdf_fields["Text Field 5"]).to eq(intake.primary.last_name)
            expect(pdf_fields["Text Field 6"]).to eq(intake.spouse.first_name)
            expect(pdf_fields["Text Field 7"]).to eq(intake.spouse.middle_initial)
            expect(pdf_fields["Text Field 8"]).to eq(intake.spouse.last_name)
          end
        end

        describe "child care credit" do
          it "fills out the section correctly" do
            expect(pdf_fields["Text Field 27"]).to eq("100")
            expect(pdf_fields["Text Field 115"]).to eq("10")
            expect(pdf_fields["Text Field 29"]).to eq("0.32")
            expect(pdf_fields["Text Field 30"]).to eq("3")
          end
        end

        describe "senior credit section" do
          it "fills out the section correctly" do
            expect(pdf_fields["Text Field 1051"]).to eq("1750")
          end
        end
      end
    end
  end
end
