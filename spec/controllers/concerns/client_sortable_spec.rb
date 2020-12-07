require "rails_helper"

RSpec.describe ClientSortable, type: :controller do
  # this is a concern spec, so it only needs some portions of a controller
  # - it needs current_user for one particular method
  # - it needs params
  # - it assumes that @clients is already set.
  let(:clients_query_double){ double }
  let(:intakes_query_double){ double }

  controller(ApplicationController) do
    include ClientSortable
  end

  before do
    allow(subject).to receive(:params).and_return params
    subject.instance_variable_set(:@clients, clients_query_double)
    allow(clients_query_double).to receive(:after_consent).and_return clients_query_double
    allow(clients_query_double).to receive(:delegated_order).and_return clients_query_double
    allow(clients_query_double).to receive(:where).and_return clients_query_double
    allow(clients_query_double).to receive(:not).and_return clients_query_double
    allow(Intake).to receive(:search).and_return intakes_query_double
  end

  describe "#filtered_and_sorted_clients" do
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
          status: "intake_in_progress"
        }
      end

      it "creates a query for the search and scopes by other provided queries" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with({ tax_returns: { status: params[:status].to_sym } })
        expect(clients_query_double).to have_received(:where).with(intake: intakes_query_double)
      end
    end

    context "with a clear param" do
      let(:params) do
        {
            clear: true,
            search: "query",
            status: "intake_in_progress",
            year: "2019",
            needs_attention: true,
            assigned_to_me: true,
            unassigned: true,
        }
      end

      it "clears all of the existing params" do
        subject.filtered_and_sorted_clients
        expect(assigns(:filters).values.compact).to be_empty
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
    end
  end
end
