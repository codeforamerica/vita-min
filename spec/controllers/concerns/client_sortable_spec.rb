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
  end
end
