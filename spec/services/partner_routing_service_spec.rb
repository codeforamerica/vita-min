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
          subject { PartnerRoutingService.new(zip_code: "28806") } #NC

          let!(:expected_vita_partner) { create :vita_partner }

          xcontext "with state-qualified organizations with excess capacity" do
            let!(:org_with_capacity_and_routing_1) {
              vita_partner = create(:vita_partner, capacity_limit: 10)
              create(:vita_partner_state, state: "NC", routing_fraction: 0.3, vita_partner: vita_partner)
              vita_partner
            }
            let!(:org_with_capacity_and_routing_2) {
              vita_partner = create(:vita_partner, capacity_limit: 10)
              create(:vita_partner_state, state: "NC", routing_fraction: 0.3, vita_partner: vita_partner)
              vita_partner
            }
            let!(:org_with_routing_without_capacity) {
              vita_partner = create(:vita_partner, capacity_limit: 0)
              create(:vita_partner_state, state: "NC", routing_fraction: 0.3, vita_partner: vita_partner)
              vita_partner
            }
            let!(:org_with_routing_without_excess_capacity) {
              vita_partner = create(:vita_partner, capacity_limit: 5)
              create(:vita_partner_state, state: "NC", routing_fraction: 0.3, vita_partner: vita_partner)
              (vita_partner.capacity_limit + 1).times do
                create :client_with_status, vita_partner: vita_partner, status: "intake_ready"
              end
            }
            before do
              weighted_service_double = double(WeightedRoutingService)
              allow(WeightedRoutingService).to receive(:new).and_return weighted_service_double
              allow(weighted_service_double).to receive(:weighted_routing_ranges).and_return(
                [
                  { id: 1, low: 0.0, high: 0.2 },
                  { id: org_with_capacity_and_routing_1.id, low: 0.2, high: 0.6 },
                  { id: 3, low: 0.6, high: 1.0 }
                ]
              )
            end

            it "only considers vita partners with capacity" do
              subject.determine_partner
              expect(WeightedRoutingService).to have_received(:new).with([org_with_capacity_and_routing_1, org_with_capacity_and_routing_2])
            end
          end

          xcontext "with state qualified vita partners, but none have capacity" do
            let!(:org_state_routed_no_capacity) {
              vita_partner = create(:vita_partner, capacity_limit: 0)
              create(:vita_partner_state, state: "NC", routing_fraction: 0.3, vita_partner: vita_partner)
              vita_partner
            }
            let!(:org_state_routed_no_excess_capacity) {
              vita_partner = create(:vita_partner, capacity_limit: 5)
              create(:vita_partner_state, state: "NC", routing_fraction: 0.3, vita_partner: vita_partner)
              (vita_partner.capacity_limit + 1).times do
                create :client_with_status, vita_partner: vita_partner, status: "intake_ready"
              end
            }
            
            it "assigns to a national vita partner" do
              expect(subject.determine_partner.national_overflow_location).to eq true
            end
          end

          context "with state qualified vita partners, but none have capacity" do
            let!(:org_state_routed_no_capacity) {
              vita_partner = create(:vita_partner, capacity_limit: 0)
              create(:vita_partner_state, state: "NC", routing_fraction: 1, vita_partner: vita_partner)
              vita_partner
            }
            let!(:org_state_routed_no_excess_capacity) {
              vita_partner = create(:vita_partner, capacity_limit: 5)
              create(:vita_partner_state, state: "NC", routing_fraction: 0, vita_partner: vita_partner)
              (vita_partner.capacity_limit + 1).times do
                create :client_with_status, vita_partner: vita_partner, status: "intake_ready"
              end
            }

            it "assigns to a state vita partner, regardless of capacity" do
              expect(subject.determine_partner.national_overflow_location).to eq false
              allow(Random).to receive(:rand).and_return(0.9)

              expect(subject.determine_partner).to eq(org_state_routed_no_capacity)
            end
          end

          it "routes a Vita Partner in that state and based on percentage" do
            allow_any_instance_of(WeightedRoutingService).to receive(:weighted_routing_ranges).and_return(
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