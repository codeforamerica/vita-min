require 'rails_helper'

describe PartnerRoutingService do
  subject { PartnerRoutingService.new }

  let(:vita_partner) { create :vita_partner }

  let(:code) { "SourceParam" }

  before do
    create :source_parameter, code: code, vita_partner: vita_partner
    create :vita_partner_zip_code, zip_code: "94606", vita_partner: vita_partner
    create :vita_partner_state, state: "CA", vita_partner: vita_partner
    5.times { create :vita_partner, national_overflow_location: true }
  end

  describe "#determine_partner" do
    context "fallback logic" do
      it "routes to an overflow partner" do
        expect(subject.determine_partner.national_overflow_location).to eq true
      end
    end

    context "when source param is provided" do
      context "when a source param is valid" do
        subject { PartnerRoutingService.new(source_param: code) }

        it "returns the referring partner" do
          expect(subject.determine_partner).to eq vita_partner
          expect(subject.routing_method).to eq :source_param
        end
      end

      context "when source param has different casing" do
        subject { PartnerRoutingService.new(source_param: code.upcase) }

        it "returns the referring partner" do
          expect(subject.determine_partner).to eq vita_partner
          expect(subject.routing_method).to eq :source_param
        end
      end

      context "when source param is not valid" do
        subject { PartnerRoutingService.new(source_param: "s0m3th1ng") }

        it "routes to an overflow partner location" do
          expect(subject.determine_partner.national_overflow_location).to eq true
        end
      end
    end

    context "when source param is not provided" do
      context "when clients zip code corresponds to a Vita Partner" do
        subject { PartnerRoutingService.new(zip_code: "94606") }

        it "returns the vita partner that has the associated vita partner zip code" do
          expect(subject.determine_partner).to eq vita_partner
          expect(subject.routing_method).to eq :zip_code
        end
      end

      context "when clients zip code doesn't correspond to a Vita Partner" do
        context "when state for that zip code has associated Vita Partners" do
          let!(:vp_state_nc_1) { create :vita_partner_state, state: "NC", vita_partner: create(:vita_partner), routing_fraction: 0.4 }
          let!(:vp_state_nc_2) { create :vita_partner_state, state: "NC", vita_partner: create(:vita_partner), routing_fraction: 0.5 }
          let!(:vp_to_route_to) { create :vita_partner_state, state: "NC", vita_partner: create(:vita_partner), routing_fraction: 0.2 }
          let!(:vp_other_state) { create :vita_partner_state, state: "MD", vita_partner: create(:vita_partner), routing_fraction: 0.1 }
          let!(:client) { create :client, vita_partner: vp_state_nc_1.vita_partner }


          subject { PartnerRoutingService.new(zip_code: "28806") }

          it "routes a Vita Partner in that state and based on percentage" do
            allow(Random).to receive(:rand).and_return(0.1)
            expect(subject.determine_partner).to eq(vp_to_route_to.vita_partner)
          end
        end

        context "when there are no Vita Partners for the state the zip code is in" do
          subject { PartnerRoutingService.new(zip_code: "32703") }

          it "routes to a national overflow partner location" do
            expect(subject.determine_partner.national_overflow_location).to eq true
          end
        end
      end
    end
  end
end