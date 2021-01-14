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
    let(:last_four) { nil }
    let(:confirmation_number) { nil }
    let(:params) { { possible_clients: possible_clients, last_four: last_four, confirmation_number: confirmation_number } }
    let(:form) { described_class.new(params) }

    context "without possible clients" do
      let(:possible_clients) { nil }

      it "raises an error" do
        expect do
          form.client
        end.to raise_error(ArgumentError)
      end
    end

    context "with neither a last_four nor confirmation_number" do
      let(:last_four) { nil }
      let(:confirmation_number) { nil }

      it "finds no client and adds a validation error" do
        expect(form.client).to be_nil
        expect(form.errors).to be_present
      end
    end

    context "with a matching primary ssn" do
      let(:last_four) { "0987" }

      it "finds the right client" do
        expect(form.client).to eq client
      end
    end

    context "with a matching spouse ssn" do
      let(:last_four) { "1234" }

      it "finds the right client" do
        expect(form.client).to eq client
      end
    end

    context "with a matching confirmation number" do
      let(:confirmation_number) { client.id.to_s }

      it "finds the right client" do
        expect(form.client).to eq client
      end
    end

    context "with a non-matching ssn" do
      let(:last_four) { "0000" }

      it "finds no client and adds a validation error" do
        expect(form.client).to eq nil
        expect(form.errors).to include(:last_four)
      end
    end

    context "with a non-matching confirmation number" do
      let(:confirmation_number) { "0" }

      it "finds no client and adds a validation error" do
        expect(form.client).to eq nil
        expect(form.errors).to include(:confirmation_number)
      end
    end
  end
end

