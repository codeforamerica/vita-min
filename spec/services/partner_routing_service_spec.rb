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
          subject { PartnerRoutingService.new(zip_code: "28806") }

          let!(:expected_vita_partner) { create :vita_partner }

          it "routes a Vita Partner in that state and based on percentage" do
            allow(VitaPartnerState).to receive(:weighted_state_routing_ranges).with("NC").and_return(
              [
                { id: 1, low: 0.0, high: 0.2 },
                { id: expected_vita_partner.id, low: 0.2, high: 0.6 },
                { id: 3, low: 0.6, high: 1.0 }
              ]
            )
            allow(Random).to receive(:rand).and_return(0.5)

            expect(subject.determine_partner).to eq(expected_vita_partner)
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