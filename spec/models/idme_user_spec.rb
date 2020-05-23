# == Schema Information
#
# Table name: idme_users
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
#  encrypted_ssn             :string
#  encrypted_ssn_iv          :string
#  first_name                :string
#  is_spouse                 :boolean          default(FALSE)
#  last_name                 :string
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :inet
#  phone_number              :string
#  provider                  :string
#  sign_in_count             :integer          default(0), not null
#  sms_notification_opt_in   :integer          default("unfilled"), not null
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
#  index_idme_users_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#

require "rails_helper"

RSpec.describe IdmeUser, type: :model do
  describe "default column values" do
    it "sets is_spouse to false by default" do
      user = build :idme_user
      expect(user.is_spouse).to eq false
    end
  end

  describe "#intake" do
    it "requires an intake" do
      user = build :idme_user, intake: nil
      expect(user).not_to be_valid
      expect(user.errors).to include :intake
    end

    it "should belong to an intake" do
      relation = described_class.reflect_on_association(:intake).macro
      expect(relation).to eq :belongs_to
    end
  end

  describe "#age_end_of_tax_year" do
    let(:user) { build :idme_user, birth_date: "1990-04-21" }

    it "returns their age at the end of 2019" do
      expect(user.age_end_of_tax_year).to eq 29
    end

    context "when birth_date is nil" do
      let(:user) { build :idme_user, birth_date: nil }

      it "returns nil and does not error" do
        expect(user.age_end_of_tax_year).to be_nil
      end
    end
  end

  describe "#contact_info_filtered_by_preferences" do
    let(:phone_number) { "+14158161286" }
    let(:user) do
      build :idme_user,
            phone_number: phone_number,
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
          phone_number: "+14158161286",
        }
        expect(user.contact_info_filtered_by_preferences).to eq expected_result
      end

      context "when the phone number is not in E164 standard format" do
        let(:phone_number ) { "4158161286" }

        it "standardizes the phone number" do
          expect(user.contact_info_filtered_by_preferences)
            .to include(phone_number: "+14158161286")
        end
      end
    end

    context "when they want sms only" do
      let(:email){ "no" }
      let(:sms){ "yes" }

      it "returns phone_number in a hash" do
        expected_result = {
          phone_number: "+14158161286",
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

    context "when the phone number is nil" do
      let(:email){ "yes" }
      let(:sms){ "yes" }
      let(:phone_number) { nil }

      it "returns nil" do
        expect(user.contact_info_filtered_by_preferences).to include(phone_number: nil)
      end
    end
  end

  describe ".from_omniauth" do
  end
end
