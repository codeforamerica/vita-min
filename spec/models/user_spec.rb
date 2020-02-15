# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  birth_date                :string
#  city                      :string
#  consented_to_service      :integer          default("unfilled"), not null
#  consented_to_service_at   :datetime
#  consented_to_service_ip   :string
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :inet
#  email                     :string
#  email_notification_opt_in :integer          default("unfilled"), not null
#  first_name                :string
#  is_spouse                 :boolean          default(FALSE)
#  last_name                 :string
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :inet
#  phone_number              :string
#  provider                  :string
#  sign_in_count             :integer          default(0), not null
#  sms_notification_opt_in   :integer          default("unfilled"), not null
#  ssn                       :string
#  state                     :string
#  street_address            :string
#  uid                       :string
#  zip_code                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  intake_id                 :bigint           not null
#
# Indexes
#
#  index_users_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#

require "rails_helper"

RSpec.describe User, type: :model do
  describe "default column values" do
    it "sets is_spouse to false by default" do
      user = build :user
      expect(user.is_spouse).to eq false
    end
  end

  describe "#intake" do
    it "requires an intake" do
      user = build :user, intake: nil
      expect(user).not_to be_valid
      expect(user.errors).to include :intake
    end

    it "should belong to an intake" do
      relation = User.reflect_on_association(:intake).macro
      expect(relation).to eq :belongs_to
    end
  end

  describe "#contact_info_filtered_by_preferences" do
    let(:user) do
      build :user,
            phone_number: "14158161286",
            email: "supermane@fantastic.horse",
            email_notification_opt_in: email,
            sms_notification_opt_in: sms
    end

    context "when they want all notifications" do
      let(:email){ "yes" }
      let(:sms){ "yes" }

      it "returns email and phone_number in a hash" do
        expected_result = {
          email: "supermane@fantastic.horse",
          phone_number: "14158161286",
        }
        expect(user.contact_info_filtered_by_preferences).to eq expected_result
      end
    end

    context "when they want sms only" do
      let(:email){ "no" }
      let(:sms){ "yes" }

      it "returns phone_number in a hash" do
        expected_result = {
          phone_number: "14158161286",
        }
        expect(user.contact_info_filtered_by_preferences).to eq expected_result

      end
    end

    context "when they want email only" do
      let(:email){ "yes" }
      let(:sms){ "no" }

      it "returns email in a hash" do
        expected_result = {
          email: "supermane@fantastic.horse",
        }
        expect(user.contact_info_filtered_by_preferences).to eq expected_result
      end
    end

    context "when they don't want any notifications" do
      let(:email){ "no" }
      let(:sms){ "no" }

      it "returns an empty hash" do
        expect(user.contact_info_filtered_by_preferences).to eq({})
      end
    end
  end

  describe ".from_omniauth" do
    context "with valid data from omniauth" do
      let(:auth) do
        OmniAuth::AuthHash.new({
          provider: "idme",
          uid: "123545",
          info: {
            first_name: "Gary",
            last_name: "Gnome",
            email: "gary.gardengnome@example.green",
            birth_date: "1993-09-06",
            phone: "15552223333",
            social: "123224567",
            street: "1234 Green St",
            city: "Passaic Park",
            state: "New Jersey",
            zip_code: "22233",
          }
        })
      end

      context "with an existing user record that matches provider and uid" do
        let!(:user) { create :user, provider: auth.provider, uid: auth.uid }

        it "does not create a new record" do
          expect {
            described_class.from_omniauth(auth)
          }.not_to change(User, :count)
        end
      end

      context "with no matching records" do
        it "initializes a new record with the auth attributes without saving" do
          user = nil

          expect {
            user = described_class.from_omniauth(auth)
          }.not_to change(User, :count)


          expect(user.provider).to eq "idme"
          expect(user.uid).to eq "123545"
          expect(user.first_name).to eq "Gary"
          expect(user.last_name).to eq "Gnome"
          expect(user.email).to eq "gary.gardengnome@example.green"
          expect(user.birth_date).to eq "1993-09-06"
          expect(user.phone_number).to eq "15552223333"
          expect(user.ssn).to eq "123224567"
          expect(user.street_address).to eq "1234 Green St"
          expect(user.city).to eq "Passaic Park"
          expect(user.state).to eq "nj"
          expect(user.zip_code).to eq "22233"
        end
      end
    end

    context "with a mostly empty sandbox data hash from omniauth" do
      let(:auth) do
        OmniAuth::AuthHash.new({
          provider: "idme",
          uid: "123545",
          info: {
            first_name: "VERONICA",
            last_name: "PERSINGER",
            email: "gary.gardengnome@example.green",
            phone: "15552223333",
            social: "123456789",
            zip_code: "55016",
          }
        })
      end

      context "on non production environments" do
        before { allow(Rails).to receive(:env) { "demo".inquiry } }

        it "saves the user with default fake data" do
          user = described_class.from_omniauth(auth)

          expect(user.first_name).to eq "Fake"
          expect(user.last_name).to eq "Person"
          expect(user.email).to eq "gary.gardengnome@example.green"
          expect(user.birth_date).to eq "1991-01-20"
          expect(user.phone_number).to eq "15552223333"
          expect(user.ssn).to eq "123456789"
          expect(user.street_address).to eq "927 Mission St"
          expect(user.city).to eq "San Francisco"
          expect(user.state).to eq "ca"
          expect(user.zip_code).to eq "55016"
        end
      end

      context "on production" do
        before { allow(Rails).to receive(:env) { "production".inquiry } }

        it "saves the user with mostly empty data hash" do
          user = described_class.from_omniauth(auth)

          expect(user.first_name).to eq "VERONICA"
          expect(user.last_name).to eq "PERSINGER"
          expect(user.email).to eq "gary.gardengnome@example.green"
          expect(user.birth_date).to eq nil
          expect(user.phone_number).to eq "15552223333"
          expect(user.ssn).to eq "123456789"
          expect(user.street_address).to eq nil
          expect(user.city).to eq nil
          expect(user.state).to eq nil
          expect(user.zip_code).to eq "55016"
        end
      end
    end
  end
end
