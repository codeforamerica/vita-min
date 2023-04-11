require "rails_helper"

RSpec.describe ClientSorter do
  let(:clients_query_double) { double }
  let(:intakes_query_double) { double }
  let(:user_role) { build :team_member_role, site: build(:site) }
  let(:user) { create :user, role: user_role }
  let(:subject) { described_class.new(clients_query_double, user, params, {}) }

  before do
    allow(subject).to receive(:current_user).and_return(user)
    allow(Client).to receive(:joins).and_return Client
    allow(clients_query_double).to receive(:after_consent).and_return clients_query_double
    allow(clients_query_double).to receive(:distinct).and_return clients_query_double
    allow(clients_query_double).to receive(:joins).and_return clients_query_double
    allow(clients_query_double).to receive(:or).and_return clients_query_double
    allow(clients_query_double).to receive(:greetable).and_return clients_query_double
    allow(clients_query_double).to receive(:delegated_order).and_return clients_query_double
    allow(clients_query_double).to receive(:where).and_return clients_query_double
    allow(clients_query_double).to receive(:not).and_return clients_query_double
    allow(Intake).to receive(:search).and_return intakes_query_double
  end

  describe "#filtered_and_sorted_clients" do
    context "when user is a greeter" do
      let(:subject) { described_class.new(Client, user, params, {}) }
      let!(:assigned_tax_return) { create :gyr_tax_return, :prep_ready_for_prep, assigned_user: user }
      let(:user_role) { build(:greeter_role) }
      let(:params) do
        {}
      end

      context "there are greetable clients" do
        let!(:greetable_tax_return) { create :gyr_tax_return, :intake_ready }

        it "limits to greetable clients and assigned clients" do
          result = subject.filtered_and_sorted_clients.to_a
          expect(result).to match_array([assigned_tax_return.client, greetable_tax_return.client])
        end
      end

      context "there are not greetable clients" do
        it "limits to assigned clients only" do
          result = subject.filtered_and_sorted_clients.to_a
          expect(result).to match_array([assigned_tax_return.client])
        end
      end
    end

    context "default sort order" do
      let(:params) { {} }

      it "sorts clients by last_outgoing_communication_at" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:delegated_order).with("last_outgoing_communication_at", "asc")
      end
    end

    context "with a 'search' param" do
      let(:params) do
        { search: "que" }
      end

      it "creates a search query for intakes and queries clients for those intakes" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(Intake).to have_received(:search).with "que"
        expect(clients_query_double).to have_received(:where).with(intake: intakes_query_double)
      end
    end

    context "with a 'search' param and additional filters" do
      let(:params) do
        {
          search: "query",
          status: "intake_ready"
        }
      end

      it "creates a query for the search and scopes by other provided queries" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with("filterable_tax_return_properties @> ?::jsonb", [{ current_state: params[:status] }].to_json)
        expect(clients_query_double).to have_received(:where).with(intake: intakes_query_double)
      end
    end

    context "with a vita partner" do
      let(:vita_partner) { create :organization }
      let(:params) do
        {
          vita_partners: [{ id: vita_partner.id, name: vita_partner.name, value: vita_partner.id }].to_json
        }
      end

      it "creates a query for the search and scopes to vita partner" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with(vita_partner_id: [vita_partner.id])
      end

      context "more than one vita partner is selected" do
        let!(:site) { create :site, parent_organization: vita_partner }
        let(:params) do
          { vita_partners: [{ id: vita_partner.id, name: vita_partner.name, value: vita_partner.id }, { id: site.id, name: site.name, value: site.id }].to_json }
        end

        it "creates a query for the search and scopes to all selected vita partners" do
          expect(subject.filtered_and_sorted_clients).to eq clients_query_double
          expect(clients_query_double).to have_received(:where).with(vita_partner_id: [vita_partner.id, site.id])
        end
      end
    end

    context "with service type selected" do
      context "online_intake" do
        let(:params) {
          {
            service_type: "online_intake"
          }
        }

        it "creates a query for the search and scopes to vita partner" do
          expect(subject.filtered_and_sorted_clients).to eq clients_query_double
          expect(clients_query_double).to have_received(:where).with("filterable_tax_return_properties @> ?::jsonb", [{ service_type: "online_intake" }].to_json)
        end
      end

      context "drop_off" do
        let(:params) {
          {
            service_type: "drop_off"
          }
        }
        it "creates a query for the search and scopes to vita partner" do
          expect(subject.filtered_and_sorted_clients).to eq clients_query_double
          expect(clients_query_double).to have_received(:where).with("filterable_tax_return_properties @> ?::jsonb", [{ service_type: "drop_off" }].to_json)
        end
      end
    end

    context "with a selected assigned user id" do
      let(:subject) { described_class.new(Client, user, params, {}) }
      let!(:assigned_tax_return) { create :gyr_tax_return, :intake_ready, assigned_user_id: user.id }
      let!(:unassigned_tax_return) { create :gyr_tax_return, :intake_ready }
      let(:user) { create :user }
      let(:params) {
        {
          assigned_user_id: user.id
        }
      }

      it "returns clients with tax returns assigned to the selected user" do
        expect(subject.filtered_and_sorted_clients.to_a).to match_array([assigned_tax_return.client])
      end
    end

    context "with a language" do
      let(:subject) { described_class.new(Client, user, params, {}) }
      let!(:spanish_intake) { create(:gyr_tax_return, :intake_ready).intake.tap { |i| i.update(locale: :es) } }
      let!(:german_intake) { create(:gyr_tax_return, :intake_ready).intake.tap { |i| i.update(locale: :de) } }
      let(:user) { create :user }
      let(:params) {
        {
          language: "de"
        }
      }

      it "returns clients where the intake's language matches the provided language" do
        expect(subject.filtered_and_sorted_clients.to_a).to match_array([german_intake.client])
      end
    end

    context "with a selected assigned user id AND assigned to me selected" do
      let(:subject) { described_class.new(Client, user, params, {}) }
      let!(:assigned_tax_return) { create :gyr_tax_return, :intake_ready, assigned_user_id: user.id }
      let!(:unassigned_tax_return) { create :gyr_tax_return, :intake_ready }
      let!(:assigned_to_me_tax_return) { create :gyr_tax_return, :intake_ready, assigned_user_id: current_user.id }
      let(:user) { create :user }
      let(:current_user) { create :user }
      let(:params) {
        {
          assigned_user_id: user.id,
          assigned_to_me: true
        }
      }
      before do
        allow(subject).to receive(:current_user).and_return(current_user)
      end

      it "returns clients with tax returns assigned to the selected user AND the current user" do
        expect(subject.filtered_and_sorted_clients.to_a).to match_array([assigned_to_me_tax_return.client, assigned_tax_return.client])
      end
    end

    context "searching for phone numbers" do
      before { subject.filtered_and_sorted_clients }

      context "with a simple phone number digit-only search" do
        let(:params) { { search: "4155551212" } }

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "+14155551212"
        end
      end

      context "with a phone number in a common local format" do
        let(:params) { { search: "(415) 555-1212" } }

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "+14155551212"
        end
      end

      context "with a phone number in an unofficial but commonly entered format" do
        let(:params) { { search: "415.555.1212" } }

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "+14155551212"
        end
      end

      context "with the last seven digits of a phone number" do
        let(:params) { { search: "555-1212" } }

        it "passes the number to search with no normalization" do
          expect(Intake).to have_received(:search).with "555-1212"
        end
      end

      context "with a phone number and another field in the search query" do
        let(:params) do
          { search: "colleen 415555(1212)" }
        end

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "colleen +14155551212"
        end
      end

      context "with a phone number in e.164 international format" do
        let(:params) do
          { search: "colleen +14155551212" }
        end

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "colleen +14155551212"
        end
      end
    end
  end

  describe "#has_search_and_sort_params?" do
    context "when containing a sort or search param" do
      context "search" do
        let(:params) { { search: "que" } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "status" do
        let(:params) { { search: "prep_ready_for_prep" } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "unassigned" do
        let(:params) { { unassigned: true } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "assigned_to_me" do
        let(:params) { { assigned_to_me: true } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "flagged_at" do
        let(:params) { { flagged: true } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "year" do
        let(:params) { { year: 2019 } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "vita_partners" do
        let(:params) { { vita_partners: [{ id: 1, name: "Partner name", value: 1 }].to_json } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end
    end

    context "without a search or sort param" do
      let(:params) { { something: 'hello' } }
      it "returns false" do
        expect(subject.has_search_and_sort_params?).to eq false
      end
    end
  end
end
