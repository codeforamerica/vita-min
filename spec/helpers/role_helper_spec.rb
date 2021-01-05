require "rails_helper"

describe RoleHelper do
  describe "#user_role" do
    context "an admin" do
      let(:user) { create :admin_user }
      it "returns the user roles" do
        expect(helper.user_role(user)).to eq "Admin"
      end
    end

    context "as an org lead" do
      let(:user) { create :user, role: create(:organization_lead_role) }

      it "shows they are an org lead" do
        expect(helper.user_role(user)).to eq "Organization lead"
      end
    end

    context "as a coalition lead" do
      let(:user) { create :user, role: create(:coalition_lead_role) }

      it "shows they are a coalition lead" do
        expect(helper.user_role(user)).to eq "Coalition lead"
      end
    end
  end

  describe "#user_group" do
    context "for a user in no group" do
      let(:user) { create :user }

      it "returns a blank value" do
        expect(helper.user_group(user)).to be_blank
      end
    end

    context "for an org lead user" do
      let(:organization) { create :organization, name: "Orange Organization" }
      let(:user) { create :organization_lead_user, organization: organization }

      it "returns the name of the org that they are a lead for" do
        expect(helper.user_group(user)).to eq("Orange Organization")
      end
    end

    context "for a coalition lead" do
      let(:coalition) { create :coalition, name: "Candy coalition" }
      let(:user) { create :coalition_lead_user, coalition: coalition }

      it "returns the name of the coalition that they are a lead for" do
        expect(helper.user_group(user)).to eq("Candy coalition")
      end
    end
  end
end
