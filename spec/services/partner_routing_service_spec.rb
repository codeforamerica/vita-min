require 'rails_helper'

describe PartnerRoutingService do
  subject { PartnerRoutingService.new }

  let(:vita_partner) { create :vita_partner }

  let(:code) { "SourceParam" }

  before do
    create :source_parameter, code: code, vita_partner: vita_partner
    create :vita_partner_zip_code, zip_code: "94606", vita_partner: vita_partner
    5.times { create :vita_partner, national_overflow_location: true }
  end

  describe "#determine_partner" do
    context "fallback logic" do
      it "routes to an overflow partner" do
        expect(subject.determine_partner.national_overflow_location).to eq true
      end
    end

    context "when a source param is provided and valid" do
      subject { PartnerRoutingService.new(source_param: code) }

      it "returns the referring partner" do
        expect(subject.determine_partner).to eq vita_partner
        expect(subject.routing_method).to eq :source_param
      end
    end

    context "when a source param is provided with different casing" do
      subject { PartnerRoutingService.new(source_param: code.upcase ) }

      it "returns the referring partner" do
        expect(subject.determine_partner).to eq vita_partner
        expect(subject.routing_method).to eq :source_param
      end
    end

    context "when a source param is provided and not valid" do
      subject { PartnerRoutingService.new(source_param: "s0m3th1ng") }

      it "routes to an overflow partner location" do
        expect(subject.determine_partner.national_overflow_location).to eq true
      end
    end

    context "when clients zip code corresponds to a Vita Partner" do
      subject { PartnerRoutingService.new(zip_code: "94606") }

      it "returns the vita partner that has the associated vita partner zip code" do
        expect(subject.determine_partner).to eq vita_partner
        expect(subject.routing_method).to eq :zip_code
      end
    end

    context "when clients zip code doesn't correspond to a Vita Partner" do
      subject { PartnerRoutingService.new(zip_code: "94117") }

      it "routes to a national overflow partner location" do
        expect(subject.determine_partner.national_overflow_location).to eq true
      end
    end
  end
end