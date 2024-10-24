require 'rails_helper'

RSpec.describe StateFile::ImportFromDirectFileJob, type: :job do
  describe '#perform' do
    let(:intake) { create :minimal_state_file_id_intake, raw_direct_file_data: nil }
    let(:xml_result) { StateFile::DirectFileApiResponseSampleService.new.read_xml('id_ernest_hoh') }
    let(:direct_file_intake_json) { StateFile::DirectFileApiResponseSampleService.new.read_json('id_ernest_hoh') }
    let(:json_result) do
      {
        "xml" => xml_result,
        "directFileData" => direct_file_intake_json,
        "submissionId" => "91873649812736",
        "status" => "accepted"
      }
    end

    before do
      allow(IrsApiService).to receive(:import_federal_data).and_return(json_result)
      allow(DfDataTransferJobChannel).to receive(:broadcast_job_complete)
      allow(intake).to receive(:synchronize_df_dependents_to_database).and_call_original
      allow(intake).to receive(:synchronize_df_1099_rs_to_database).and_call_original
      allow(intake).to receive(:synchronize_df_w2s_to_database).and_call_original
      allow(intake).to receive(:synchronize_filers_to_database).and_call_original
    end

    context "with a successful direct file response" do
      it "calls the DF api, updates the intake and broadcasts to the ActionCable channel" do
        auth_code = "8700210c-781c-4db6-8e25-8db4e1082312"
        described_class.perform_now(authorization_code: auth_code, intake: intake)

        expect(IrsApiService).to have_received(:import_federal_data).with(auth_code, "id")
        expect(intake).to have_received(:synchronize_df_dependents_to_database)
        expect(intake).to have_received(:synchronize_df_1099_rs_to_database)
        expect(intake).to have_received(:synchronize_df_w2s_to_database)
        expect(intake).to have_received(:synchronize_filers_to_database)
        expect(intake.federal_submission_id).to eq "91873649812736"
        expect(intake.federal_return_status).to eq "accepted"
        expect(intake.raw_direct_file_data).to eq xml_result
        expect(intake.raw_direct_file_intake_data).to eq direct_file_intake_json
        expect(intake.dependents.count).to eq(3)
        expected_hashed_ssn = OpenSSL::HMAC.hexdigest(
          "SHA256",
          EnvironmentCredentials.dig(:duplicate_hashing_key),
          "ssn|400000010"
        )
        expect(intake.hashed_ssn).to eq expected_hashed_ssn
        expect(DfDataTransferJobChannel).to have_received(:broadcast_job_complete)
      end

      it "clears df_data_import_failed_at if there was a previous failure" do
        intake.update(df_data_import_failed_at: DateTime.now - 5.minutes)
        auth_code = "8700210c-781c-4db6-8e25-8db4e1082312"
        described_class.perform_now(authorization_code: auth_code, intake: intake)

        expect(intake.df_data_import_failed_at).to eq nil
      end
    end

    context "when the direct file xml is formed in a way that causes our code to error" do
      before do
        allow(intake).to receive(:synchronize_df_dependents_to_database).and_raise StandardError.new("Malformed data")
      end

      it "catches the error and persists it to the intake record" do
        auth_code = "8700210c-781c-4db6-8e25-8db4e1082312"
        described_class.perform_now(authorization_code: auth_code, intake: intake)

        expect(intake.df_data_import_failed_at).to be_present
        expect(intake.df_data_import_errors.count).to eq(1)
        expect(intake.df_data_import_errors.first.message).to eq("Malformed data")
      end
    end

    context "when the direct file data is missing" do
      let(:json_result) { nil }
      it "marks the failure gracefully" do
        auth_code = "8700210c-781c-4db6-8e25-8db4e1082312"
        described_class.perform_now(authorization_code: auth_code, intake: intake)

        expect(intake.df_data_import_failed_at).to be_present
        expect(intake.raw_direct_file_data).to_not be_present
        expect(intake.df_data_import_errors.count).to eq(1)
        expect(intake.df_data_import_errors.first.message).to eq("Direct file data was not transferred for intake id #{intake.id}.")
      end
    end
  end
end
