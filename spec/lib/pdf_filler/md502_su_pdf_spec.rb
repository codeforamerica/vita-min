require "rails_helper"

RSpec.describe PdfFiller::Md502SuPdf do
  include PdfSpecHelper
  let(:intake) { create :state_file_md_intake }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  before do
    intake.direct_file_data.primary_ssn = primary_ssn
    intake.direct_file_data.spouse_ssn = spouse_ssn
    allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_ab).and_return 100
    allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_u).and_return 100
    allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_v).and_return 100
  end

  describe "#hash_for_pdf" do
    let(:file_path) { described_class.new(submission).output_file.path }
    let(:pdf_fields) { filled_in_values(file_path) }

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
    let(:spouse_ssn) { "987654321" }
    let(:primary_ssn) { "345678901" }
    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map { |k| k.to_s.gsub("'", "&apos;").to_s } - pdf_fields.keys
      expect(missing_fields).to eq([])
    end


    it "sets fields to the correct values" do
      expect(pdf_fields["Your First Name"]).to eq "Janet"
      expect(pdf_fields["Text1"]).to eq "G"
      expect(pdf_fields["Your Last Name"]).to eq "Jormp"
      expect(pdf_fields["NAME_2"]).to eq "Jormp"
      expect(pdf_fields["NAME"]).to eq "Jormp"
      expect(pdf_fields["Your Social Security Number"]).to eq primary_ssn
      expect(pdf_fields["SSN"]).to eq primary_ssn
      expect(pdf_fields["SSN_2"]).to eq primary_ssn
      expect(pdf_fields["Spouses First Name"]).to eq "Jane"
      expect(pdf_fields["Text2"]).to eq "M"
      expect(pdf_fields["Spouses Last Name"]).to eq "Jomp"
      expect(pdf_fields["Spouses Social Security Number"]).to eq spouse_ssn
      expect(pdf_fields["ab Income from US Government obligations See Instruction 13                         ab"]).to eq("100")
      expect(pdf_fields["retirement income received in the taxable year                                     u"]).to eq("100")
      expect(pdf_fields["v"]).to eq("100")
      expect(pdf_fields["appropriate code letters                                                  TOTAL 1"]).to eq("300")
    end
  end
end
