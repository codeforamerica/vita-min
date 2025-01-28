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

  describe "#fetch_random_addresses" do
    let(:state_file_archived_intake) { create(:state_file_archived_intake, mailing_state: "NY") }
    let(:state_file_archived_intake_request) { create(:state_file_archived_intake_request, state_file_archived_intake: state_file_archived_intake) }

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(
        double("Aws::S3::Client", get_object: true)
      )
      allow(CSV).to receive(:read).and_return(["123 Fake St", "456 Imaginary Rd"])
    end

    context "when in production environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production")) }
      context "when state_file_archived_intake has different mailing states" do
        it "uses the correct file key and for AZ" do
          state_file_archived_intake.update!(mailing_state: "AZ")
          state_file_archived_intake_request.update!(state_file_archived_intake: state_file_archived_intake)

          allow(state_file_archived_intake_request).to receive(:download_file_from_s3).and_call_original

          expect(state_file_archived_intake_request).to receive(:download_file_from_s3).with(
            "vita-min-prod-docs",
            "az_addresses.csv",
            Rails.root.join("tmp", "az_addresses.csv").to_s
          )

          state_file_archived_intake_request.send(:fetch_random_addresses)
        end

        it "uses the correct file key and bucket for NY" do
          state_file_archived_intake.update!(mailing_state: "NY")
          state_file_archived_intake_request.update!(state_file_archived_intake: state_file_archived_intake)

          allow(state_file_archived_intake_request).to receive(:download_file_from_s3).and_call_original

          expect(state_file_archived_intake_request).to receive(:download_file_from_s3).with(
            "vita-min-prod-docs",
            "ny_addresses.csv",
            Rails.root.join("tmp", "ny_addresses.csv").to_s
          )

          state_file_archived_intake_request.send(:fetch_random_addresses)
        end
      end
    end

    context "when in staging environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("staging")) }

      it "uses the correct bucket and file key" do
        expect(state_file_archived_intake_request).to receive(:download_file_from_s3).with(
          "vita-min-staging-docs",
          "non_prod_addresses.csv",
          Rails.root.join("tmp", "non_prod_addresses.csv").to_s
        )

        state_file_archived_intake_request.send(:fetch_random_addresses)
      end
    end

    context "when in development environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development")) }

      it "uses the correct local file path" do
        expect(CSV).to receive(:read).with(
          Rails.root.join("app", "lib", "challenge_addresses", "test_addresses.csv"),
          headers: false
        ).and_return(["123 Fake St", "456 Imaginary Rd"])

        state_file_archived_intake_request.send(:fetch_random_addresses)
      end
    end

    context "when in test environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("test")) }

      it "uses the correct local file path" do
        expect(CSV).to receive(:read).with(
          Rails.root.join("app", "lib", "challenge_addresses", "test_addresses.csv"),
          headers: false
        )

        state_file_archived_intake_request.send(:fetch_random_addresses)
      end
    end

    context "when in demo environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("demo")) }

      it "uses the correct bucket and file key" do
        expect(state_file_archived_intake_request).to receive(:download_file_from_s3).with(
          "vita-min-demo-docs",
          "non_prod_addresses.csv",
          Rails.root.join("tmp", "non_prod_addresses.csv").to_s
        )

        state_file_archived_intake_request.send(:fetch_random_addresses)
      end
    end
  end

  describe "#populate_fake_addresses" do
    let(:state_file_archived_intake_request) { build(:state_file_archived_intake_request, fake_address_1: nil, fake_address_2: nil) }

    context "when state_file_archived_intake is not present" do
      before { allow(state_file_archived_intake_request).to receive(:state_file_archived_intake).and_return(nil) }

      it "does not populate fake_address_1 and fake_address_2" do
        state_file_archived_intake_request.save

        expect(state_file_archived_intake_request.fake_address_1).to be_nil
        expect(state_file_archived_intake_request.fake_address_2).to be_nil
      end
    end
  end
end
