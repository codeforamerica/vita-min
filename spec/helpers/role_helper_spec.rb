require "rails_helper"

describe RoleHelper do
  describe "#user_role" do
    context "an admin" do
      let(:user) { create :admin_user }
      it "returns the user role" do
        expect(helper.user_role(user)).to eq "Admin"
      end
    end

    context "a client success user" do
      let(:user) { create :client_success_user }
      it "returns the user role" do
        expect(helper.user_role(user)).to eq "Client Success"
      end
    end

    context "as an org lead" do
      let(:user) { create :user, role: create(:organization_lead_role) }

      it "shows they are an org lead" do
        expect(helper.user_role(user)).to eq "Organization Lead"
      end
    end

    context "as a team member" do
      let(:user) { create :user, role: create(:team_member_role) }

      it "shows their role" do
        expect(helper.user_role(user)).to eq "Team Member"
      end
    end

    context "as a coalition lead" do
      let(:user) { create :user, role: create(:coalition_lead_role) }

      it "shows they are a coalition lead" do
        expect(helper.user_role(user)).to eq "Coalition Lead"
      end
    end

    context "as a site coordinator" do
      let(:user) { create :user, role: create(:site_coordinator_role) }

      it "shows they are a site coordinator" do
        expect(helper.user_role(user)).to eq "Site Coordinator"
      end
    end

    context "as a greeter" do
      let(:user) { create :user, role: create(:greeter_role) }

      it "shows the role name" do
        expect(helper.user_role(user)).to eq "Greeter"
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

    context "for a coalition lead user" do
      let(:coalition) { create :coalition, name: "Candy coalition" }
      let(:user) { create :coalition_lead_user, coalition: coalition }

      it "returns the name of the coalition that they are a lead for" do
        expect(helper.user_group(user)).to eq("Candy coalition")
      end
    end

    context "for a site coordinator user" do
      let(:site) { create :site, name: "Soda Site" }
      let(:user) { create :site_coordinator_user, site: site }

      it "returns the name of the site that they are a coordinator for" do
        expect(helper.user_group(user)).to eq("Soda Site")
      end
    end

    context "for a team member user" do
      let(:user) { create :team_member_user, site: create(:site, name: "Soda Site") }

      it "returns the name of their group" do
        expect(helper.user_group(user)).to eq("Soda Site")
      end
    end
  end
end
