require 'rails_helper'

primary_test_cases = [
  { employer_name: 'Primary 1', wages: 1000, box14_fli: 90, box14_ui_hc_wd: 100, employer_ein: 710415181 },
  { employer_name: 'Primary 2', wages: 1001, box14_fli: 91, box14_ui_hc_wd: 101, employer_ein: 710415182 },
  { employer_name: 'Primary 3', wages: 1002, box14_fli: 92, box14_ui_hc_wd: 102, employer_ein: 710415183 },
  { employer_name: 'Primary 4', wages: 1003, box14_fli: 93, box14_ui_hc_wd: 103, employer_ein: 710415184 },
  { employer_name: 'Primary 5', wages: 1004, box14_fli: 94, box14_ui_hc_wd: 104, employer_ein: 710415185 },
  { employer_name: 'Primary 6', wages: 1005, box14_fli: 95, box14_ui_hc_wd: 105, employer_ein: 710415186 },
  { employer_name: 'Primary 7', wages: 1006, box14_fli: 96, box14_ui_hc_wd: 106, employer_ein: 710415187 },
]
spouse_test_cases  = [
  { employer_name: 'Spouse 1', wages: 1000, box14_fli: 90, box14_ui_hc_wd: 100, employer_ein: 710415188 },
  { employer_name: 'Spouse 2', wages: 1001, box14_fli: 91, box14_ui_hc_wd: 101, employer_ein: 710415189 },
]

RSpec.describe PdfFiller::Nj2450Pdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_nj_intake, :df_data_mfj) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission, { person: intake.primary }) }
  let(:file_path) { described_class.new(submission, { person: intake.primary }).output_file.path }
  let(:pdf_fields) { filled_in_values(file_path) }
  let(:primary_ssn_from_fixture) { intake.primary.ssn }
  let(:spouse_ssn_from_fixture) { intake.spouse.ssn }
  let(:fake_time) { Time.utc(MultiTenantService.statefile.current_tax_year, 2, 6, 0, 0, 0) }

  primary_test_cases.each.with_index do |test_case, index|
    let!(:"primary_w2_#{index}") { 
      create(
      :state_file_w2,
      state_file_intake: intake,
      employer_name: test_case[:employer_name],
      employer_ein: test_case[:employer_ein],
      wages: test_case[:wages],
      employee_ssn: primary_ssn_from_fixture,
      box14_fli: test_case[:box14_fli],
      box14_ui_hc_wd: test_case[:box14_ui_hc_wd],
      )
    }
  end

  spouse_test_cases.each.with_index do |test_case, index|
    let!(:"spouse_w2_#{index}") { 
      create(
      :state_file_w2,
      state_file_intake: intake,
      employer_name: test_case[:employer_name],
      employer_ein: test_case[:employer_ein],
      wages: test_case[:wages],
      employee_ssn: spouse_ssn_from_fixture,
      box14_fli: test_case[:box14_fli],
      box14_ui_hc_wd: test_case[:box14_ui_hc_wd],
      )
    }
  end

  describe '#hash_for_pdf' do
    context "primary" do

      it "fills in the header fields" do
        expect(pdf_fields["Names as shown on Form NJ1040"]).to eq "Muppet Ernie & Bert K"
        expect(pdf_fields["Social Security Number"]).to eq "400000031"
        expect(pdf_fields["Claimant Name"]).to eq "Muppet Ernie"
        expect(pdf_fields["Claimant SSN"]).to eq "400000031"
        expect(pdf_fields["Address"]).to eq "123 Sesame St Apt 1"
        expect(pdf_fields["City"]).to eq "Hammonton"
        expect(pdf_fields["State"]).to eq "NJ"
        expect(pdf_fields["ZIP Code"]).to eq "85034"
      end
        
      it "enters w2 data for the first 5 w2s" do
        primary_test_cases[0..4].each.with_index do |test_case, index|
          pdf_keys = described_class::W2_PDF_KEYS[index]
          expect(pdf_fields[pdf_keys[:employer_name]]).to eq test_case[:employer_name]
          expect(pdf_fields[pdf_keys[:employer_ein]]).to eq test_case[:employer_ein].to_s
          expect(pdf_fields[pdf_keys[:wages]]).to eq test_case[:wages].to_s
          expect(pdf_fields[pdf_keys[:column_a]]).to eq test_case[:box14_ui_hc_wd].to_s
          expect(pdf_fields[pdf_keys[:column_c]]).to eq test_case[:box14_fli].to_s
        end
      end
        
      it "enters the correct totals when summing remaining pdfs" do
        expect(pdf_fields["If additional space is required enclose a rider and enter the total on this line"]).to eq "211"
        expect(pdf_fields["3If additional space is required enclose a rider and enter the total on this line"]).to eq "191"
      end

      
      it "enters the date" do
        Timecop.freeze(fake_time) do
          expect(pdf_fields["Date"]).to eq "2/5/2023"
        end
      end

      it "enters the correct total for column a" do
        expect(pdf_fields["Total Deducted Add lines 1A through 1F Enter here"]).to eq "721"
      end

      it "enters the correct total for column c" do
        expect(pdf_fields["3Total Deducted Add lines 1A through 1F Enter here"]).to eq "651"
      end

      it "enters the correct difference for column a" do
        expect(pdf_fields["14620Subtract line 3 column A from line 2 column A Enter on line 58 of the NJ1040"]).to eq "541"
      end

      it "enters the correct difference for column c" do
        expect(pdf_fields["2752Subtract line 3 column C from line 2 column C Enter on line 60 of the NJ1040"]).to eq "506"
      end
    end

    context "spouse" do
      let(:pdf) { described_class.new(submission, { person: intake.spouse }) }
      let(:file_path) { described_class.new(submission, { person: intake.spouse }).output_file.path }

      it "fills in the header fields" do
        expect(pdf_fields["Names as shown on Form NJ1040"]).to eq "Muppet Ernie & Bert K"
        expect(pdf_fields["Social Security Number"]).to eq "400000031"
        expect(pdf_fields["Claimant Name"]).to eq "Muppet Bert K"
        expect(pdf_fields["Claimant SSN"]).to eq "123456789"
        expect(pdf_fields["Address"]).to eq "123 Sesame St Apt 1"
        expect(pdf_fields["City"]).to eq "Hammonton"
        expect(pdf_fields["State"]).to eq "NJ"
        expect(pdf_fields["ZIP Code"]).to eq "85034"
      end

      it "fills w2 data" do
        spouse_test_cases.each.with_index do |test_case, index|
          pdf_keys = described_class::W2_PDF_KEYS[index]
          expect(pdf_fields[pdf_keys[:employer_name]]).to eq test_case[:employer_name]
          expect(pdf_fields[pdf_keys[:employer_ein]]).to eq test_case[:employer_ein].to_s
          expect(pdf_fields[pdf_keys[:wages]]).to eq test_case[:wages].to_s
          expect(pdf_fields[pdf_keys[:column_a]]).to eq test_case[:box14_ui_hc_wd].to_s
          expect(pdf_fields[pdf_keys[:column_c]]).to eq test_case[:box14_fli].to_s
        end
      end

      it "leaves fields empty when there is no w2 data" do
        described_class::W2_PDF_KEYS[2..].each do |pdf_keys|
          pdf_keys.each do |key|
            expect(pdf_fields[key]).to eq nil
          end
        end
      end
        
      it "does not enter additional w2 sums when there are none" do
        expect(pdf_fields["If additional space is required enclose a rider and enter the total on this line"]).to eq ""
        expect(pdf_fields["3If additional space is required enclose a rider and enter the total on this line"]).to eq ""
      end
    end
  end
end