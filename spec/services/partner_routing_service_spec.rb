require 'rails_helper'

describe PartnerRoutingService do
  let(:vita_partner_for_source_param) { create :vita_partner }
  let(:vita_partner_for_zip_code) { create :vita_partner }
  let(:vita_partner_for_state) { create :vita_partner }
  let(:default_vita_partner) { create :vita_partner } # default_vita_partner is temporary and goes away with fallback_organization
  let(:code) { "SourceParam" }
  subject { PartnerRoutingService.new }
  before do
    create :source_parameter, code: code, vita_partner: vita_partner_for_source_param
    create :vita_partner_zip_code, zip_code: "94606", vita_partner: vita_partner_for_zip_code
    create :vita_partner_state, state: "CA", vita_partner: vita_partner_for_state
    allow(subject).to receive(:fallback_organization).and_return default_vita_partner
  end

  describe "#determine_organization" do
    context "initialized without custom client data" do
      it "still returns a vita partner" do
        expect(subject.determine_organization).to eq default_vita_partner
      end
    end

    context "routing by source param" do
      context "when a source param is provided and valid" do
        subject { PartnerRoutingService.new(source_param: code) }

        it "returns the referring organization" do
          expect(subject.determine_organization).to eq vita_partner_for_source_param
          expect(subject.routing_method).to eq :source_param
        end
      end

      context "when a source param is provided and not valid" do
        subject { PartnerRoutingService.new(source_param: "s0m3th1ng") }

        it "returns the default organization" do
          expect(subject.determine_organization).to eq default_vita_partner
        end
      end
    end

    context "routing by zip code" do
      context "when clients zip code corresponds to a Vita Partner" do
        subject { PartnerRoutingService.new(zip_code: "94606") }

        it "returns the vita partner that has the associated vita partner zip code" do
          expect(subject.determine_organization).to eq vita_partner_for_zip_code
          expect(subject.routing_method).to eq :zip_code
        end
      end

      context "when clients zip code doesn't correspond to a Vita Partner" do
        subject { PartnerRoutingService.new(zip_code: "94117") }

        it "returns the default organization" do
          expect(subject.determine_organization).to eq default_vita_partner
        end
      end
    end

    context "routing by state" do
      context "when client state corresponds to a Vita Partner" do
        subject { PartnerRoutingService.new(state: "CA") }

        it "returns the vita partner with the associated state" do
          expect(subject.determine_organization).to eq vita_partner_for_state
          expect(subject.routing_method).to eq :state
        end
      end
    end
  end
end