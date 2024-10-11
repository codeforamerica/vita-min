# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfFiller::Id40Pdf do
  include PdfSpecHelper

  let!(:intake) {
    create(:state_file_id_intake,
           :single_filer_with_json, # includes phone number data
           primary_esigned: "yes",
           primary_esigned_at: DateTime.now)
  }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(described_class.new(submission).output_file.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "when filer signed submission agreement" do
      it 'sets signature date field to the correct value' do
        expect(pdf_fields["DateSign 2"]).to eq DateTime.now.strftime("%m-%d-%Y")
        expect(pdf_fields["TaxpayerPhoneNo"]).to eq "2085551234"
      end
    end
  end
end
