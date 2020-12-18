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
#  is_admin                  :boolean          default(FALSE), not null
#  is_client_support         :boolean
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

  describe "#accessible_organizations" do
    let!(:user) { create :user, supported_organizations: [greetable_org] }
    let!(:greetable_org) { create :vita_partner, name: "Greetable org" }
    let!(:organization) { create :organization, name: "Parent org" }
    let!(:site) { create :site, parent_organization: organization, name: "Child org" }
    let!(:not_accessible_partner) { create :vita_partner, name: "Not accessible" }

    before { create :organization_lead_role, user: user, organization: organization }

    it "should return a user's primary org, supportable orgs, and coalition members" do
      accessible_organization_ids = user.accessible_organizations.pluck(:id)
      expect(accessible_organization_ids).to include(organization.id)
      expect(accessible_organization_ids).to include(site.id)
      expect(accessible_organization_ids).to include(greetable_org.id)
      expect(accessible_organization_ids).not_to include(not_accessible_partner.id)
    end
  end

  describe "first_name" do
    context "Luke" do
      let(:user) { build :user, name: "Luke"}
      it "returns nil" do
        expect(user.first_name).to eq "Luke"
      end
    end

    context "Luke Skywalker" do
      let(:user) { build :user, name: "Luke Skywalker"}
      it "returns nil" do
        expect(user.first_name).to eq "Luke"
      end
    end

    context "without name" do
      let(:user) { build :user, name: nil}
      it "returns nil" do
        expect(user.first_name).to eq nil
      end
    end
  end
end
