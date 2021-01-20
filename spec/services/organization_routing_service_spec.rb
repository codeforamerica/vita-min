require 'rails_helper'

describe OrganizationRoutingService do
  let(:vita_partner) { create :vita_partner }
  before do
    create :organization_lead_role, organization: create(:vita_partner)
  end

  describe '#determine_organization' do
    subject { OrganizationRoutingService.new }

    context "initialized without custom client data" do
      it 'still returns a vita partner' do
        expect(subject.determine_organization).to be_an_instance_of VitaPartner
        expect(subject.routing_method).to eq :most_org_leads
      end
    end

    context "when a referring organization id is provided" do
      subject { OrganizationRoutingService.new(referring_organization_id: vita_partner.id) }

      it "returns the referring organization" do
        expect(subject.determine_organization).to eq vita_partner
        expect(subject.routing_method).to eq :direct
      end
    end

    xcontext "routing by zip code" do
      subject { OrganizationRoutingService.new(zip_code: "94606") }
    end
  end
end