require "rails_helper"

describe SubmissionBundle do
  let(:submission_2020) { create :efile_submission, :ctc, tax_year: 2020, irs_submission_id: "12345202201011234569" }
  let(:submission_2021) { create :efile_submission, :ctc, tax_year: 2021, irs_submission_id: "12345202201011234568" }
  let(:submission) { create :efile_submission, :ctc, tax_year: 2021, irs_submission_id: "12345202201011234567" }

  before do
    submission_2020.intake.update(
      primary_signature_pin: "12345",
      primary_signature_pin_at: DateTime.new(2021, 4, 20, 16, 20),
    )
    submission_2021.intake.update(
      primary_signature_pin: "12345",
      primary_signature_pin_at: DateTime.new(2022, 4, 20, 16, 20),
    )
  end

  around do |example|
    ENV["TEST_SCHEMA_VALIDITY_ONLY"] = 'true'
    example.run
    ENV.delete("TEST_SCHEMA_VALIDITY_ONLY")
  end

  describe "#build" do
    it "stores the submission bundle on the submission" do
      response = described_class.new(submission_2020).build

      expect(submission_2020.reload.submission_bundle).to be_present
      expect(submission_2020.submission_bundle.content_type).to eq "application/zip"
      file_name = ActiveStorage::Blob.service.path_for(submission_2020.submission_bundle.key)
      Zip::File.open_buffer(File.open(file_name, "rb")) do |zip_file|
        expect(zip_file.entries.first.name).to eq "manifest/manifest.xml"
        expect(zip_file.entries.last.name).to eq "xml/submission.xml"
      end
      expect(response).to be_valid
    end

    context "when a SubmissionBuilder instance is not valid" do
      let(:submission_builder_double) { double(SubmissionBuilder::Response) }
      let(:errors) { ['error', 'error'] }
      before do
        allow(SubmissionBuilder::FederalManifest).to receive(:build).and_return SubmissionBuilder::Response.new(errors: errors, document: nil)
      end

      it "returns errors from the SubmissionBuilder::Response" do
        expect(described_class.new(submission_2020).build.errors).to eq ['error', 'error']
      end
    end

    context "using appropriate documents per tax year" do
      before do
        allow(SubmissionBuilder::Ty2020::Return1040).to receive(:build).and_return SubmissionBuilder::Response.new(errors: [], document: nil)
        allow(SubmissionBuilder::Ty2021::Return1040).to receive(:build).and_return SubmissionBuilder::Response.new(errors: [], document: nil)
      end

      context "when the tax year is 2020" do
        it "calls the TY2020 submission builder class" do
          described_class.new(submission_2020).build
          expect(SubmissionBuilder::Ty2020::Return1040).to have_received(:build).with(submission_2020)
        end
      end

      context "when the tax year is 2021" do
        it "calls the TY2021 submission builder class" do
          described_class.new(submission_2021).build
          expect(SubmissionBuilder::Ty2021::Return1040).to have_received(:build).with(submission_2021)
        end
      end
    end
  end

  describe "state filing" do
    context "NY state" do
      let(:submission) {
        create(:efile_submission, data_source: create(:state_file_ny_intake, :with_efile_device_infos), irs_submission_id: "12345202201011234570")
      }
      it "can bundle a minimal NY return" do
        expect(described_class.new(submission).build.errors).to eq([])
      end
    end

    context "AZ state" do
      let(:submission) {
        create(:efile_submission, data_source: create(:state_file_az_intake, :with_efile_device_infos), irs_submission_id: "12345202201011234570")
      }

      it "can bundle a minimal AZ return" do
        expect(described_class.new(submission).build.errors).to eq([])
      end
    end
  end
end
