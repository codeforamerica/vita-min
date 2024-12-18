require "rails_helper"

RSpec.describe PdfFiller::Md502SuPdf do
  include PdfSpecHelper
  let(:intake) { create :state_file_md_intake }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe "#hash_for_pdf" do
    let(:file_path) { described_class.new(submission).output_file.path }
    let(:pdf_fields) { filled_in_values(file_path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map { |k| k.to_s.gsub("'", "&apos;").to_s } - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context 'without interest reports' do
      let(:primary_ssn) { "345678901" }
      let(:spouse_ssn) { "987654321" }
      let(:intake) do
        create(
          :state_file_md_intake,
          primary_first_name: "Janet",
          primary_middle_initial: "G",
          primary_last_name: "Jormp",
          spouse_first_name: "Jane",
          spouse_middle_initial: "M",
          spouse_last_name: "Jomp",
          )
      end

      before do
        intake.direct_file_data.primary_ssn = primary_ssn
        intake.direct_file_data.spouse_ssn = spouse_ssn
      end

      it "sets fields to the correct values" do
        expect(pdf_fields["Your First Name"]).to eq "Janet"
        expect(pdf_fields["Text1"]).to eq "G"
        expect(pdf_fields["Your Last Name"]).to eq "Jormp"
        expect(pdf_fields["Your Social Security Number"]).to eq primary_ssn
        expect(pdf_fields["Spouses First Name"]).to eq "Jane"
        expect(pdf_fields["Text2"]).to eq "M"
        expect(pdf_fields["Spouses Last Name"]).to eq "Jomp"
        expect(pdf_fields["Spouses Social Security Number"]).to eq spouse_ssn
        expect(pdf_fields["ab Income from US Government obligations See Instruction 13                         ab"]).to eq("0")
        expect(pdf_fields["appropriate code letters                                            TOTAL  1"]).to eq("0")
      end
    end

    context 'with interest report' do
      let(:intake) { create(:state_file_md_intake, :df_data_1099_int) }
      it "sets fields to the correct values" do
        expect(pdf_fields["Your First Name"]).to eq "Mary"
        expect(pdf_fields["Text1"]).to eq "A"
        expect(pdf_fields["Your Last Name"]).to eq "Lando"
        expect(pdf_fields["Your Social Security Number"]).to eq "123456789"
        expect(pdf_fields["Spouses First Name"]).to eq ""
        expect(pdf_fields["Text2"]).to eq ""
        expect(pdf_fields["Spouses Last Name"]).to eq ""
        expect(pdf_fields["Spouses Social Security Number"]).to eq ""
        expect(pdf_fields["ab Income from US Government obligations See Instruction 13                         ab"]).to eq("2")
        expect(pdf_fields["appropriate code letters                                            TOTAL  1"]).to eq("2")
      end
    end
  end
end
