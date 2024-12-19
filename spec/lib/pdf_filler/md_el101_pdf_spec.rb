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

    before do
      submission.data_source.direct_file_data.primary_ssn = '555123666'
      submission.data_source.primary_esigned_yes!
      submission.data_source.primary_esigned_at = 1.hour.ago
      submission.data_source.primary_signature_pin = '23456'
    end

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map { |k| k.to_s.gsub("'", "&apos;").to_s } - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "when mfj" do
      let(:intake) { create(:state_file_md_intake, :with_spouse) }

      before do
        submission.data_source.direct_file_data.spouse_ssn = '555123456'
        submission.data_source.spouse_esigned_yes!
        submission.data_source.spouse_esigned_at = 1.hour.ago
        submission.data_source.spouse_signature_pin = '11111'
      end

      it "fills out spouse information" do
        expect(pdf_fields["Spouses First Name"]).to eq("Marty")
        expect(pdf_fields["Spouse MI"]).to eq("B")
        expect(pdf_fields["Spouses Last Name"]).to eq("Lando")
        expect(pdf_fields["SSNTaxpayer Identification Number_2"]).to eq("555123456")
        expect(pdf_fields["ERO firm name_2"]).to eq "FileYourStateTaxes"
        expect(pdf_fields["to enter or generate my PIN_2"]).to eq "11111"
        # expect(pdf_fields["Spouses signature 1"]).to eq "Marty B Lando"
        expect(pdf_fields["Date_2"]).to eq Date.today.strftime("%F")
      end
    end

    context "when taxes are owed" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_45).and_return 100
      end

      it "fills out the required fields" do
        expect(pdf_fields["First Name"]).to eq("Mary")
        expect(pdf_fields["Primary MI"]).to eq("A")
        expect(pdf_fields["Last Name"]).to eq("Lando")
        expect(pdf_fields["SSNTaxpayer Identification Number"]).to eq("555123666")
        expect(pdf_fields["2 Amount of overpayment to be refunded to you                                         2"]).to eq("0")
        expect(pdf_fields["3"]).to eq "100"
        expect(pdf_fields["ERO firm name"]).to eq "FileYourStateTaxes"
        expect(pdf_fields["to enter or generate my PIN"]).to eq "23456"
        # expect(pdf_fields["Your signature"]).to eq "On"
        expect(pdf_fields["Date"]).to eq Date.today.strftime("%F")
      end
    end

    context "when there is a refund" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_46).and_return 300
      end

      it "fills out the required fields" do
        expect(pdf_fields["First Name"]).to eq("Mary")
        expect(pdf_fields["Primary MI"]).to eq("A")
        expect(pdf_fields["Last Name"]).to eq("Lando")
        expect(pdf_fields["SSNTaxpayer Identification Number"]).to eq("555123666")
        expect(pdf_fields["2 Amount of overpayment to be refunded to you                                         2"]).to eq "300"
        expect(pdf_fields["3"]).to eq("0")
        expect(pdf_fields["ERO firm name"]).to eq "FileYourStateTaxes"
        expect(pdf_fields["to enter or generate my PIN"]).to eq "23456"
        # expect(pdf_fields["Your signature"]).to eq "On"
        expect(pdf_fields["Date"]).to eq Date.today.strftime("%F")
      end
    end
  end
end


