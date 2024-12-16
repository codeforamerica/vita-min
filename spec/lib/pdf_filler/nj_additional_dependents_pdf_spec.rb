require 'rails_helper'

RSpec.describe PdfFiller::NjAdditionalDependentsPdf do
  include PdfSpecHelper

  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:file_path) { described_class.new(submission).output_file.path }
    let(:pdf_fields) { filled_in_values(file_path) }
    let(:intake) { create(:state_file_nj_intake, :df_data_many_deps)}

    before do
      intake.dependents.each_with_index do |dependent, i|
        dependent.update(
          nj_did_not_have_health_insurance: i.odd? ? 'no' : 'yes'
        )
      end
    end

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    it 'fills in name and SSN from XML' do
      expect(pdf_fields["Names(s) as shown on NJ 1040"]).to eq "Thunder Zeus L"
      expect(pdf_fields["Social Security Number"]).to eq "400000015"
    end

    it 'fills dependents from XML after index 4 into the PDF' do
      expect(pdf_fields["Name_Row1"]).to eq "Underworld Hades"
      expect(pdf_fields["SSN_Row1"]).to eq "300000027"
      expect(pdf_fields["BirthYear_Row1"]).to eq "2020"
      expect(pdf_fields["HealthInsurance_Row1"]).to eq "Yes"

      expect(pdf_fields["Name_Row2"]).to eq "Thunder Ares"
      expect(pdf_fields["SSN_Row2"]).to eq "300000022"
      expect(pdf_fields["BirthYear_Row2"]).to eq "2019"
      expect(pdf_fields["HealthInsurance_Row2"]).to eq "Off"

      expect(pdf_fields["Name_Row3"]).to eq "Thunder Hercules"
      expect(pdf_fields["SSN_Row3"]).to eq "300000065"
      expect(pdf_fields["BirthYear_Row3"]).to eq "2018"
      expect(pdf_fields["HealthInsurance_Row3"]).to eq "Yes"

      expect(pdf_fields["Name_Row4"]).to eq "Archer Hermes"
      expect(pdf_fields["SSN_Row4"]).to eq "300000024"
      expect(pdf_fields["BirthYear_Row4"]).to eq "2017"
      expect(pdf_fields["HealthInsurance_Row4"]).to eq "Off"

      expect(pdf_fields["Name_Row5"]).to eq "Thunder Hebe"
      expect(pdf_fields["SSN_Row5"]).to eq "300000023"
      expect(pdf_fields["BirthYear_Row5"]).to eq "2016"
      expect(pdf_fields["HealthInsurance_Row5"]).to eq "Yes"

      expect(pdf_fields["Name_Row6"]).to eq "Wine Dionysus"
      expect(pdf_fields["SSN_Row6"]).to eq "300000068"
      expect(pdf_fields["BirthYear_Row6"]).to eq "2015"
      expect(pdf_fields["HealthInsurance_Row6"]).to eq "Off"

      expect(pdf_fields["Name_Row7"]).to eq ""
      expect(pdf_fields["SSN_Row7"]).to eq ""
      expect(pdf_fields["BirthYear_Row7"]).to eq ""
      expect(pdf_fields["HealthInsurance_Row7"]).to eq "Off"

      expect(pdf_fields["Name_Row8"]).to eq ""
      expect(pdf_fields["SSN_Row8"]).to eq ""
      expect(pdf_fields["BirthYear_Row8"]).to eq ""
      expect(pdf_fields["HealthInsurance_Row8"]).to eq "Off"
    end
  end
end