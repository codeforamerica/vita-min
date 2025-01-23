# == Schema Information
#
# Table name: state_file_archived_intake_requests
#
#  id                            :bigint           not null, primary key
#  email_address                 :string
#  failed_attempts               :integer          default(0), not null
#  fake_address_1                :string
#  fake_address_2                :string
#  ip_address                    :string
#  locked_at                     :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  state_file_archived_intake_id :bigint
#
# Indexes
#
#  idx_on_state_file_archived_intake_id_7dd0f99380  (state_file_archived_intake_id)
#
require "rails_helper"

describe StateFileArchivedIntakeRequest do
  describe "#increment_failed_attempts" do
    let!(:request_instance) { create :state_file_archived_intake_request, failed_attempts: 1 }
    it "locks access when failed attempts is incremented to 2" do
      expect(request_instance.access_locked?).to eq(false)

      request_instance.increment_failed_attempts

      expect(request_instance.access_locked?).to eq(true)
    end
  end

  describe "#s3_credentials" do
    context "AWS_ACCESS_KEY_ID in ENV" do
      it "uses the environment variables" do
        stub_const("ENV", {
          "AWS_ACCESS_KEY_ID" => "mock-aws-access-key-id",
          "AWS_SECRET_ACCESS_KEY" => "mock-aws-secret-access-key"
        })
        credentials = SchemaFileLoader.s3_credentials
        expect(credentials.access_key_id).to eq "mock-aws-access-key-id"
      end
    end

    context "without AWS_ACCESS_KEY_ID in ENV" do
      it "uses the rails credentials" do
        stub_const("ENV", {})
        expect(Rails.application.credentials).to receive(:dig).with(:aws, :access_key_id).and_return "mock-aws-access-key-id"
        expect(Rails.application.credentials).to receive(:dig).with(:aws, :secret_access_key).and_return "mock-aws-secret-access-key"
        credentials = SchemaFileLoader.s3_credentials
        expect(credentials.access_key_id).to eq "mock-aws-access-key-id"
      end
    end
  end

  describe '#determine_csv_file_path' do
    let(:state_file_archived_intake_request) { build(:state_file_archived_intake_request) }

    context 'in development or test environment' do
      it 'returns the correct file path for development' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))

        file_path = state_file_archived_intake_request.send(:determine_csv_file_path)

        expect(file_path).to eq(Rails.root.join('app', 'lib', 'challenge_addresses', 'test_addresses.csv'))
      end

      it 'returns the correct file path for test' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))

        file_path = state_file_archived_intake_request.send(:determine_csv_file_path)

        expect(file_path).to eq(Rails.root.join('app', 'lib', 'challenge_addresses', 'test_addresses.csv'))
      end
    end

    context 'in production or other environments' do
      it 'returns the correct file path and ensures S3 download is called for AZ' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        allow(File).to receive(:exist?).and_return(false)
        state_file_archived_intake_request.state_file_archived_intake = build(:state_file_archived_intake, mailing_state: 'AZ')

        expect(state_file_archived_intake_request).to receive(:download_file_from_s3).with(
          Rails.root.join('tmp', 'challenge_addresses.csv')
        )

        file_path = state_file_archived_intake_request.send(:determine_csv_file_path)

        expect(file_path).to eq(Rails.root.join('tmp', 'challenge_addresses.csv'))
      end

      it 'returns the correct file path and ensures S3 download is called for NY' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        allow(File).to receive(:exist?).and_return(false)
        state_file_archived_intake_request.state_file_archived_intake = build(:state_file_archived_intake, mailing_state: 'NY')

        expect(state_file_archived_intake_request).to receive(:download_file_from_s3).with(
          Rails.root.join('tmp', 'challenge_addresses.csv')
        )

        file_path = state_file_archived_intake_request.send(:determine_csv_file_path)

        expect(file_path).to eq(Rails.root.join('tmp', 'challenge_addresses.csv'))
      end
    end
  end
end
