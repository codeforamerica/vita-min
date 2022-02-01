require "rails_helper"

RSpec.describe ClientSortable, type: :controller do
  # this is a concern spec, so it only needs some portions of a controller
  # - it needs current_user for one particular method
  # - it needs params
  # - it assumes that @clients is already set.
  let(:clients_query_double) { double }
  let(:intakes_query_double) { double }
  let(:cookies) { double }
  controller(ApplicationController) do
    include ClientSortable

    private

    def filter_cookie_name
      "some_filter_cookie_name"
    end
  end

  before do
    allow(controller).to receive(:cookies).and_return(cookies)
    allow(cookies).to receive(:delete)
    allow(cookies).to receive(:[]=)
    allow(cookies).to receive(:[])

    allow(subject).to receive(:params).and_return params
    subject.instance_variable_set(:@clients, clients_query_double)
    allow(clients_query_double).to receive(:after_consent).and_return clients_query_double
    allow(Client).to receive(:joins).and_return Client
    allow(clients_query_double).to receive(:joins).and_return clients_query_double
    allow(clients_query_double).to receive(:greetable).and_return clients_query_double
    allow(clients_query_double).to receive(:sla_breach_date).and_return clients_query_double
    allow(clients_query_double).to receive(:delegated_order).and_return clients_query_double
    allow(clients_query_double).to receive(:where).and_return clients_query_double
    allow(clients_query_double).to receive(:not).and_return clients_query_double
    allow(clients_query_double).to receive(:first_unanswered_incoming_interaction_communication_breaches).and_return clients_query_double
    allow(Intake).to receive(:search).and_return intakes_query_double
  end

  describe "#filtered_and_sorted_clients" do
    context "when user is a greeter" do
      let(:params) do
        {}
      end
      let(:user_double) { double(User) }
      before do
        allow(subject).to receive(:current_user).and_return(user_double)
        allow(user_double).to receive(:to_i)
        allow(user_double).to receive(:greeter?).and_return(true)
      end

      context "there are greetable clients" do
        it "limits to greetable clients only" do
          expect(subject.filtered_and_sorted_clients).to eq clients_query_double

          expect(clients_query_double).to have_received(:greetable)
        end
      end

      context "there are not greetable clients" do
        before do
          allow(clients_query_double).to receive(:greetable).and_return nil
        end

        it "limits to intake statuses only" do
          subject.filtered_and_sorted_clients

          expect(Client).to have_received(:joins).with(:tax_returns)
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
        expect(clients_query_double).to have_received(:where).with({ tax_returns: { state: params[:status] } })
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

    context "with a provided language" do
      let(:params) {
        {
          language: "de"
        }
      }

      it "creates a query for the search and scopes to vita partner" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with('intakes.locale = :language OR intakes.preferred_interview_language = :language', language: "de")
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
          expect(clients_query_double).to have_received(:where).with({ tax_returns: { service_type: "online_intake" } })
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
          expect(clients_query_double).to have_received(:where).with({ tax_returns: { service_type: "drop_off" } })
        end
      end
    end

    context "with a selected assigned user id" do
      let(:user) { create :user }
      let(:params) {
        {
          assigned_user_id: user.id
        }
      }

      it "creates a query that includes the call to limit to assigned user" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with({ tax_returns: { assigned_user: [user.id] } })
      end
    end

    context "with a selected assigned user id AND assigned to me selected" do
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

      it "creates a query that includes a call to limit to assigned to current user AND some other user" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with({ tax_returns: { assigned_user: [current_user.id, user.id] } })
      end
    end

    context "with a clear param" do
      let(:params) do
        {
          clear: true,
          assigned_user_id: 1
        }
      end

      before do
        allow(cookies).to receive(:delete)
        allow(cookies).to receive(:[]).with(anything)
      end

      it "removes the filter cookie" do
        subject.filtered_and_sorted_clients
        expect(cookies).to have_received(:delete).with("some_filter_cookie_name")
      end
    end

    context "with a sla breach date param" do
      let(:params) do
        {
          sla_breach_date: DateTime.new(2021, 5, 18, 11, 32)
        }
      end

      it "creates a query that includes clients that are in breach of the sla date" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:first_unanswered_incoming_interaction_communication_breaches).with(params[:sla_breach_date])
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
