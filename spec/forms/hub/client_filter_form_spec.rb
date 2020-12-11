require "rails_helper"

RSpec.describe Hub::ClientFilterForm do
  describe "#sort_column" do
    context "valid values" do
      it "permits preferred_name" do
        expect(described_class.new(sort_column: "preferred_name").sort_column).to eq("preferred_name")
      end

      it "permits updated_at" do
        expect(described_class.new(sort_column: "updated_at").sort_column).to eq("updated_at")
      end

      it "permits locale" do
        expect(described_class.new(sort_column: "locale").sort_column).to eq("locale")
      end
    end

    context "blank or invalid" do
      it "uses id by default" do
        expect(described_class.new.sort_column).to eq("id")
      end

      it "converts invalid values to id" do
        expect(described_class.new(sort_column: "invalid").sort_column).to eq("id")
      end
    end
  end

  describe "#sort_order" do
    context "asc by default" do
      it "uses asc by default" do
        expect(described_class.new.sort_order).to eq("asc")
      end

      it "uses asc when given bad values" do
        expect(described_class.new(sort_order: "bad").sort_order).to eq("asc")
      end
    end

    context "desc" do
      it "uses desc if given" do
        expect(described_class.new(sort_order: "desc").sort_order).to eq("desc")
      end
    end
  end

  describe "#filtered_and_sorted_clients" do
    context "filtering for consent" do
      let(:client_before_consent) { create(:client) }
      let(:client_after_consent) { create(:client, :with_return) }

      it "filters for only clients that have consented" do
        expect(subject.filtered_and_sorted_clients(
          Client.where(id: [client_after_consent.id, client_before_consent.id]))).to eq([client_after_consent])
      end
    end

    context "ordering" do
      let(:clients_query_double) { double }

      before do
        allow(clients_query_double).to receive(:after_consent).and_return(clients_query_double)
        allow(clients_query_double).to receive(:delegated_order)
      end

      it "passes sort_column and sort_order to Client#delegated_order" do
        subject.filtered_and_sorted_clients(clients_query_double)
        expect(clients_query_double).to have_received(:delegated_order).with(subject.sort_column, subject.sort_order)
      end
    end
  end
end
