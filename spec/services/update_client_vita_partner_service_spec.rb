require "rails_helper"

describe UpdateClientVitaPartnerService do
  describe ".update" do
    subject { UpdateClientVitaPartnerService.new(client: client, vita_partner_id: other_site.id, change_initiated_by: assigned_user).update! }

    let(:current_site) { create :site }
    let(:other_site) { create :site, parent_organization: current_site.parent_organization }
    let(:client) { create :client, vita_partner: current_site, tax_returns: [tax_return] }
    let(:tax_return) { create :tax_return, year: 2019, assigned_user: assigned_user }
    let(:assigned_user) { create :team_member_user, site: current_site }

    context "when an assigned user does not have access to the new vita partner" do

      it "changes the vita partner" do
        expect { subject }.to change(client, :vita_partner).from(current_site).to(other_site)
      end

      it "leaves a note" do
        expect { subject }.to change(SystemNote::OrganizationChange, :count).by(1)
        expect(SystemNote.last.user).to eq assigned_user
      end

      it "removes the assignee from the tax return" do
        subject
        expect(tax_return.reload.assigned_user).to eq(nil)
      end
    end

    context "when the assigned user does have access to the new vita partner" do
      let(:assigned_user) { create :organization_lead_user, organization: current_site.parent_organization }

      it "changes the vita partner" do
        expect { subject }.to change(client, :vita_partner).from(current_site).to(other_site)
      end

      it "leaves the assignee on the return" do
        subject
        expect(tax_return.reload.assigned_user).to eq(assigned_user)
      end
    end
  end
end