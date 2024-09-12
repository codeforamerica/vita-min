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
        ) }

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
        ) }

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

    describe "spouse SSN" do
      context "with spouse SSN" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            spouse_ssn: "123456789",
            spouse_first_name: "Ada"
          ) }

        it 'sets spouse SSN fields' do
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
      end

      context "without spouse SSN" do
        let(:submission) {
          create :efile_submission, tax_return: nil, data_source: create(
            :state_file_nj_intake,
            spouse_ssn: ""
          ) }

        it 'leaves spouse SSN fields blank' do
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
          ) }
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
            ) }
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
          ) }
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
            ) }
          it 'fills pdf with LastName FirstName' do
            expect(pdf_fields[name_field]).to eq "Hopper Grace"
          end
        end

        context "with middle initial" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              primary_first_name: "Grace",
              primary_last_name: "Hopper",
              primary_middle_initial: "B"
            ) }
          it 'fills pdf with LastName FirstName MI' do
            expect(pdf_fields[name_field]).to eq "Hopper Grace B"
          end
        end

        context "with suffix" do
          let(:submission) {
            create :efile_submission, tax_return: nil, data_source: create(
              :state_file_nj_intake,
              primary_first_name: "Grace",
              primary_last_name: "Hopper",
              primary_suffix: "JR"
            ) }
          it 'fills pdf with LastName FirstName Suf' do
            expect(pdf_fields[name_field]).to eq "Hopper Grace JR"
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
            ) }
          it 'fills pdf with LastName FirstName MI Suf' do
            expect(pdf_fields[name_field]).to eq "Hopper Grace B JR"
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
            ) }
          it 'fills pdf with LastName FirstName & FirstName' do
            expect(pdf_fields[name_field]).to eq "Muppet Bert S & Ernie"
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
            ) }
          it 'fills pdf with LastName FirstName & LastName FirstName' do
            expect(pdf_fields[name_field]).to eq "Lively Blake E & Reynolds Ryan"
          end
        end
      end
    end

    describe "address fields" do
      let(:submission) {
        create :efile_submission, tax_return: nil, data_source: create(
          :state_file_nj_intake,
        ) }

      it 'enters values into PDF' do
        # address values from zeus_one_dep.xml
        expect(pdf_fields["SpousesCU Partners SSN if filing jointly"]).to eq "391 US-206 B"
        expect(pdf_fields["CountyMunicipality Code See Table page 50"]).to eq "Hammonton"
        expect(pdf_fields["State"]).to eq "NJ"
        expect(pdf_fields["ZIP Code"]).to eq "08037"
      end
    end
  end
end