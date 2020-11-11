require "rails_helper"

describe VitaPartnerHelper do
  describe "#grouped_organization_options" do
    let(:parent_org1) { create(:vita_partner, name: "First Parent Org") }
    let(:parent_org2) { create(:vita_partner, name: "Second Parent Org") }
    let(:parent_org3) { create(:vita_partner, name: "No Child Org") }
    let(:sub_org1) { create(:vita_partner, parent_organization_id: parent_org1.id, name: "The First Child Org") }
    let(:sub_org2) { create(:vita_partner, parent_organization_id: parent_org1.id, name: "The Second Child Org") }
    let(:sub_org3) { create(:vita_partner, parent_organization_id: parent_org2.id, name: "The Third Child Org") }
    let!(:inaccessible_org) { create(:vita_partner, name: "User Cannot Access It") }

    let(:user) { create(:user, vita_partner: parent_org1, supported_organizations: [parent_org2, parent_org3]) }

    context "with a logged-in user" do
      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it "returns an array of VitaPartners, grouped by parent org, that this user can access" do
        expected =
          [
            ["First Parent Org", [["First Parent Org", parent_org1.id], ["The First Child Org", sub_org1.id], ["The Second Child Org",  sub_org2.id]]],
            ["Second Parent Org", [["Second Parent Org", parent_org2.id], ["The Third Child Org", sub_org3.id]]],
            ["No Child Org", [["No Child Org", parent_org3.id]]]
          ]

        expect(helper.grouped_organization_options).to eq(expected)
      end
    end
  end
end
