require 'rails_helper'

RSpec.describe PdfFiller::Nj1040Pdf do
  include PdfSpecHelper

  let(:submission) { create :efile_submission, tax_return: nil, data_source: create(:state_file_nj_intake) }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }

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

        it "fills pdf with Line 7 fields" do
          expect(pdf_fields["Check Box41"]).to eq "Off"
          expect(pdf_fields["Check Box42"]).to eq "Off"
          expect(pdf_fields["x  1000_2"]).to eq "0"
          expect(pdf_fields["undefined_9"]).to eq "0"
        end

        context "primary over 65" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              :primary_over_65,
            )
          }
          it "fills pdf with Line 7 fields" do
            expect(pdf_fields["Check Box41"]).to eq "Yes"
            expect(pdf_fields["Check Box42"]).to eq "Off"
            expect(pdf_fields["x  1000_2"]).to eq "1000"
            expect(pdf_fields["undefined_9"]).to eq "1"
          end
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

        it "fills pdf with Line 7 fields" do
          expect(pdf_fields["Check Box41"]).to eq "Off"
          expect(pdf_fields["Check Box42"]).to eq "Off"
          expect(pdf_fields["x  1000_2"]).to eq "0"
          expect(pdf_fields["undefined_9"]).to eq "0"
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
              primary_last_name: "Hopper"
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
      let(:submission) {
        create :efile_submission, tax_return: nil, data_source: create(
          :state_file_nj_intake,
        )
      }

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
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: intake
        }

        before do
          intake.dependents[0].update(dob: Date.new(2023, 1, 1))
        end

        it 'enters single dependent into PDF' do
          # dependent 1
          expect(pdf_fields["Last Name First Name Middle Initial 1"]).to eq "ATHENS KRONOS"
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
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: intake
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
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            :df_data_minimal
          )
        }

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

        it "includes the rounded sum 200,001.33 split into each box on line 15" do
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
          expect(pdf_fields["Text104"]).to eq "1"
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

        it "includes the rounded sum 62,345.67 split into each box on line 15" do
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
          expect(pdf_fields["Text104"]).to eq "6"
          # decimals
          expect(pdf_fields["Text105"]).to eq "0"
          expect(pdf_fields["Text106"]).to eq "0"
        end
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

    describe "lines 40a and 40b" do
      context "when taxpayer is a renter" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
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
    end
  end
end