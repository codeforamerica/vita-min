require "rails_helper"

describe RoleHelper do
  describe '#user_roles' do
    context "an admin" do
      let(:user) { create :admin_user }
      it 'returns the user roles' do
        expect(helper.user_roles(user)).to eq "Admin"
      end
    end

    context "as an org lead" do
      let(:user) { create :user }
      before do
        create :organization_lead_role, user: user
      end

      it 'shows they are an org lead' do
        expect(helper.user_roles(user)).to eq "Organization lead"
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
      let(:user) { create :user }
      let(:organization) { create :organization, name: "Orange Organization" }
      before do
        create :organization_lead_role, user: user, organization: organization
      end

      it "returns the name of the org that they are a lead for" do
        expect(helper.user_org(user)).to eq("Orange Organization")
      end
    end
  end
end
