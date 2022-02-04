require 'rails_helper'

describe PartnerRoutingService do
  subject { PartnerRoutingService.new }

  let(:vita_partner) { create :organization }

  let(:code) { "SourceParam" }

  before do
    create :source_parameter, code: code, vita_partner: vita_partner
    create :vita_partner_zip_code, zip_code: "94606", vita_partner: vita_partner
  end

  describe "#determine_partner" do
    context "fallback logic" do
      it "returns nil" do
        expect(subject.determine_partner).to be_nil
      end
    end

    context "when a client is returning and it has a vita partner" do
      let!(:this_year_intake) { create :intake, primary_birth_date: Date.new(1960, 5, 12), primary_last_four_ssn: 1122, primary_first_name: "Sean", primary_last_name: "Strawberry", client: (create :client) }
      let!(:last_year_intake) { create :archived_2021_gyr_intake, primary_birth_date: Date.new(1960, 5, 12), primary_last_four_ssn: 1122, primary_first_name: "Sean", primary_last_name: "Strawberry", client: (create :client, vita_partner: vita_partner) }
      subject { PartnerRoutingService.new(intake: this_year_intake) }

      before do
        allow_any_instance_of(VitaPartner).to receive(:active?).and_return true
      end

      it "returns last years partner" do
        expect(subject.determine_partner).to eq vita_partner
        expect(subject.routing_method).to eq :returning_client
      end
    end

    context "when client uses the special at-capacity testing ZIP code" do
      subject { PartnerRoutingService.new(zip_code: "94606") }

      before do
        stub_const("PartnerRoutingService::TESTING_AT_CAPACITY_ZIP_CODE", "94606")
      end

      context "on demo" do
        before do
          allow(Rails).to receive(:env).and_return("demo".inquiry)
        end

        it "returns at capacity" do
          expect(subject.determine_partner).to eq nil
          expect(subject.routing_method).to eq :at_capacity
        end
      end

      context "on production" do
        before do
          allow(Rails).to receive(:env).and_return("production".inquiry)
        end

        it "returns the VitaPartner with that ZIP code" do
          expect(subject.determine_partner).to eq vita_partner
          expect(subject.routing_method).to eq :zip_code
        end
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

        it "returns nil" do
          expect(subject.determine_partner).to be_nil
          expect(subject.routing_method).to eq :at_capacity
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

        context "when a Vita Partner matches the zip code but they do not have capacity" do
          before do
            vita_partner.update(capacity_limit: 0)
          end

          it "returns nil" do
            expect(subject.determine_partner).to be_nil
            expect(subject.routing_method).to eq :at_capacity
          end
        end
      end

      context "when clients zip code doesn't correspond to a Vita Partner" do
        context "when state for that zip code has associated Vita Partners" do
          subject { PartnerRoutingService.new(zip_code: "28806") } #NC

          context "and some VitaPartners have capacity" do
            let!(:expected_vita_partner) { create :organization, capacity_limit: 2, coalition: create(:coalition) }
            let!(:nc_org_with_capacity_state_routing_fraction) {
              srt = create(:state_routing_target, target: expected_vita_partner.coalition, state_abbreviation: "NC")
              create(:state_routing_fraction, state_routing_target: srt, routing_fraction: 0.0, vita_partner: expected_vita_partner)
            }
            let!(:nc_org_with_capacity_2_state_routing_fraction) {
              vita_partner = create(:organization, capacity_limit: 1, coalition: create(:coalition))
              srt = create(:state_routing_target, target: vita_partner.coalition, state_abbreviation: "NC")
              create(:state_routing_fraction, state_routing_target: srt, routing_fraction: 0.2, vita_partner: vita_partner)
            }
            let!(:nc_site_with_capacity_state_routing_fraction) {
              vita_partner = create(:site, parent_organization: nc_org_with_capacity_state_routing_fraction.vita_partner)
              srt = nc_org_with_capacity_state_routing_fraction.state_routing_target
              create(:state_routing_fraction, state_routing_target: srt, routing_fraction: 0.3, vita_partner: vita_partner)
            }
            let!(:nc_org_no_capacity_state_routing_fraction) {
              vita_partner = create(:organization, capacity_limit: 0)
              srt = create(:state_routing_target, target: vita_partner, state_abbreviation: "NC")
              create(:state_routing_fraction, state_routing_target: srt, routing_fraction: 0.5, vita_partner: vita_partner)
            }
            let!(:nc_site_no_capacity_state_routing_fraction) {
              parent_org_no_capacity = create(:organization, capacity_limit: 0, coalition: create(:coalition))
              vita_partner = create(:site, parent_organization: parent_org_no_capacity)
              srt = create(:state_routing_target, target: parent_org_no_capacity.coalition, state_abbreviation: "NC")
              create(:state_routing_fraction, state_routing_target: srt, routing_fraction: 0.1, vita_partner: vita_partner)
            }
            let!(:ca_org_with_capacity_state_routing_fraction) {
              vita_partner = create(:organization, capacity_limit: 1)
              srt = create(:state_routing_target, target: vita_partner, state_abbreviation: "CA")
              create(:state_routing_fraction, state_routing_target: srt, routing_fraction: 0.5, vita_partner: vita_partner)
            }
            let(:weighted_routing_service_double) { instance_double(WeightedRoutingService) }

            before do
              allow(WeightedRoutingService).to receive(:new).and_return(weighted_routing_service_double)
              allow(weighted_routing_service_double).to receive(:weighted_routing_ranges)
                .and_return(
                  [
                    { id: 1, low: 0.0, high: 0.2 },
                    { id: expected_vita_partner.id, low: 0.2, high: 0.6 },
                    { id: 3, low: 0.6, high: 1.0 }
                  ]
                )
              allow(Random).to receive(:rand).and_return(0.5)
            end

            it "routes a Vita Partner in that state based on percentage" do
              expect(subject.determine_partner).to eq(expected_vita_partner)
              expect(WeightedRoutingService).to have_received(:new).with(
                match_array(
                  [
                    nc_org_with_capacity_state_routing_fraction,
                    nc_org_with_capacity_2_state_routing_fraction,
                    nc_site_with_capacity_state_routing_fraction
                  ]
                )
              )
            end
          end

          context "but no VitaPartners have capacity" do
            let!(:org_state_routed_no_capacity) {
              vita_partner = create(:organization, capacity_limit: 0, coalition: create(:coalition))
              srt = create(:state_routing_target, target: vita_partner.coalition, state_abbreviation: "NC")
              create(:state_routing_fraction, state_routing_target: srt, routing_fraction: 0.3, vita_partner: vita_partner)
              vita_partner
            }
            let!(:org_state_routed_no_excess_capacity) {
              vita_partner = create(:organization, capacity_limit: 5)
              srt = create(:state_routing_target, target: vita_partner, state_abbreviation: "NC")
              create(:state_routing_fraction, state_routing_target: srt, routing_fraction: 0.4, vita_partner: vita_partner)
              (vita_partner.capacity_limit + 1).times do
                create :client_with_tax_return_state, vita_partner: vita_partner, state: "intake_ready", intake: create(:intake)
              end
            }

            it "returns nil" do
              expect(subject.determine_partner).to be_nil
              expect(subject.routing_method).to eq :at_capacity
            end
          end
        end

        context "when there are no Vita Partners for the state the zip code is in" do
          subject { PartnerRoutingService.new(zip_code: "32703") }

          it "returns nil" do
            expect(subject.determine_partner).to be_nil
            expect(subject.routing_method).to eq :at_capacity
          end
        end
      end
    end

    context "when there are no matches on other data or routing rules" do
      context "when national overflow partners exist" do
        let!(:overflow_partner) { create :organization, national_overflow_location: true }

        it "routes to a national overflow partner" do
          subject { PartnerRoutingService.new(zip_code: "11111") }
          expect(subject.determine_partner).to eq overflow_partner
          expect(subject.routing_method).to eq :national_overflow
        end
      end
    end
  end
end
