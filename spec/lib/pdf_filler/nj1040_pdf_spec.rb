require 'rails_helper'

RSpec.describe PdfFiller::Nj1040Pdf do
  include PdfSpecHelper

  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }
    let(:intake) { create(:state_file_nj_intake)}

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "with county code" do
      let(:submission) {
        create :efile_submission, tax_return: nil, data_source: create(
          :state_file_nj_intake,
          municipality_code: "0314"
        )
      }

      it 'sets county code fields to the correct values' do
        expect(pdf_fields["CM4"]).to eq "0"
        expect(pdf_fields["CM3"]).to eq "3"
        expect(pdf_fields["CM2"]).to eq "1"
        expect(pdf_fields["CM1"]).to eq "4"
      end
    end

    context "with taxpayer SSN" do
      let(:submission) {
        create :efile_submission, tax_return: nil, data_source: create(
          :state_file_nj_intake,
          primary_ssn: "123456789"
        )
      }

      it 'sets taxpayer SSN fields on header' do
        expect(pdf_fields["Your Social Security Number"]).to eq "123456789"
        expect(pdf_fields["Your Social Security Number_2"]).to eq "123456789"
        expect(pdf_fields["Your Social Security Number_3"]).to eq "123456789"
      end

      it 'sets taxpayer SSN fields' do
        expect(pdf_fields["undefined"]).to eq "1"
        expect(pdf_fields["undefined_2"]).to eq "2"
        expect(pdf_fields["Your Social Security Number required"]).to eq "3"
        expect(pdf_fields["Text3"]).to eq "4"
        expect(pdf_fields["Text4"]).to eq "5"
        expect(pdf_fields["Text5"]).to eq "6"
        expect(pdf_fields["Text6"]).to eq "7"
        expect(pdf_fields["Text7"]).to eq "8"
        expect(pdf_fields["Text8"]).to eq "9"
      end
    end

    describe "with spouse SSN" do
      context "when married filing jointly" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :married_filing_jointly,
            primary_ssn: "222222222",
            spouse_ssn: "123456789",
            spouse_first_name: "Ada"
          )
        }

        it 'sets taxpayer SSN fields on header to primary SSN' do
          expect(pdf_fields["Your Social Security Number"]).to eq "222222222"
          expect(pdf_fields["Your Social Security Number_2"]).to eq "222222222"
          expect(pdf_fields["Your Social Security Number_3"]).to eq "222222222"
        end

        it 'sets header spouse SSN fields' do
          expect(pdf_fields["undefined_3"]).to eq "1"
          expect(pdf_fields["undefined_4"]).to eq "2"
          expect(pdf_fields["undefined_5"]).to eq "3"
          expect(pdf_fields["Text9"]).to eq "4"
          expect(pdf_fields["Text10"]).to eq "5"
          expect(pdf_fields["Text11"]).to eq "6"
          expect(pdf_fields["Text12"]).to eq "7"
          expect(pdf_fields["Text13"]).to eq "8"
          expect(pdf_fields["Text14"]).to eq "9"
        end

        it 'leaves married filing separately spouse SSN fields blank' do
          expect(pdf_fields["undefined_7"]).to eq ""
          expect(pdf_fields["undefined_8"]).to eq ""
          expect(pdf_fields["Enter spousesCU partners SSN"]).to eq ""
          expect(pdf_fields["Text31"]).to eq ""
          expect(pdf_fields["Text32"]).to eq ""
          expect(pdf_fields["Text33"]).to eq ""
          expect(pdf_fields["Text34"]).to eq ""
          expect(pdf_fields["Text35"]).to eq ""
          expect(pdf_fields["Text36"]).to eq ""
        end
      end

      context "when married filing separately" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :married_filing_separately,
            primary_ssn: "222222222",
            spouse_ssn: "123456789",
            spouse_first_name: "Ada"
          )
        }

        it 'sets taxpayer SSN fields on header to primary SSN' do
          expect(pdf_fields["Your Social Security Number"]).to eq "222222222"
          expect(pdf_fields["Your Social Security Number_2"]).to eq "222222222"
          expect(pdf_fields["Your Social Security Number_3"]).to eq "222222222"
        end

        it 'fills married filing separately spouse SSN fields' do
          expect(pdf_fields["undefined_7"]).to eq "1"
          expect(pdf_fields["undefined_8"]).to eq "2"
          expect(pdf_fields["Enter spousesCU partners SSN"]).to eq "3"
          expect(pdf_fields["Text31"]).to eq "4"
          expect(pdf_fields["Text32"]).to eq "5"
          expect(pdf_fields["Text33"]).to eq "6"
          expect(pdf_fields["Text34"]).to eq "7"
          expect(pdf_fields["Text35"]).to eq "8"
          expect(pdf_fields["Text36"]).to eq "9"
        end

        it 'leaves header spouse SSN fields blank' do
          expect(pdf_fields["undefined_3"]).to eq ""
          expect(pdf_fields["undefined_4"]).to eq ""
          expect(pdf_fields["undefined_5"]).to eq ""
          expect(pdf_fields["Text9"]).to eq ""
          expect(pdf_fields["Text10"]).to eq ""
          expect(pdf_fields["Text11"]).to eq ""
          expect(pdf_fields["Text12"]).to eq ""
          expect(pdf_fields["Text13"]).to eq ""
          expect(pdf_fields["Text14"]).to eq ""
        end
      end
    end

    describe "exemptions" do
      describe "Line 6 exemptions" do
        context "single filer" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
            )
          }
          it "fills pdf with correct Line 6 fields" do
            expect(pdf_fields["Check Box39"]).to eq "Off"
            expect(pdf_fields["Check Box40"]).to eq "Off"
            expect(pdf_fields["Domestic"]).to eq "1"
            expect(pdf_fields["x  1000"]).to eq "1000"
          end
        end

        context "married filing jointly" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :married_filing_jointly,
              )
          }
          it "fills pdf with correct Line 6 fields" do
            expect(pdf_fields["Check Box39"]).to eq "Yes"
            expect(pdf_fields["Check Box40"]).to eq "Off"
            expect(pdf_fields["Domestic"]).to eq "2"
            expect(pdf_fields["x  1000"]).to eq "2000"
          end
        end
      end

      describe "Line 7 exemptions" do
        context "primary under 65" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              )
          }
          it "does not check the primary over 65 checkbox or the spouse over 65 checkbox" do
            expect(pdf_fields["Check Box41"]).to eq "Off"
            expect(pdf_fields["Check Box42"]).to eq "Off"
            expect(pdf_fields["x  1000_2"]).to eq "0"
            expect(pdf_fields["undefined_9"]).to eq "0"
          end
        end

        context "primary over 65" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :primary_over_65,
              )
          }
          it "checks the primary over 65 checkbox but not the spouse over 65 checkbox" do
            expect(pdf_fields["Check Box41"]).to eq "Yes"
            expect(pdf_fields["Check Box42"]).to eq "Off"
            expect(pdf_fields["x  1000_2"]).to eq "1000"
            expect(pdf_fields["undefined_9"]).to eq "1"
          end
        end

        context "primary over 65 and spouse under 65" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :married_filing_jointly,
              :primary_over_65,
              )
          }
          it "checks the primary over 65 checkbox but not the spouse over 65 checkbox" do
            expect(pdf_fields["Check Box41"]).to eq "Yes"
            expect(pdf_fields["Check Box42"]).to eq "Off"
            expect(pdf_fields["x  1000_2"]).to eq "1000"
            expect(pdf_fields["undefined_9"]).to eq "1"
          end
        end

        context "primary under 65 and spouse over 65" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :mfj_spouse_over_65,
              )
          }
          it "checks the spouse over 65 checkbox but not the self over 65 checkbox" do
            expect(pdf_fields["Check Box41"]).to eq "Off"
            expect(pdf_fields["Check Box42"]).to eq "Yes"
            expect(pdf_fields["x  1000_2"]).to eq "1000"
            expect(pdf_fields["undefined_9"]).to eq "1"
          end
        end

        context "primary over 65 and spouse over 65" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :mfj_spouse_over_65,
              :primary_over_65
              )
          }
          it "checks the spouse over 65 checkbox but not the self over 65 checkbox" do
            expect(pdf_fields["Check Box41"]).to eq "Yes"
            expect(pdf_fields["Check Box42"]).to eq "Yes"
            expect(pdf_fields["x  1000_2"]).to eq "2000"
            expect(pdf_fields["undefined_9"]).to eq "2"
          end
        end

      end

      describe "Line 8 exemptions" do
        context "neither primary nor spouse are blind" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              )
          }
          it "does not check the either the self or spouse blind/disabled checkboxes" do
            expect(pdf_fields["Check Box43"]).to eq "Off"
            expect(pdf_fields["Check Box44"]).to eq "Off"
            expect(pdf_fields["x  1000_3"]).to eq "0"
            expect(pdf_fields["undefined_10"]).to eq "0"
          end
        end

        context "primary is blind but spouse is not blind" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :primary_blind
            )
          }
          it "checks the self blind/disabled exemption but not the spouse checkbox" do
            expect(pdf_fields["Check Box43"]).to eq "Yes"
            expect(pdf_fields["Check Box44"]).to eq "Off"
            expect(pdf_fields["x  1000_3"]).to eq "1000"
            expect(pdf_fields["undefined_10"]).to eq "1"
          end
        end

        context "primary is not blind but spouse is blind" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :spouse_blind
            )
          }
          it "checks the self blind/disabled exemption but not the spouse checkbox" do
            expect(pdf_fields["Check Box43"]).to eq "Off"
            expect(pdf_fields["Check Box44"]).to eq "Yes"
            expect(pdf_fields["x  1000_3"]).to eq "1000"
            expect(pdf_fields["undefined_10"]).to eq "1"
          end
        end

        context "primary and spouse are both blind" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :married_filing_jointly,
              :primary_blind,
              :spouse_blind
            )
          }
          it "claims both the self and spouse blind/disabled exemptions" do
            expect(pdf_fields["Check Box43"]).to eq "Yes"
            expect(pdf_fields["Check Box44"]).to eq "Yes"
            expect(pdf_fields["x  1000_3"]).to eq "2000"
            expect(pdf_fields["undefined_10"]).to eq "2"
          end
        end
      end

      describe "Line 9 exemptions" do
        context "neither primary nor spouse are veterans" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              )
          }
          it "does not check the either the self or spouse veteran checkboxes" do
            expect(pdf_fields["Check Box45"]).to eq "Off"
            expect(pdf_fields["Check Box46"]).to eq "Off"
            expect(pdf_fields["x  6000"]).to eq "0"
            expect(pdf_fields["undefined_11"]).to eq "0"
          end
        end
  
        context "primary is veteran but spouse is not" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :primary_veteran
            )
          }
          it "checks the self veteran exemption but not the spouse checkbox" do
            expect(pdf_fields["Check Box45"]).to eq "Yes"
            expect(pdf_fields["Check Box46"]).to eq "Off"
            expect(pdf_fields["x  6000"]).to eq "6000"
            expect(pdf_fields["undefined_11"]).to eq "1"
          end
        end
  
        context "primary is not veteran but spouse is veteran" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :spouse_veteran
            )
          }
          it "checks the spouse veteran exemption but not the self checkbox" do
            expect(pdf_fields["Check Box45"]).to eq "Off"
            expect(pdf_fields["Check Box46"]).to eq "Yes"
            expect(pdf_fields["x  6000"]).to eq "6000"
            expect(pdf_fields["undefined_11"]).to eq "1"
          end
        end
  
        context "primary and spouse are both veterans" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :married_filing_jointly,
              :primary_veteran,
              :spouse_veteran
            )
          }
          it "claims both the self and spouse veteran exemptions" do
            expect(pdf_fields["Check Box45"]).to eq "Yes"
            expect(pdf_fields["Check Box46"]).to eq "Yes"
            expect(pdf_fields["x  6000"]).to eq "12000"
            expect(pdf_fields["undefined_11"]).to eq "2"
          end
        end
      end

      describe "Line 10 exemptions" do
        context "0 qualified dependent children" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake
            )
          }
          it "fills in zeroes" do
            expect(pdf_fields["Text47"]).to eq ""
            expect(pdf_fields["undefined_12"]).to eq "0"
            expect(pdf_fields["x  1500"]).to eq "0"
          end
        end

        context "1 qualified dependent child" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :df_data_two_deps,
            )
          }
          it "fills in properly" do
            expect(pdf_fields["Text47"]).to eq ""
            expect(pdf_fields["undefined_12"]).to eq "1"
            expect(pdf_fields["x  1500"]).to eq "1500"
          end
        end

        context "10 qualified dependent children" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :df_data_many_deps,
            )
          }
          it "fills in properly" do
            expect(pdf_fields["Text47"]).to eq "1"
            expect(pdf_fields["undefined_12"]).to eq "0"
            expect(pdf_fields["x  1500"]).to eq "15000"
          end
        end
      end

      describe "Line 11 exemptions" do
        context "0 dependents not qualifying children" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :df_data_minimal,
            )
          }
          it "fills in zeroes" do
            expect(pdf_fields["Text48"]).to eq ""
            expect(pdf_fields["undefined_13"]).to eq "0"
            expect(pdf_fields["x  1500_2"]).to eq "0"
          end
        end

        context "1 dependent not qualifying child" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :df_data_two_deps,
            )
          }
          it "fills in properly" do
            expect(pdf_fields["Text48"]).to eq ""
            expect(pdf_fields["undefined_13"]).to eq "1"
            expect(pdf_fields["x  1500_2"]).to eq "1500"
          end
        end
      end
    end

    describe "name field" do
      name_field = "Last Name First Name Initial Joint Filers enter first name and middle initial of each Enter spousesCU partners last name ONLY if different"
      context "single filer" do
        context "first and last name only" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              primary_first_name: "Grace",
              primary_last_name: "Hopper",
              primary_middle_initial: ""
            )
          }
          it 'fills pdf with LastName FirstName' do
            expected_name = "Hopper Grace"
            expect(pdf_fields[name_field]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_2"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_3"]).to eq expected_name
          end
        end

        context "with middle initial" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              primary_first_name: "Grace",
              primary_last_name: "Hopper",
              primary_middle_initial: "B"
            )
          }
          it 'fills pdf with LastName FirstName MI' do
            expected_name = "Hopper Grace B"
            expect(pdf_fields[name_field]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_2"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_3"]).to eq expected_name
          end
        end

        context "with suffix" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              primary_first_name: "Grace",
              primary_last_name: "Hopper",
              primary_middle_initial: "",
              primary_suffix: "JR"
            )
          }
          it 'fills pdf with LastName FirstName Suf' do
            expected_name = "Hopper Grace JR"
            expect(pdf_fields[name_field]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_2"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_3"]).to eq expected_name
          end
        end

        context "with suffix and middle initial" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              primary_first_name: "Grace",
              primary_last_name: "Hopper",
              primary_middle_initial: "B",
              primary_suffix: "JR"
            )
          }
          it 'fills pdf with LastName FirstName MI Suf' do
            expected_name = "Hopper Grace B JR"
            expect(pdf_fields[name_field]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_2"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_3"]).to eq expected_name
          end
        end
      end

      context "joint filer" do
        context "same last name" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              primary_first_name: "Bert",
              primary_last_name: "Muppet",
              primary_middle_initial: "S",
              spouse_first_name: "Ernie",
              spouse_last_name: "Muppet",
              spouse_ssn: "123456789"
            )
          }
          it 'fills pdf with LastName FirstName & FirstName' do
            expected_name = "Muppet Bert S & Ernie"
            expect(pdf_fields[name_field]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_2"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_3"]).to eq expected_name
          end
        end

        context "different last names" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              primary_first_name: "Blake",
              primary_last_name: "Lively",
              primary_middle_initial: "E",
              spouse_first_name: "Ryan",
              spouse_last_name: "Reynolds",
              spouse_ssn: "123456789"
            )
          }

          it 'fills pdf with LastName FirstName & LastName FirstName' do
            expected_name = "Lively Blake E & Reynolds Ryan"
            expect(pdf_fields[name_field]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_2"]).to eq expected_name
            expect(pdf_fields["Names as shown on Form NJ1040_3"]).to eq expected_name
          end
        end
      end
    end

    describe "address fields" do
      it 'enters values into PDF' do
        # address values from zeus_one_dep.xml
        expect(pdf_fields["SpousesCU Partners SSN if filing jointly"]).to eq "391 US-206 B"
        expect(pdf_fields["CountyMunicipality Code See Table page 50"]).to eq "Hammonton"
        expect(pdf_fields["State"]).to eq "NJ"
        expect(pdf_fields["ZIP Code"]).to eq "08037"
      end
    end

    describe "dependents" do

      context 'one dependent' do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_one_dep
          )
        }

        before do
          intake.dependents[0].update(dob: Date.new(2023, 1, 1))
        end

        it 'enters single dependent into PDF' do
          # dependent 1
          expect(pdf_fields["Last Name First Name Middle Initial 1"]).to eq "ATHENS KRONOS T"
          expect(pdf_fields["undefined_18"]).to eq "3"
          expect(pdf_fields["undefined_19"]).to eq "0"
          expect(pdf_fields["undefined_20"]).to eq "0"
          expect(pdf_fields["Text54"]).to eq "0"
          expect(pdf_fields["Text55"]).to eq "0"
          expect(pdf_fields["Text56"]).to eq "0"
          expect(pdf_fields["Text57"]).to eq "0"
          expect(pdf_fields["Text58"]).to eq "2"
          expect(pdf_fields["Text59"]).to eq "9"

          expect(pdf_fields["Birth Year"]).to eq "2"
          expect(pdf_fields["Text60"]).to eq "0"
          expect(pdf_fields["Text61"]).to eq "2"
          expect(pdf_fields["Text62"]).to eq "3"

          # dependent 2
          expect(pdf_fields["Last Name First Name Middle Initial 2"]).to eq ""
          expect(pdf_fields["undefined_21"]).to eq ""
          expect(pdf_fields["undefined_22"]).to eq ""
          expect(pdf_fields["undefined_23"]).to eq ""
          expect(pdf_fields["undefined_24"]).to eq ""
          expect(pdf_fields["Text65"]).to eq ""
          expect(pdf_fields["Text66"]).to eq ""
          expect(pdf_fields["Text67"]).to eq ""
          expect(pdf_fields["Text68"]).to eq ""
          expect(pdf_fields["Text69"]).to eq ""
          expect(pdf_fields["Text70"]).to eq ""
          expect(pdf_fields["Text71"]).to eq ""
          expect(pdf_fields["Text72"]).to eq ""
          expect(pdf_fields["Text73"]).to eq ""
        end
      end

      context 'many dependents' do
        let(:intake) {
          create(
            :state_file_nj_intake,
            :df_data_many_deps
          )
        }

        before do
          intake.dependents.each_with_index do |dependent, i|
            dependent.update(
              dob: i.years.ago(Date.new(2020, 1, 1)),
              first_name: "Firstname#{i}",
              last_name: "Lastname#{i}",
              middle_initial: 'ABCDEFGHIJK'[i],
              suffix: 'JR',
              ssn: "1234567#{"%02d" % i}"
            )
          end
        end

        it 'enters first four dependents into PDF' do
          # dependent 1
          expect(pdf_fields["Last Name First Name Middle Initial 1"]).to eq "Lastname0 Firstname0 A JR"

          expect(pdf_fields["undefined_18"]).to eq "1"
          expect(pdf_fields["undefined_19"]).to eq "2"
          expect(pdf_fields["undefined_20"]).to eq "3"
          expect(pdf_fields["Text54"]).to eq "4"
          expect(pdf_fields["Text55"]).to eq "5"
          expect(pdf_fields["Text56"]).to eq "6"
          expect(pdf_fields["Text57"]).to eq "7"
          expect(pdf_fields["Text58"]).to eq "0"
          expect(pdf_fields["Text59"]).to eq "0"

          expect(pdf_fields["Birth Year"]).to eq "2"
          expect(pdf_fields["Text60"]).to eq "0"
          expect(pdf_fields["Text61"]).to eq "2"
          expect(pdf_fields["Text62"]).to eq "0"

          # dependent 2
          expect(pdf_fields["Last Name First Name Middle Initial 2"]).to eq "Lastname1 Firstname1 B JR"

          expect(pdf_fields["undefined_21"]).to eq "1"
          expect(pdf_fields["undefined_22"]).to eq "2"
          expect(pdf_fields["undefined_23"]).to eq "3"
          expect(pdf_fields["undefined_24"]).to eq "4"
          expect(pdf_fields["Text65"]).to eq "5"
          expect(pdf_fields["Text66"]).to eq "6"
          expect(pdf_fields["Text67"]).to eq "7"
          expect(pdf_fields["Text68"]).to eq "0"
          expect(pdf_fields["Text69"]).to eq "1"

          expect(pdf_fields["Text70"]).to eq "2"
          expect(pdf_fields["Text71"]).to eq "0"
          expect(pdf_fields["Text72"]).to eq "1"
          expect(pdf_fields["Text73"]).to eq "9"

          # dependent 3
          expect(pdf_fields["Last Name First Name Middle Initial 3"]).to eq "Lastname2 Firstname2 C JR"

          expect(pdf_fields["undefined_25"]).to eq "1"
          expect(pdf_fields["undefined_26"]).to eq "2"
          expect(pdf_fields["undefined_27"]).to eq "3"
          expect(pdf_fields["undefined_28"]).to eq "4"
          expect(pdf_fields["Text75"]).to eq "5"
          expect(pdf_fields["Text76"]).to eq "6"
          expect(pdf_fields["Text77"]).to eq "7"
          expect(pdf_fields["Text78"]).to eq "0"
          expect(pdf_fields["Text79"]).to eq "2"

          expect(pdf_fields["Text80"]).to eq "2"
          expect(pdf_fields["Text81"]).to eq "0"
          expect(pdf_fields["Text82"]).to eq "1"
          expect(pdf_fields["Text83"]).to eq "8"

          # dependent 4
          expect(pdf_fields["Last Name First Name Middle Initial 4"]).to eq "Lastname3 Firstname3 D JR"

          expect(pdf_fields["undefined_29"]).to eq "1"
          expect(pdf_fields["undefined_30"]).to eq "2"
          expect(pdf_fields["undefined_31"]).to eq "3"
          expect(pdf_fields["undefined_32"]).to eq "4"
          expect(pdf_fields["Text85"]).to eq "5"
          expect(pdf_fields["Text86"]).to eq "6"
          expect(pdf_fields["Text87"]).to eq "7"
          expect(pdf_fields["Text88"]).to eq "0"
          expect(pdf_fields["Text89"]).to eq "3"

          expect(pdf_fields["Text90"]).to eq "2"
          expect(pdf_fields["Text91"]).to eq "0"
          expect(pdf_fields["Text92"]).to eq "1"
          expect(pdf_fields["Text93"]).to eq "7"
        end
      end
    end

    describe "line 15 wages" do
      context "when no w2 wages" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

        it "does not fill in any box on line 15" do
          expect(pdf_fields["15"]).to eq ""
          expect(pdf_fields["undefined_36"]).to eq ""
          expect(pdf_fields["undefined_37"]).to eq ""
          expect(pdf_fields["undefined_38"]).to eq ""
          expect(pdf_fields["Text100"]).to eq ""
          expect(pdf_fields["Text101"]).to eq ""
          expect(pdf_fields["Text103"]).to eq ""
          expect(pdf_fields["Text104"]).to eq ""
          expect(pdf_fields["Text105"]).to eq ""
          expect(pdf_fields["Text106"]).to eq ""
        end
      end

      context "when w2 wages exist" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_many_w2s
          )
        }

        it "includes the sum 200,000 split into each box on line 15" do
          # millions
          expect(pdf_fields["15"]).to eq ""
          expect(pdf_fields["undefined_36"]).to eq ""
          # thousands
          expect(pdf_fields["undefined_37"]).to eq "2"
          expect(pdf_fields["undefined_38"]).to eq "0"
          expect(pdf_fields["Text100"]).to eq "0"
          # hundreds
          expect(pdf_fields["Text101"]).to eq "0"
          expect(pdf_fields["Text103"]).to eq "0"
          expect(pdf_fields["Text104"]).to eq "0"
          # decimals
          expect(pdf_fields["Text105"]).to eq "0"
          expect(pdf_fields["Text106"]).to eq "0"
        end
      end

      context "when w2 wages exist (including decimal places)" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_2_w2s
          )
        }

        it "includes the sum 62,345 split into each box on line 15" do
          # millions
          expect(pdf_fields["15"]).to eq ""
          expect(pdf_fields["undefined_36"]).to eq ""
          # thousands
          expect(pdf_fields["undefined_37"]).to eq ""
          expect(pdf_fields["undefined_38"]).to eq "6"
          expect(pdf_fields["Text100"]).to eq "2"
          # hundreds
          expect(pdf_fields["Text101"]).to eq "3"
          expect(pdf_fields["Text103"]).to eq "4"
          expect(pdf_fields["Text104"]).to eq "5"
          # decimals
          expect(pdf_fields["Text105"]).to eq "0"
          expect(pdf_fields["Text106"]).to eq "0"
        end
      end
    end

    describe "line 16a taxable interest income" do
      context 'with interest reports, but no interest on government bonds' do
        let(:intake) { create(:state_file_nj_intake, :df_data_one_dep) }

        it 'does not set line 16a' do
          ["112",
           "111",
           "110",
           "109",
           "108",
           "Text107",
           "undefined_41",
           "undefined_40",
           "undefined_39",
           "undefined_43"].each { |pdf_field| expect(pdf_fields[pdf_field]).to eq "" }
        end
      end 
  
      context 'with interest on government bonds' do
        let(:intake) { create(:state_file_nj_intake, :df_data_two_deps) }

        it 'sets line 16a to 300 (fed taxable income minus sum of bond interest)' do
          expect(pdf_fields["undefined_43"]).to eq ""
          expect(pdf_fields["undefined_39"]).to eq ""
          expect(pdf_fields["undefined_40"]).to eq ""
          expect(pdf_fields["undefined_41"]).to eq ""
          expect(pdf_fields["Text107"]).to eq ""
          expect(pdf_fields["108"]).to eq "3"
          expect(pdf_fields["109"]).to eq "0"
          expect(pdf_fields["110"]).to eq "0"
          expect(pdf_fields["111"]).to eq "0"
          expect(pdf_fields["112"]).to eq "0"
        end
      end
    end

    describe "line 16b tax exempt interest income" do
      context "with no tax exempt interest income" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
        it 'does not set line 16b' do
          ["117",
           "116",
           "115",
           "114",
           "113",
           "undefined_44",
           "16a",
           "undefined_42",
           "16b"].each { |pdf_field| expect(pdf_fields[pdf_field]).to eq "" }
        end
      end

      context "with tax exempt interest income and interest on government bonds less than 10k" do
        let(:intake) { create(:state_file_nj_intake, :df_data_two_deps) }
        it 'sets line 16b to the sum' do
          expect(pdf_fields["16b"]).to eq ""
          expect(pdf_fields["undefined_42"]).to eq ""
          expect(pdf_fields["16a"]).to eq ""
          expect(pdf_fields["undefined_44"]).to eq ""
          expect(pdf_fields["113"]).to eq "2"
          expect(pdf_fields["114"]).to eq "0"
          expect(pdf_fields["115"]).to eq "1"
          expect(pdf_fields["116"]).to eq "0"
          expect(pdf_fields["117"]).to eq "0"
        end
      end
    end

    describe "line 13/30 total exemptions" do
      let(:submission) {
        create :efile_submission, tax_return: nil, data_source: create(
          :state_file_nj_intake
        )
      }
      it "totals line 6-12 and writes it to line 13" do
        # thousands
        expect(pdf_fields["undefined_15"]).to eq ""
        expect(pdf_fields["undefined_16"]).to eq "1"
        # hundreds
        expect(pdf_fields["undefined_17"]).to eq "0"
        expect(pdf_fields["Text50"]).to eq "0"
        expect(pdf_fields["Text51"]).to eq "0"
        # decimals
        expect(pdf_fields["Text52"]).to eq "0"
        expect(pdf_fields["Text53"]).to eq "0"
      end

      it "totals line 6-12 and writes it to line 30" do
        # thousands
        expect(pdf_fields["30"]).to eq ""
        expect(pdf_fields["210"]).to eq ""
        expect(pdf_fields["211"]).to eq "1"
        # hundreds
        expect(pdf_fields["undefined_90"]).to eq "0"
        expect(pdf_fields["212"]).to eq "0"
        expect(pdf_fields["213"]).to eq "0"
        # decimals
        expect(pdf_fields["undefined_91"]).to eq "0"
        expect(pdf_fields["214"]).to eq "0"
      end
    end

    describe "filing status" do
      context "single" do
        before do
          submission.data_source.direct_file_data.filing_status = 1
        end
        it "checks the Choice1 box" do
          expect(pdf_fields["Group1"]).to eq "Choice1"
        end
      end

      context "married filing jointly" do
        before do
          submission.data_source.direct_file_data.filing_status = 2
        end
        it "checks the Choice2 box" do
          expect(pdf_fields["Group1"]).to eq "Choice2"
        end
      end

      context "married filing separately" do
        before do
          submission.data_source.direct_file_data.filing_status = 3
        end
        it "checks the Choice3 box" do
          expect(pdf_fields["Group1"]).to eq "Choice3"
        end
      end

      context "head of household" do
        before do
          submission.data_source.direct_file_data.filing_status = 4
        end
        it "checks the Choice4 box" do
          expect(pdf_fields["Group1"]).to eq "Choice4"
        end
      end

      context "qualifying widow" do
        context "spouse passed in the last year" do
          before do
            submission.data_source.direct_file_data.filing_status = 5
            date_within_prior_year = "#{MultiTenantService.new(:statefile).current_tax_year}-09-30"
            submission.data_source.direct_file_data.spouse_date_of_death = date_within_prior_year
          end

          it "checks the Choice5 box" do
            expect(pdf_fields["Group1"]).to eq "Choice5"
          end

          it "checks the one year prior spouse date of death" do
            expect(pdf_fields["Group1qualwi5ab"]).to eq "1"
          end
        end

        context "spouse passed two years prior" do
          before do
            submission.data_source.direct_file_data.filing_status = 5
            date_two_years_prior = "#{MultiTenantService.new(:statefile).current_tax_year - 1}-09-30"
            submission.data_source.direct_file_data.spouse_date_of_death = date_two_years_prior
          end

          it "checks the Choice5 box" do
            expect(pdf_fields["Group1"]).to eq "Choice5"
          end

          it "checks the two years prior spouse date of death" do
            expect(pdf_fields["Group1qualwi5ab"]).to eq "0"
          end
        end
      end
    end

    describe "line 27 - total income" do
      context "when taxpayer provides total income with the sum 200,000" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_many_w2s
          )
        }
        it "fills in the total income boxes in the PDF on line 27 with the rounded value" do
          # millions
          expect(pdf_fields["263"]).to eq ""
          expect(pdf_fields["27"]).to eq ""
          expect(pdf_fields["183"]).to eq ""
          # thousands
          expect(pdf_fields["undefined_78"]).to eq "2"
          expect(pdf_fields["184"]).to eq "0"
          expect(pdf_fields["185"]).to eq "0"
          # hundreds
          expect(pdf_fields["undefined_79"]).to eq "0"
          expect(pdf_fields["186"]).to eq "0"
          expect(pdf_fields["187"]).to eq "0"
          # decimals
          expect(pdf_fields["undefined_80"]).to eq "0"
          expect(pdf_fields["188"]).to eq "0"
        end
      end

      context "when taxpayer provides total income of 0" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

        it "does not fill in any of the boxes on line 27" do
          # millions
          expect(pdf_fields["263"]).to eq ""
          expect(pdf_fields["27"]).to eq ""
          expect(pdf_fields["183"]).to eq ""
          # thousands
          expect(pdf_fields["undefined_78"]).to eq ""
          expect(pdf_fields["184"]).to eq ""
          expect(pdf_fields["185"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_79"]).to eq ""
          expect(pdf_fields["186"]).to eq ""
          expect(pdf_fields["187"]).to eq ""
          # decimals
          expect(pdf_fields["undefined_80"]).to eq ""
          expect(pdf_fields["188"]).to eq ""
        end
      end
    end

    describe "line 29 - gross income" do
      context "when taxpayer provides gross income with the sum 200,000" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_many_w2s
          )
        }
        it "fills in the gross income boxes in the PDF on line 29 with the rounded value" do
          # millions
          expect(pdf_fields["270"]).to eq ""
          expect(pdf_fields["29"]).to eq ""
          expect(pdf_fields["204"]).to eq ""
          # thousands
          expect(pdf_fields["undefined_87"]).to eq "2"
          expect(pdf_fields["205"]).to eq "0"
          expect(pdf_fields["206"]).to eq "0"
          # hundreds
          expect(pdf_fields["undefined_88"]).to eq "0"
          expect(pdf_fields["207"]).to eq "0"
          expect(pdf_fields["208"]).to eq "0"
          # decimals
          expect(pdf_fields["undefined_89"]).to eq "0"
          expect(pdf_fields["209"]).to eq "0"
        end
      end

      context "when taxpayer provides total income of 0" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

        it "does not fill in any of the boxes on line 29" do
          # millions
          expect(pdf_fields["270"]).to eq ""
          expect(pdf_fields["29"]).to eq ""
          expect(pdf_fields["204"]).to eq ""
          # thousands
          expect(pdf_fields["undefined_87"]).to eq ""
          expect(pdf_fields["205"]).to eq ""
          expect(pdf_fields["206"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_88"]).to eq ""
          expect(pdf_fields["207"]).to eq ""
          expect(pdf_fields["208"]).to eq ""
          # decimals
          expect(pdf_fields["undefined_89"]).to eq ""
          expect(pdf_fields["209"]).to eq ""
        end
      end
    end

    describe "line 31 medical expenses" do
      context "with a gross income of 200k" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            medical_expenses: 567_890
          )
        }
        it "writes sum $563,890.00 to fill boxes on line 31" do
          # thousands
          expect(pdf_fields["31"]).to eq "5"
          expect(pdf_fields["215"]).to eq "6"
          expect(pdf_fields["216"]).to eq "3"
          # hundreds
          expect(pdf_fields["undefined_92"]).to eq "8"
          expect(pdf_fields["217"]).to eq "9"
          expect(pdf_fields["218"]).to eq "0"
          # decimals
          expect(pdf_fields["undefined_93"]).to eq "0"
          expect(pdf_fields["219"]).to eq "0"
        end
      end

      context "when medical expenses do not exceed 2% gross income" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            medical_expenses: 4000
          )
        }
        it "does not fill line 31" do
          # thousands
          expect(pdf_fields["31"]).to eq ""
          expect(pdf_fields["215"]).to eq ""
          expect(pdf_fields["216"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_92"]).to eq ""
          expect(pdf_fields["217"]).to eq ""
          expect(pdf_fields["218"]).to eq ""
          # decimals
          expect(pdf_fields["undefined_93"]).to eq ""
          expect(pdf_fields["219"]).to eq ""
        end
      end
    end

    describe "line 38 total exemptions and deductions" do
      let(:submission) {
        create :efile_submission, tax_return: nil, data_source: create(
          :state_file_nj_intake
        )
      }
      it "writes sum $1,000.00 to fill boxes on line 38" do
        # millions
        expect(pdf_fields["278"]).to eq ""
        # thousands
        expect(pdf_fields["undefined_104"]).to eq ""
        expect(pdf_fields["246"]).to eq ""
        expect(pdf_fields["247"]).to eq "1"
        # hundreds
        expect(pdf_fields["undefined_105"]).to eq "0"
        expect(pdf_fields["248"]).to eq "0"
        expect(pdf_fields["249"]).to eq "0"
        # decimals
        expect(pdf_fields["undefined_106"]).to eq "0"
        expect(pdf_fields["250"]).to eq "0"
      end
    end

    describe "line 39 taxable income" do
      let(:submission) {
        create :efile_submission, tax_return: nil, data_source: create(
          :state_file_nj_intake, :df_data_many_w2s
        )
      }
      it "writes taxable income $199,000 (200,000-1000) to fill boxes on line 39" do
        # millions
        expect(pdf_fields["279"]).to eq ""
        expect(pdf_fields["38a Total Property Taxes 18 of Rent Paid See instructions page 23 38a"]).to eq ""
        expect(pdf_fields["251"]).to eq ""
        # thousands
        expect(pdf_fields["undefined_107"]).to eq "1"
        expect(pdf_fields["252"]).to eq "9"
        expect(pdf_fields["253"]).to eq "9"
        # hundreds
        expect(pdf_fields["undefined_108"]).to eq "0"
        expect(pdf_fields["254"]).to eq "0"
        expect(pdf_fields["255"]).to eq "0"
        # decimals
        expect(pdf_fields["undefined_109"]).to eq "0"
        expect(pdf_fields["256"]).to eq "0"
      end
    end

    describe "lines 40a and 40b" do
      context "when taxpayer is a renter" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            household_rent_own: 'rent',
            rent_paid: 75381
          )
        }
        it "checks the Choice2 box" do
          expect(pdf_fields["Group182"]).to eq "Choice2"
        end

        it "inserts rent-converted property tax $13,568.58 rounded on line 40a" do
          # millions
          expect(pdf_fields["39"]).to eq ""
          expect(pdf_fields["280"]).to eq ""
          # thousands
          expect(pdf_fields["undefined_112"]).to eq ""
          expect(pdf_fields["281"]).to eq "1"
          expect(pdf_fields["282"]).to eq "3"
          # hundreds
          expect(pdf_fields["undefined_113"]).to eq "5"
          expect(pdf_fields["283"]).to eq "6"
          expect(pdf_fields["37"]).to eq "9"
          # decimals
          expect(pdf_fields["245"]).to eq "0"
          expect(pdf_fields["24539a#2"]).to eq "0"
        end
      end

      context "when taxpayer is a homeowner" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            household_rent_own: 'own',
            property_tax_paid: 12345678
          )
        }
        it "checks the Choice1 box" do
          expect(pdf_fields["Group182"]).to eq "Choice1"
        end

        it "inserts property tax $12,345,678 on line 40a" do
          # millions
          expect(pdf_fields["39"]).to eq "1"
          expect(pdf_fields["280"]).to eq "2"
          # thousands
          expect(pdf_fields["undefined_112"]).to eq "3"
          expect(pdf_fields["281"]).to eq "4"
          expect(pdf_fields["282"]).to eq "5"
          # hundreds
          expect(pdf_fields["undefined_113"]).to eq "6"
          expect(pdf_fields["283"]).to eq "7"
          expect(pdf_fields["37"]).to eq "8"
          # decimals
          expect(pdf_fields["245"]).to eq "0"
          expect(pdf_fields["24539a#2"]).to eq "0"
        end
      end

      context "when taxpayer is a neither a homeowner nor a renter" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            household_rent_own: 'neither')
        }
        it "does not check a box" do
          expect(pdf_fields["Group182"]).to eq "Off"
        end

        it "does not insert property tax calculation on line 40a" do
          expect(pdf_fields["39"]).to eq ""
          expect(pdf_fields["280"]).to eq ""
          expect(pdf_fields["undefined_112"]).to eq ""
          expect(pdf_fields["281"]).to eq ""
          expect(pdf_fields["282"]).to eq ""
          expect(pdf_fields["undefined_113"]).to eq ""
          expect(pdf_fields["283"]).to eq ""
          expect(pdf_fields["37"]).to eq ""
          expect(pdf_fields["245"]).to eq ""
          expect(pdf_fields["24539a#2"]).to eq ""
        end
      end

      context "when taxpayer does not have enough income to claim property tax credit or deduction" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_minimal)
        }
        it "does not check a box" do
          expect(pdf_fields["Group182"]).to eq "Off"
        end

        it "does not insert property tax calculation on line 40a" do
          expect(pdf_fields["39"]).to eq ""
          expect(pdf_fields["280"]).to eq ""
          expect(pdf_fields["undefined_112"]).to eq ""
          expect(pdf_fields["281"]).to eq ""
          expect(pdf_fields["282"]).to eq ""
          expect(pdf_fields["undefined_113"]).to eq ""
          expect(pdf_fields["283"]).to eq ""
          expect(pdf_fields["37"]).to eq ""
          expect(pdf_fields["245"]).to eq ""
          expect(pdf_fields["24539a#2"]).to eq ""
        end
      end
    end

    describe "line 41 - property tax deduction" do
      context 'when taking property tax deduction' do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
             :state_file_nj_intake,
             :df_data_many_w2s,
             household_rent_own: 'own',
             property_tax_paid: 15_000,
          )
        }

        it "fills line 41 with $15,000 property tax deduction amount" do
          # thousands
          expect(pdf_fields["undefined_116"]).to eq "1"
          expect(pdf_fields["41"]).to eq "5"
          # hundreds
          expect(pdf_fields["undefined_117"]).to eq "0"
          expect(pdf_fields["undefined_118"]).to eq "0"
          expect(pdf_fields["Text1"]).to eq "0"
          # decimals
          expect(pdf_fields["Text2"]).to eq "0"
          expect(pdf_fields["Text18"]).to eq "0"
        end
      end

      context 'when not taking property tax deduction' do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            household_rent_own: 'own',
            property_tax_paid: 0,
          )
        }

        it "does not fill fields" do
          # thousands
          expect(pdf_fields["undefined_116"]).to eq ""
          expect(pdf_fields["41"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_117"]).to eq ""
          expect(pdf_fields["undefined_118"]).to eq ""
          expect(pdf_fields["Text1"]).to eq ""
          # decimals
          expect(pdf_fields["Text2"]).to eq ""
          expect(pdf_fields["Text18"]).to eq ""
        end
      end

      context 'when ineligible for property tax deduction due to income' do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_minimal,
          )
        }

        it "does not fill fields" do
          # thousands
          expect(pdf_fields["undefined_116"]).to eq ""
          expect(pdf_fields["41"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_117"]).to eq ""
          expect(pdf_fields["undefined_118"]).to eq ""
          expect(pdf_fields["Text1"]).to eq ""
          # decimals
          expect(pdf_fields["Text2"]).to eq ""
          expect(pdf_fields["Text18"]).to eq ""
        end
      end

      context 'when ineligible for property tax deduction due to income but could be eligible for credit' do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_minimal,
            :primary_over_65,
          )
        }

        it "does not fill fields" do
          # thousands
          expect(pdf_fields["undefined_116"]).to eq ""
          expect(pdf_fields["41"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_117"]).to eq ""
          expect(pdf_fields["undefined_118"]).to eq ""
          expect(pdf_fields["Text1"]).to eq ""
          # decimals
          expect(pdf_fields["Text2"]).to eq ""
          expect(pdf_fields["Text18"]).to eq ""
        end
      end
    end

    describe "line 42 new jersey taxable income" do
      let(:submission) {
        create :efile_submission, tax_return: nil, data_source: create(
          :state_file_nj_intake, :df_data_many_w2s
        )
      }
      it "writes new jersey taxable income $199,000 (200,000-1000) to fill boxes on line 39" do
        # millions
        expect(pdf_fields["Enter Code4332"]).to eq ""
        expect(pdf_fields["40"]).to eq ""
        expect(pdf_fields["undefined_114"]).to eq ""
        # thousands
        expect(pdf_fields["Text19"]).to eq "1"
        expect(pdf_fields["Text20"]).to eq "9"
        expect(pdf_fields["Text30"]).to eq "9"
        # hundreds
        expect(pdf_fields["Text37"]).to eq "0"
        expect(pdf_fields["Text38"]).to eq "0"
        expect(pdf_fields["Text39"]).to eq "0"
        # decimals
        expect(pdf_fields["Text40"]).to eq "0"
        expect(pdf_fields["Text41"]).to eq "0"
      end
    end

    describe "line 43 - tax amount" do
      let(:submission) {
        create :efile_submission, tax_return: nil, data_source: create(
          :state_file_nj_intake,
          :df_data_many_w2s,
          :married_filing_jointly,
          household_rent_own: 'own',
          property_tax_paid: 15_000,
      )
      }

      it "writes rounded tax amount $7,615.10 based on income $200,000 with 2,000 exemptions 15,000 property tax deduction and 0.0637 tax rate minus 4,042.50 subtraction" do
        # millions
        expect(pdf_fields["Enter Code4332243ew"]).to eq ""
        expect(pdf_fields["4036y54ethdf"]).to eq ""
        # thousands
        expect(pdf_fields["42"]).to eq ""
        expect(pdf_fields["undefined_119"]).to eq ""
        expect(pdf_fields["undefined_120"]).to eq "7"
        # hundreds
        expect(pdf_fields["Text43"]).to eq "6"
        expect(pdf_fields["Text44"]).to eq "1"
        expect(pdf_fields["Text45"]).to eq "5"
        # decimals
        expect(pdf_fields["Text46"]).to eq "0"
        expect(pdf_fields["Text63"]).to eq "0"
      end
    end

    describe "line 51 - use tax" do
      let(:submission) {
        create :efile_submission, tax_return: nil, data_source: create(
          :state_file_nj_intake,
          sales_use_tax: 123
        )
      }

      it "writes $123.00 property tax credit" do
        # thousands
        expect(pdf_fields["50"]).to eq ""
        expect(pdf_fields["50_2"]).to eq ""
        expect(pdf_fields["50_3"]).to eq ""
        # hundreds
        expect(pdf_fields["Text131"]).to eq "1"
        expect(pdf_fields["Text132"]).to eq "2"
        expect(pdf_fields["Text133"]).to eq "3"
        # decimals
        expect(pdf_fields["Text134"]).to eq "0"
        expect(pdf_fields["50_7"]).to eq "0"
      end
    end

    describe "line 56 - property tax credit" do
      context 'when taxpayer income is above property tax minimum' do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_many_w2s,
            household_rent_own: 'own',
            property_tax_paid: 0,
            )
        }

        it "writes $50.00 property tax credit" do
          # hundreds
          expect(pdf_fields["Text161"]).to eq "5"
          expect(pdf_fields["Text162"]).to eq "0"
          # decimals
          expect(pdf_fields["Text163"]).to eq "0"
          expect(pdf_fields["Text164"]).to eq "0"
        end
      end

      context 'when taxpayer income is below property tax minimum' do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_minimal)
        }

        it "does not fill property tax credit" do
          # hundreds
          expect(pdf_fields["Text161"]).to eq ""
          expect(pdf_fields["Text162"]).to eq ""
          # decimals
          expect(pdf_fields["Text163"]).to eq ""
          expect(pdf_fields["Text164"]).to eq ""
        end
      end

      context 'when taxpayer income is below property tax minimum but eligible for credit' do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_minimal,
            :primary_blind)
        }

        it "writes $50.00 property tax credit" do
          # hundreds
          expect(pdf_fields["Text161"]).to eq "5"
          expect(pdf_fields["Text162"]).to eq "0"
          # decimals
          expect(pdf_fields["Text163"]).to eq "0"
          expect(pdf_fields["Text164"]).to eq "0"
        end
      end
    end

    describe "line 57 - estimated tax payments" do
      context 'when estimated_tax_payments has a value' do
        let(:intake) { create(:state_file_nj_intake, estimated_tax_payments: 12_345_678.11) }

        it "fills EstimatedPaymentTotal with rounded estimated_tax_payments" do
          # millions
          expect(pdf_fields["56!\#$$"]).to eq "1"
          expect(pdf_fields["56"]).to eq "2"
          # thousands
          expect(pdf_fields["undefined_147"]).to eq "3"
          expect(pdf_fields["undefined_148"]).to eq "4"
          expect(pdf_fields["undefined_149"]).to eq "5"
          # hundreds
          expect(pdf_fields["Text160"]).to eq "6"
          expect(pdf_fields["55"]).to eq "7"
          expect(pdf_fields["undefined_146"]).to eq "8"
          # decimals
          expect(pdf_fields["Text158"]).to eq "0"
          expect(pdf_fields["Text159"]).to eq "0"
        end
      end

      context 'when estimated_tax_payments is nil' do
        let(:intake) { create(:state_file_nj_intake) }

        it "does not fill EstimatedPaymentTotal" do
          # millions
          expect(pdf_fields["56!\#$$"]).to eq ""
          expect(pdf_fields["56"]).to eq ""
          # thousands
          expect(pdf_fields["undefined_147"]).to eq ""
          expect(pdf_fields["undefined_148"]).to eq ""
          expect(pdf_fields["undefined_149"]).to eq ""
          # hundreds
          expect(pdf_fields["Text160"]).to eq ""
          expect(pdf_fields["55"]).to eq ""
          expect(pdf_fields["undefined_146"]).to eq ""
          # decimals
          expect(pdf_fields["Text158"]).to eq ""
          expect(pdf_fields["Text159"]).to eq ""
        end
      end
    end


    describe "line 58 - earned income tax credit" do
      context 'when there is EarnedIncomeCreditAmt on the federal 1040' do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake
          )
        }

        it "fills line 58 with $596 for 40% of federal tax credit and checks federal checkbox" do
          # thousands
          expect(pdf_fields["58"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_152"]).to eq "5"
          expect(pdf_fields["undefined_153"]).to eq "9"
          expect(pdf_fields["Text170"]).to eq "6"
          # decimals
          expect(pdf_fields["Text171"]).to eq "0"
          expect(pdf_fields["Text172"]).to eq "0"

          # federal checkbox
          expect(pdf_fields["Check Box168"]).to eq "Yes"

          # NJ CU checkbox
          expect(pdf_fields["Check Box169"]).to eq "Off"
        end
      end

      context 'when no EarnedIncomeCreditAmt on federal 1040 but taxpayer qualifies for NJ EITC' do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake, :df_data_minimal, :claimed_as_eitc_qualifying_child_no
          )
        }

        it "fills line 58 with $240 and does not check federal checkbox" do
          allow(Efile::Nj::NjFlatEitcEligibility).to receive(:eligible?).and_return true

          # thousands
          expect(pdf_fields["58"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_152"]).to eq "2"
          expect(pdf_fields["undefined_153"]).to eq "4"
          expect(pdf_fields["Text170"]).to eq "0"
          # decimals
          expect(pdf_fields["Text171"]).to eq "0"
          expect(pdf_fields["Text172"]).to eq "0"

          # federal checkbox
          expect(pdf_fields["Check Box168"]).to eq "Off"

          # NJ CU checkbox
          expect(pdf_fields["Check Box169"]).to eq "Off"
        end
      end

      context 'when taxpayer does not qualify for NJ EITC' do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake, :df_data_minimal, :claimed_as_eitc_qualifying_child
          )
        }

        it "does not fill line 58 and does not check any checkboxes" do
          # thousands
          expect(pdf_fields["58"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_152"]).to eq ""
          expect(pdf_fields["undefined_153"]).to eq ""
          expect(pdf_fields["Text170"]).to eq ""
          # decimals
          expect(pdf_fields["Text171"]).to eq ""
          expect(pdf_fields["Text172"]).to eq ""

          # federal checkbox
          expect(pdf_fields["Check Box168"]).to eq "Off"

          # NJ CU checkbox
          expect(pdf_fields["Check Box169"]).to eq "Off"
        end
      end
    end

    describe "line 59 - excess UI/WF/SWF or UI/HC/WD" do
      let(:intake) { create(:state_file_nj_intake, :df_data_mfj) }

      context "without excess contributions" do 
        it "does not fill line 59" do 
          [
            "Text175",
            "Text174",
            "Text173",
            "undefined_155",
            "undefined_154",
            "59"
          ].each { |pdf_field| expect(pdf_fields[pdf_field]).to eq "" }
        end
      end

      context "with excess contributions" do 
        before do
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_59).and_return 123
        end
        it "fills line 59 with 123.00" do 
          # thousands
          expect(pdf_fields["59"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_154"]).to eq "1"
          expect(pdf_fields["undefined_155"]).to eq "2"
          expect(pdf_fields["Text173"]).to eq "3"
          # decimals
          expect(pdf_fields["Text174"]).to eq "0"
          expect(pdf_fields["Text175"]).to eq "0"
          
        end
      end
    end

    describe "line 61 - excess FLI" do
      let(:intake) { create(:state_file_nj_intake, :df_data_mfj) }

      context "without excess contributions" do 
        it "does not fill line 61" do 
          [
            "Text178",
            "Text177",
            "Text176",
            "undefined_157",
            "undefined_156",
            "60"
          ].each { |pdf_field| expect(pdf_fields[pdf_field]).to eq "" }
        end
      end

      context "with excess contributions" do 
        before do
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_61).and_return 123
        end
        it "fills line 61 with 123" do 
          # thousands
          expect(pdf_fields["60"]).to eq ""
          # hundreds
          expect(pdf_fields["undefined_156"]).to eq "1"
          expect(pdf_fields["undefined_157"]).to eq "2"
          expect(pdf_fields["Text176"]).to eq "3"
          # decimals
          expect(pdf_fields["Text177"]).to eq "0"
          expect(pdf_fields["Text178"]).to eq "0"
          
        end
      end
    end

    describe "line 64 child and dependent care credit" do
      let(:intake) {
        create(:state_file_nj_intake, :df_data_one_dep, :fed_credit_for_child_and_dependent_care)
      }
      it "adds 40% of federal credit for an income of 60k or less" do
        digits_in_pdf = ""
        digit_fields = [
          'undefined_168',
          'Text192',
          'Text193',
          'Text194',
          'Text195',
          'Text196',
        ]
        digit_fields.each do |field_name, _i|
          digits_in_pdf << pdf_fields[field_name]
          digits_in_pdf << "." if field_name == digit_fields[-3]
        end
        tax_credit = digits_in_pdf.to_f
        expect(tax_credit).to eq 400
      end
    end

    describe "line 65 nj child tax credit" do
      let(:intake) {
        create(
          :state_file_nj_intake,
          :df_data_one_dep
        )
      }
      before do
        intake.dependents.first.update(dob: Date.new(2023, 1, 1))
      end

      it "adds the correct number of dependents younger than 5" do
        expect(pdf_fields["64"]).to eq "1"
      end

      it "adds 600 per dependent for nj taxable incomes less than or equal to 50k" do
        digits_in_pdf = ""
        digit_fields = ["undefined_162",
                        "Text182",
                        "Text183",
                        "Text184",
                        "Text185",
                        "Text186"]
        digit_fields.each do |field_name, _i|
          digits_in_pdf << pdf_fields[field_name]
          digits_in_pdf << "." if field_name == digit_fields[-3]
        end
        tax_credit = digits_in_pdf.to_f
        expect(tax_credit).to eq 600
      end
    end
  end
end