require 'rails_helper'

describe SubmissionBuilder::Ty2022::States::ReturnHeader do
  describe '.document' do
    context "filer DOBs" do
      let(:submission) { create(:efile_submission, data_source: intake) }

      context "single filer" do
        let(:primary_birth_date) { 40.years.ago }
        let(:intake) {
          create(
            :state_file_ny_intake,
            primary_birth_date: primary_birth_date
          )
        }

        it "generates xml with primary filer DOB only" do
          doc = SubmissionBuilder::Ty2022::States::ReturnHeader.new(submission).document
          expect(doc.at("Filer Primary DateOfBirth").text).to eq primary_birth_date.strftime("%F")
          expect(doc.at("Filer Secondary DateOfBirth")).not_to be_present
        end
      end

      context "filer with spouse" do
        let(:primary_birth_date) { 40.years.ago }
        let(:spouse_birth_date) { 42.years.ago }
        let(:intake) {
          create(
            :state_file_ny_intake,
            primary_birth_date: primary_birth_date,
            filing_status: "married_filing_jointly",
            spouse_first_name: "Spouse",
            spouse_birth_date: spouse_birth_date,
            raw_direct_file_data: StateFile::XmlReturnSampleService.new.read("ny_robert_mfj")
          )
        }

        it "generates xml with primary and spouse DOBs" do
          doc = SubmissionBuilder::Ty2022::States::ReturnHeader.new(submission).document
          expect(doc.at("Filer Primary DateOfBirth").text).to eq primary_birth_date.strftime("%F")
          expect(doc.at("Filer Secondary DateOfBirth").text).to eq spouse_birth_date.strftime("%F")
        end
      end
    end

    context "misc other attributes" do
      let(:intake) { create :state_file_az_intake }
      let(:submission) { create(:efile_submission, data_source: intake) }

      it "generates xml with the right values" do
        doc = SubmissionBuilder::Ty2022::States::ReturnHeader.new(submission).document
        expect(doc.at("ReturnType").text).to eq "Form140"
      end
    end
  end
end
