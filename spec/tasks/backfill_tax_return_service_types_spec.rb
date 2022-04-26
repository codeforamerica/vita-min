require 'rails_helper'

describe "backfill_tax_return_service_types:backfill" do
  include_context "rake"

  around do |example|
    capture_output { example.run }
  end

  context "tax returns with nil service type" do
    let(:client) { create(:client, tax_returns: [create(:tax_return, service_type: "online_intake", year: 2021)]) }
    let!(:tax_return_with_sibling) { create :tax_return, service_type: nil, year: 2020, client: client }
    let!(:tax_return_without_sibling) { create :tax_return, service_type: nil, client: create(:client) }

    it "backfills with sibling's service type, or not at all" do
      task.invoke

      expect(tax_return_with_sibling.reload.service_type).to eq "online_intake"
      expect(tax_return_without_sibling.reload.service_type).to be_nil
    end
  end
end
