require "rails_helper"

RSpec.describe PdfFiller::MdEl101Pdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_md_intake) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe "#hash_for_pdf" do
    let(:file_path) { described_class.new(submission).output_file.path }
    let(:pdf_fields) { filled_in_values(file_path) }
    let(:intake) { create(:state_file_md_intake) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map { |k| k.to_s.gsub("'", "&apos;").to_s } - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "when taxes are owed" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_45).and_return 100
      end

      it 'outputs the amount owed' do
        expect(pdf_fields["3"]).to eq "100"
      end
    end

    context "when there is a refund" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_46).and_return 300
      end

      it 'outputs the amount to be refunded' do
        expect(pdf_fields["2 Amount of overpayment to be refunded to you                                         2"]).to eq "300"
      end
    end
  end
end


