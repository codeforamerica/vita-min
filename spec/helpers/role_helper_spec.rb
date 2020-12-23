require "rails_helper"

describe RoleHelper do
  describe '#user_role' do
    context "an admin" do
      let(:user) { create :admin_user }
      it 'returns the user roles' do
        expect(helper.user_role(user)).to eq "Admin"
      end
    end

    context "as an org lead" do
      let(:user) { create :user, role: create(:organization_lead_role) }

      it 'shows they are an org lead' do
        expect(helper.user_role(user)).to eq "Organization lead"
      end
    end
  end

  describe "#user_org" do
    context "for a user in no org" do
      let(:user) { create :user }

      it "returns a blank value" do
        expect(helper.user_org(user)).to be_blank
      end
    end

    context "for an org lead user" do
      let(:organization) { create :organization, name: "Orange Organization" }
      let(:user) { create :organization_lead_user, organization: organization }

      it "returns the name of the org that they are a lead for" do
        expect(helper.user_org(user)).to eq("Orange Organization")
      end
    end
  end
end
