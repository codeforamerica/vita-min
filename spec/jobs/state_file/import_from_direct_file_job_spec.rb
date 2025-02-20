require 'rails_helper'

RSpec.describe StateFile::ImportFromDirectFileJob, type: :job do
  describe '#perform' do
    let(:intake) { create :minimal_state_file_id_intake, raw_direct_file_data: nil }
    let(:xml_result) { StateFile::DirectFileApiResponseSampleService.new.read_xml('test_ernest_hoh') }
    let(:direct_file_intake_json) { StateFile::DirectFileApiResponseSampleService.new.read_json('test_ernest_hoh') }
    let(:authorization_code) { 'test_ernest_hoh' }
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

      it "sets df_data_import_succeeded_at" do
        auth_code = "8700210c-781c-4db6-8e25-8db4e1082312"
        described_class.perform_now(authorization_code: auth_code, intake: intake)

        expect(intake.df_data_import_succeeded_at).to be_present
      end
    end

    context "when the direct file xml is formed in a way that causes our code to error" do
      before do
        allow(intake).to receive(:synchronize_df_dependents_to_database).and_raise StandardError.new("Malformed data")
      end

      it "catches the error and persists it to the intake record" do
        auth_code = "8700210c-781c-4db6-8e25-8db4e1082312"
        described_class.perform_now(authorization_code: auth_code, intake: intake)

        expect(intake.df_data_import_succeeded_at).to be_nil
        expect(intake.df_data_import_errors.count).to eq(1)
        expect(intake.df_data_import_errors.first.message).to eq("Malformed data")
      end
    end

    context "when the DF data contains invalid data in associated models that can be corrected by the user later" do
      let(:xml_result) { StateFile::DirectFileApiResponseSampleService.new.read_xml('test_miranda_1099r_with_df_w2_error') }
      let(:direct_file_intake_json) { StateFile::DirectFileApiResponseSampleService.new.read_json('test_miranda_1099r_with_df_w2_error') }

      it "ignores the errors so that the user can continue through the application" do
        auth_code = "miranda_1099r_with_df_w2_error"
        described_class.perform_now(authorization_code: auth_code, intake: intake)

        expect(intake.df_data_import_succeeded_at).to be_present
        expect(intake.df_data_import_errors).to be_empty

        expect(intake.state_file_w2s.first).not_to be_valid(:state_file_edit)
        expect(intake.state_file1099_rs.second).not_to be_valid(:retirement_income_intake)
      end
    end

    context "when the direct file data is missing" do
      let(:json_result) { nil }
      it "marks the failure gracefully" do
        auth_code = "8700210c-781c-4db6-8e25-8db4e1082312"
        described_class.perform_now(authorization_code: auth_code, intake: intake)

        expect(intake.df_data_import_succeeded_at).to be_nil
        expect(intake.raw_direct_file_data).to_not be_present
        expect(intake.df_data_import_errors.count).to eq(1)
        expect(intake.df_data_import_errors.first.message).to eq("Direct file data was not transferred for intake id #{intake.id}.")
      end
    end

    context "with duplicated state_file_w2s" do
      let(:authorization_code) { '78126520243400w44xy0' }
      let!(:state_file_w2) { create :state_file_w2, w2_index: 0, employer_name: "First Enterprises", state_file_intake: intake }
      let!(:state_file_w2_dup) { create :state_file_w2, w2_index: 0, state_file_intake: intake }

      before do
        allow(Rails.logger).to receive(:info)
        allow(intake).to receive(:synchronize_df_w2s_to_database) # does nothing
      end

      it "should destroy duplicate state_file_w2s" do
        expect(intake.state_file_w2s.count).to eq(2)

        described_class.perform_now(authorization_code: authorization_code, intake: intake)

        expect(intake.state_file_w2s.count).to eq(1)
        expect(intake.state_file_w2s.map(&:w2_index)).to include(0)
        expect(Rails.logger).to have_received(:info).with("ImportFromDirectFileJob removing duplicates StateFileW2 for id #{intake.id}")
      end
    end

    context "with duplicated state_file_dependents" do
      let!(:dependent) { create(:state_file_dependent, intake: intake, ssn: "123456789") }
      let!(:duplicate_dependent) { create(:state_file_dependent, intake: intake, ssn: "123456789") }
      let!(:another_dependent) { create(:state_file_dependent, intake: intake, ssn: "123456780") }

      before do
        allow(Rails.logger).to receive(:info)
        allow(intake).to receive(:synchronize_df_dependents_to_database) # does nothing
      end

      it "should destroy duplicate dependent" do
        expect(intake.dependents.count).to eq(3)

        described_class.perform_now(authorization_code: authorization_code, intake: intake)

        expect(intake.dependents.count).to eq(2)
        expect(intake.dependents.map(&:ssn)).to include("123456789")
        expect(intake.dependents.map(&:ssn)).to include("123456780")
        expect(Rails.logger).to have_received(:info).with("ImportFromDirectFileJob removing duplicates StateFileDependent for id #{intake.id}")
      end
    end
  end
end
