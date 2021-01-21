require 'rails_helper'

describe PartnerRoutingService do
  let(:vita_partner) { create :vita_partner }
  let(:code) { "SourceParam" }
  before do
    create :source_parameter, code: code, vita_partner: vita_partner
    create :organization_lead_role, organization: create(:vita_partner)
    create :vita_partner_zip_code, zip_code: "94606", vita_partner: vita_partner
  end

  describe '#determine_organization' do
    subject { PartnerRoutingService.new }

    context "initialized without custom client data" do
      it 'still returns a vita partner' do
        expect(subject.determine_organization).to be_an_instance_of VitaPartner
        expect(subject.routing_method).to eq :most_org_leads
      end
    end

    context "when a source param is provided" do
      subject { PartnerRoutingService.new(source_param: code) }

      it "returns the referring organization" do
        expect(subject.determine_organization).to eq vita_partner
        expect(subject.routing_method).to eq :source_param
      end
    end

    context "when a zip code is provided but a source param is not" do
      subject { PartnerRoutingService.new(zip_code: "94606") }

      it "returns the vita partner that has the associated vita partner zip code" do
        expect(subject.determine_organization).to eq vita_partner
        expect(subject.routing_method).to eq :zip_code
      end
    end
  end
end