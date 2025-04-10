# == Schema Information
#
# Table name: state_file_archived_intakes
#
#  id                      :bigint           not null, primary key
#  email_address           :string
#  failed_attempts         :integer          default(0), not null
#  fake_address_1          :string
#  fake_address_2          :string
#  hashed_ssn              :string
#  locked_at               :datetime
#  mailing_apartment       :string
#  mailing_city            :string
#  mailing_state           :string
#  mailing_street          :string
#  mailing_zip             :string
#  permanently_locked_at   :datetime
#  state_code              :string
#  tax_year                :integer
#  unsubscribed_from_email :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
require 'rails_helper'

RSpec.describe StateFileArchivedIntake, type: :model do
  describe "#increment_failed_attempts" do
    let!(:state_file_archived_intake) { create :state_file_archived_intake, failed_attempts: 1 }
    it "locks access when failed attempts is incremented to 2" do
      expect(state_file_archived_intake.access_locked?).to eq(false)

      state_file_archived_intake.increment_failed_attempts

      expect(state_file_archived_intake.access_locked?).to eq(true)
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
    let!(:state_file_archived_intake) { create(:state_file_archived_intake)}

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
          state_file_archived_intake.update!(state_code: "AZ")

          allow(state_file_archived_intake).to receive(:download_file_from_s3).and_call_original

          expect(state_file_archived_intake).to receive(:download_file_from_s3).with(
            "vita-min-prod-docs",
            "az_addresses.csv",
            Rails.root.join("tmp", "az_addresses.csv").to_s
          )

          state_file_archived_intake.send(:fetch_random_addresses)
        end

        it "uses the correct file key and bucket for NY" do
          state_file_archived_intake.update!(state_code: "NY")

          allow(state_file_archived_intake).to receive(:download_file_from_s3).and_call_original

          expect(state_file_archived_intake).to receive(:download_file_from_s3).with(
            "vita-min-prod-docs",
            "ny_addresses.csv",
            Rails.root.join("tmp", "ny_addresses.csv").to_s
          )

          state_file_archived_intake.send(:fetch_random_addresses)
        end
      end
    end

    context "when in staging environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("staging")) }

      it "uses the correct bucket and file key" do
        expect(state_file_archived_intake).to receive(:download_file_from_s3).with(
          "vita-min-staging-docs",
          "non_prod_addresses.csv",
          Rails.root.join("tmp", "non_prod_addresses.csv").to_s
        )

        state_file_archived_intake.send(:fetch_random_addresses)
      end
    end

    context "when in development environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development")) }

      it "uses the correct local file path" do
        expect(CSV).to receive(:read).with(
          Rails.root.join("app", "lib", "challenge_addresses", "test_addresses.csv"),
          headers: false
        ).and_return(["123 Fake St", "456 Imaginary Rd"])

        state_file_archived_intake.send(:fetch_random_addresses)
      end
    end

    context "when in test environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("test")) }

      it "uses the correct local file path" do
        expect(CSV).to receive(:read).with(
          Rails.root.join("app", "lib", "challenge_addresses", "test_addresses.csv"),
          headers: false
        )

        state_file_archived_intake.send(:fetch_random_addresses)
      end
    end

    context "when in demo environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("demo")) }

      it "uses the correct bucket and file key" do
        expect(state_file_archived_intake).to receive(:download_file_from_s3).with(
          "vita-min-demo-docs",
          "non_prod_addresses.csv",
          Rails.root.join("tmp", "non_prod_addresses.csv").to_s
        )

        state_file_archived_intake.send(:fetch_random_addresses)
      end
    end
  end

  describe "#populate_fake_addresses" do
    let(:state_file_archived_intake) { build(:state_file_archived_intake, hashed_ssn: nil) }

    context "when state_file_archived_intake hashed ssn is nil" do

      it "does not populate fake_address_1 and fake_address_2" do
        state_file_archived_intake.save

        expect(state_file_archived_intake.fake_address_1).to be_nil
        expect(state_file_archived_intake.fake_address_2).to be_nil
      end
    end
  end
end
