require 'rails_helper'

RSpec.describe PdfFiller::Ny214Pdf do
  include PdfSpecHelper

  let(:intake) do
    create(
      :state_file_ny_intake,
      household_rent_own: 'own',
      household_own_propety_tax: 4000,
      household_own_assessments: 22
    )
  end
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  before do
    intake.direct_file_data.fed_agi = 2500
    intake.direct_file_data.fed_unemployment = 500
    intake.direct_file_data.fed_taxable_ssb = 400
    intake.direct_file_data.fed_wages = 900
  end

  describe 'field mappings' do
    it "uses the available options from the PDF" do
      field_defs = PdfForms.new(utf8_fields: true).get_fields(File.open(Rails.root.join('app', 'lib', 'pdfs', "#{pdf.source_pdf_name}.pdf")).path)

      described_class::FIELD_OPTIONS.each do |pdf_field_name, ruby_field_options|
        file_field_options = field_defs.find { |d| d.name == pdf_field_name }.options

        expect(ruby_field_options.values).to match_array(file_field_options - ["Off"])
      end
    end
  end

  # We aren't supporting IT-214 currently so the generated submission will never contain the values these tests expect
  # We should reinstate these tests if we ever add IT-214 support back in.
  # describe '#hash_for_pdf' do
  #   let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }
  #
  #   it 'uses field names that exist in the pdf' do
  #     missing_fields = pdf.hash_for_pdf.keys.map { |k| k.gsub("'", "&apos;").to_s } - pdf_fields.keys
  #     expect(missing_fields).to eq([])
  #   end
  #
  #   context "when the household are homeowners" do
  #     it 'calculates the IT214 lines correctly' do
  #       expect(pdf_fields['19 dollars14']).to eq ""
  #       expect(pdf_fields['27 dollars14']).not_to be_nil
  #     end
  #   end
  #
  #   context 'when the household rents' do
  #     before do
  #       intake.household_rent_own = 'rent'
  #       intake.household_rent_amount = 4800
  #       intake.household_rent_adjustments = 4800
  #     end
  #
  #     it 'calculates the IT214 lines correctly' do
  #       expect(pdf_fields['19 dollars14']).not_to be_nil
  #       expect(pdf_fields['27 dollars14']).to eq ""
  #     end
  #   end
  # end
end
