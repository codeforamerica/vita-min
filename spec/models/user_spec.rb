# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  active                    :boolean
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :string
#  email                     :string           not null
#  encrypted_access_token    :string
#  encrypted_access_token_iv :string
#  encrypted_password        :string           default(""), not null
#  failed_attempts           :integer          default(0), not null
#  invitation_accepted_at    :datetime
#  invitation_created_at     :datetime
#  invitation_limit          :integer
#  invitation_sent_at        :datetime
#  invitation_token          :string
#  invitations_count         :integer          default(0)
#  is_beta_tester            :boolean          default(FALSE), not null
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :string
#  locked_at                 :datetime
#  name                      :string
#  provider                  :string
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  role                      :string
#  sign_in_count             :integer          default(0), not null
#  suspended                 :boolean
#  ticket_restriction        :string
#  timezone                  :string           default("America/New_York"), not null
#  two_factor_auth_enabled   :boolean
#  uid                       :string
#  verified                  :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  invited_by_id             :bigint
#  vita_partner_id           :bigint
#  zendesk_user_id           :bigint
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_vita_partner_id       (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require "rails_helper"

RSpec.describe User, type: :model do
  describe ".from_zendesk_oauth" do
    let(:email) { "ttomato@itsafruit.orange" }
    let(:auth) do
      OmniAuth::AuthHash.new({
        provider: "zendesk",
        uid: 89178938838417938,
        credentials: {
          token: "a87dsgf87aghs"
        },
        info: {
          id: 89178938838417938,
          name: "Tom Tomato",
          email: email,
          role: "admin",
          ticket_restriction: nil,
          two_factor_auth_enabled: true,
          active: true,
          suspended: false,
          verified: true
        }
      })
    end

    context "with existing user with the same email" do
      let(:email) { "ttomato@itsafruit.orange" }
      let(:old_uid) { 1 }
      let(:old_name) { "Tim Tomato" }
      let!(:existing_user) { create :user, name: old_name, email: email, uid: old_uid }

      it "updates all the fields on the model" do
        expect do
          result = described_class.from_zendesk_oauth(auth)
          expect(result).to eq existing_user
        end.not_to change(User, :count)

        user = existing_user.reload
        expect(user.name).to eq auth.info.name
        expect(user.access_token).to eq "a87dsgf87aghs"
        expect(user.uid).to eq(auth.uid.to_s)
      end
    end

    context "with an existing user with the same email but different capitalization" do
      let(:email) { "tTomato@itsafruit.orange" }
      let!(:existing_user) { create :user, email: email.downcase }

      it "reuses the same user" do
        expect do
          result = described_class.from_zendesk_oauth(auth)
          expect(result).to eq existing_user
        end.not_to change(User, :count)
      end
    end

    context "with an existing user with same info but different email" do
      let(:old_email) { "ttimato@itsafruit.plum" }
      let!(:existing_user) { create :user, email: old_email, uid: auth.uid, provider: "zendesk" }
      # we are including this test to document that we *only* match on email
      # and have deviated from the standard use of uid and providers as our unique oauth identifiers
      it "creates a new user with the same uid and provider" do
        expect do
          result = described_class.from_zendesk_oauth(auth)
          expect(result).to be_a User
        end.to change(User, :count).by(1)

        user = User.last
        expect(existing_user.reload).not_to eq user
        expect(user.email).not_to eq existing_user.email
        expect(user.uid).to eq(existing_user.uid)
        expect(user.provider).to eq(existing_user.provider)
      end
    end

    context "without an existing user" do
      it "creates a user with all the fields" do
        expect do
          result = described_class.from_zendesk_oauth(auth)
          expect(result).to be_a User
        end.to change(User, :count).by(1)

        user = User.last
        expect(user.access_token).to eq "a87dsgf87aghs"
        expect(user.uid).to eq "89178938838417938"
        expect(user.provider).to eq "zendesk"
        expect(user.name).to eq "Tom Tomato"
        expect(user.email).to eq email
        expect(user.role).to eq "admin"
        expect(user.ticket_restriction).to eq nil
        expect(user.two_factor_auth_enabled).to eq true
        expect(user.active).to eq true
        expect(user.suspended).to eq false
        expect(user.verified).to eq true
        # it creates a default random password that the user will have to reset
        expect(user.encrypted_password).to be_present
      end
    end
  end

  describe "#valid?" do
    it "required fields" do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors).to include :name
      expect(user.errors).to include :password
      expect(user.errors).to include :email
    end

    it "validates timezone" do
      user = User.new(name: "Gary Guava", email: "example@example.com", password: "examplePassword", timezone: "Invalid timezone")
      expect(user).not_to be_valid
      expect(user.errors).to include :timezone
      user.timezone = "America/New_York"
      expect(user).to be_valid
    end
  end
end
