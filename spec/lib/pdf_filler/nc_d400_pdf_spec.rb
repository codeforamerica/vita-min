require 'rails_helper'

RSpec.describe PdfFiller::NcD400Pdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_nc_intake) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }
  before do
    intake.synchronize_df_w2s_to_database
  end

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "pulling fields from xml" do
      let(:intake) {
        create(:state_file_nc_intake,
               filing_status: "single",
               primary_last_name: "Carolinianian",
               untaxed_out_of_state_purchases: "no",
               primary_esigned: "yes",
               primary_esigned_at: DateTime.now)
      }

      context "single filer" do
        it 'sets static fields to the correct values' do
          expect(pdf_fields['y_d400wf_datebeg']).to eq '01-01'
          expect(pdf_fields['y_d400wf_dateend']).to eq "12-31-#{Rails.configuration.statefile_current_tax_year.to_s[-2..-1]}"
          expect(pdf_fields['y_d400wf_rs1yes']).to eq 'Yes'
          expect(pdf_fields['y_d400wf_rs2yes']).to eq 'Off'
          expect(pdf_fields['y_d400wf_county']).to eq 'Alama'
          expect(pdf_fields['y_d400wf_fedex1no']).to eq 'Yes'
        end

        it "sets other fields to the correct values" do
          expect(pdf_fields['y_d400wf_fname1']).to eq 'North'
          expect(pdf_fields['y_d400wf_mi1']).to eq 'A'
          expect(pdf_fields['y_d400wf_lname1']).to eq 'Carolinianian'
          expect(pdf_fields['y_d400wf_ssn1']).to eq '400000030'
          expect(pdf_fields['y_d400wf_add']).to eq '123 Red Right Hand St Apt 1'
          expect(pdf_fields['y_d400wf_apartment number']).to eq 'Apt 1'
          expect(pdf_fields['y_d400wf_city']).to eq 'Raleigh'
          expect(pdf_fields['y_d400wf_state']).to eq 'NC'
          expect(pdf_fields['y_d400wf_zip']).to eq '27513'

          expect(pdf_fields['y_d400wf_fstat1']).to eq 'Yes'
          expect(pdf_fields['y_d400wf_fstat2']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat3']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat4']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat5']).to eq 'Off'

          expect(pdf_fields['y_d400wf_li6_good']).to eq '9000'
          expect(pdf_fields['y_d400wf_li8_good']).to eq '9000'
          expect(pdf_fields['y_d400wf_ncstandarddeduction']).to eq 'Yes'
          expect(pdf_fields['y_d400wf_li11_page1_good']).to eq '12750'

          expect(pdf_fields['y_d400wf_lname2_PG2']).to eq 'Carolinian'
          expect(pdf_fields['y_d400wf_li20a_pg2_good']).to eq '15'
          expect(pdf_fields['y_d400wf_li23_pg2_good']).to eq '15'
          expect(pdf_fields['y_d400wf_li25_pg2_good']).to eq '15'
          expect(pdf_fields['y_d400wf_dayphone']).to eq '9845559876'
          expect(pdf_fields['y_d400wf_Consumer_Use_Tax']).to eq 'Yes'
          expect(pdf_fields['y_d400wf_li18_pg2_good']).to eq '0'
          expect(pdf_fields['y_d400wf_li19_pg2_good']).to eq '0'
          expect(pdf_fields['y_d400wf_li26a_pg2_good']).to eq ''
          expect(pdf_fields['y_d400wf_li27_pg2_good']).to eq '0'
          expect(pdf_fields['y_d400wf_li28_pg2_good']).to eq '15'
          expect(pdf_fields['y_d400wf_li34_pg2_good']).to eq '15'
          expect(pdf_fields['y_d400wf_sigdate']). to eq DateTime.now.strftime('%Y-%m-%d')
          expect(pdf_fields['y_d400wf_sigdate2']). to eq ""
        end

        context "CTC & cascading fields" do
          let(:intake) { create(:state_file_nc_intake, filing_status: "single", raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml("nc_shiloh_hoh")) }
          let(:child_deduction) { 2000 }
          let(:nc_agi_addition) { 8000 }
          let(:nc_agi_subtraction) { 7000 }
          let(:income_tax) { 70 }
          before do
            intake.direct_file_data.qualifying_children_under_age_ssn_count = 5
            allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_10b).and_return child_deduction
            allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_12a).and_return nc_agi_addition
            allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_12b).and_return nc_agi_subtraction
            allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_15).and_return income_tax
          end

          it "sets the correct values" do
            expect(pdf_fields["y_d400wf_li10a_good"]).to eq "5"
            expect(pdf_fields["y_d400wf_li10b_good"]).to eq child_deduction.to_s
            expect(pdf_fields["y_d400wf_li12a_pg1_good"]).to eq nc_agi_addition.to_s
            expect(pdf_fields["y_d400wf_li12b_pg1_good"]).to eq nc_agi_subtraction.to_s
            expect(pdf_fields["y_d400wf_li14_pg1_good"]).to eq nc_agi_subtraction.to_s
            expect(pdf_fields["y_d400wf_li15_pg1_good"]).to eq income_tax.to_s
            expect(pdf_fields["y_d400wf_li17_pg2_good"]).to eq income_tax.to_s
          end
        end
      end

      context "mfj filers" do
        let(:intake) { create(:state_file_nc_intake, :with_spouse, filing_status: "married_filing_jointly", primary_esigned: "yes", primary_esigned_at: DateTime.now, spouse_esigned: "yes", spouse_esigned_at: DateTime.now)}

        before do
          submission.data_source.direct_file_data.spouse_date_of_death = "2024-09-30"
          submission.data_source.direct_file_data.w2s[0].EmployeeSSN = submission.data_source.spouse.ssn
          intake.synchronize_df_w2s_to_database
        end

        it 'sets static fields to the correct values' do
          expect(pdf_fields['y_d400wf_datebeg']).to eq '01-01'
          expect(pdf_fields['y_d400wf_dateend']).to eq "12-31-#{Rails.configuration.statefile_current_tax_year.to_s[-2..-1]}"
          expect(pdf_fields['y_d400wf_rs2yes']).to eq 'Yes'
        end

        it "sets fields specific to filing status" do
          expect(pdf_fields['y_d400wf_fname2']).to eq 'Susie'
          expect(pdf_fields['y_d400wf_mi2']).to eq 'B'
          expect(pdf_fields['y_d400wf_lname2']).to eq 'Spouse'
          expect(pdf_fields['y_d400wf_ssn2']).to eq '600000030'
          expect(pdf_fields['y_d400wf_dead2']).to eq '09-30-24'

          expect(pdf_fields['y_d400wf_fstat2']).to eq 'Yes'
          expect(pdf_fields['y_d400wf_fstat1']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat3']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat4']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat5']).to eq 'Off'

          expect(pdf_fields['y_d400wf_li20b_pg2_good']).to eq '15'
          expect(pdf_fields['y_d400wf_sigdate']). to eq DateTime.now.strftime('%Y-%m-%d')
          expect(pdf_fields['y_d400wf_sigdate2']). to eq DateTime.now.strftime('%Y-%m-%d')
        end
      end

      context "mfs filer" do
        let(:intake) { create(:state_file_nc_intake, :with_spouse, filing_status: "married_filing_separately") }
        before do
          submission.data_source.direct_file_data.spouse_name = "Stella Crumpets"
          submission.data_source.direct_file_data.spouse_ssn = "111100030"
        end

        it "sets fields specific to filing status" do
          expect(pdf_fields['y_d400wf_sname2']).to eq 'Stella Crumpets'
          expect(pdf_fields['y_d400wf_sssn2']).to eq '111100030'

          expect(pdf_fields['y_d400wf_fstat1']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat2']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat3']).to eq 'Yes'
          expect(pdf_fields['y_d400wf_fstat4']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat5']).to eq 'Off'
        end
      end

      context "hoh filer" do
        let(:intake) { create(:state_file_nc_intake, :with_spouse, filing_status: "head_of_household") }

        it "sets fields specific to filing status" do
          expect(pdf_fields['y_d400wf_fstat1']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat2']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat3']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat4']).to eq 'Yes'
          expect(pdf_fields['y_d400wf_fstat5']).to eq 'Off'
        end
      end

      context "qw filer" do
        let(:intake) { create(:state_file_nc_intake, :with_spouse, filing_status: "qualifying_widow") }
        before do
          submission.data_source.direct_file_data.spouse_date_of_death = "2024-06-07"
        end

        it "sets fields specific to filing status" do
          expect(pdf_fields['y_d400wf_fstat1']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat2']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat3']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat4']).to eq 'Off'
          expect(pdf_fields['y_d400wf_fstat5']).to eq 'Yes'

          expect(pdf_fields['y_d400wf_dead3']).to eq '2024'
        end
      end

      context "veteran status fields" do
        let(:intake) { create(:state_file_nc_intake, :with_spouse, filing_status: "married_filing_jointly", primary_veteran: "yes", spouse_veteran: "no") }

        it "sets veteran status fields correctly" do
          expect(pdf_fields['y_d400wf_v1yes']).to eq 'Yes'
          expect(pdf_fields['y_d400wf_v2no']).to eq 'Off'
          expect(pdf_fields['y_d400wf_sv1yes']).to eq 'Off'
          expect(pdf_fields['y_d400wf_sv1no']).to eq 'Yes'
        end
      end

      context "total deductions field" do
        let(:intake) { create(:state_file_nc_intake, filing_status: "single", tribal_member: "yes", tribal_wages_amount: 500.00) }

        it "total deductions field" do
          expect(pdf_fields['y_d400wf_li9_good']).to eq '500'
        end
      end
    end
  end
end
