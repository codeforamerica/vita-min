require "rails_helper"

RSpec.describe Portal::ClientLoginForm do
  let(:intake) do
    create(
      :intake,
      primary_last_four_ssn: "0987",
      spouse_last_four_ssn: "1234"
    )
  end
  let!(:client) { intake.client }
  let!(:other_client) { create :client }

  describe "#client" do
    let(:possible_clients) { Client.where(id: [client.id, other_client.id]) }
    let(:last_four_or_client_id) { nil }
    let(:params) { { possible_clients: possible_clients, last_four_or_client_id: last_four_or_client_id } }
    let(:form) { described_class.new(params) }

    context "without possible clients" do
      let(:possible_clients) { nil }

      it "raises an error" do
        expect do
          form.client
        end.to raise_error(ArgumentError)
      end
    end

    context "with no last_four_or_client_id" do
      let(:last_four_or_client_id) { nil }

      it "finds no client and adds a validation error" do
        expect(form.client).to be_nil
        expect(form.errors).to include(:last_four_or_client_id)
      end
    end

    context "with a matching primary ssn" do
      let(:last_four_or_client_id) { "0987" }

      it "finds the right client" do
        expect(form.client).to eq client
      end
    end

    context "with a matching spouse ssn" do
      let(:last_four_or_client_id) { "1234" }

      it "finds the right client" do
        expect(form.client).to eq client
      end
    end

    context "with a matching client id" do
      let(:last_four_or_client_id) { client.id.to_s }

      it "finds the right client" do
        expect(form.client).to eq client
      end
    end

    context "with a non-matching number" do
      let(:last_four_or_client_id) { "0000" }

      it "finds no client and adds a validation error" do
        expect(form.client).to eq nil
        expect(form.errors).to include(:last_four_or_client_id)
      end
    end
  end
end

