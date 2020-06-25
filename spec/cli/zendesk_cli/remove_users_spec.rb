# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZendeskCli::RemoveUsers do
  let(:fake_csv_path) { "/tmp/test-file.csv" }
  let(:instance) { described_class.new(csv_path: fake_csv_path) }

  describe "#parse_csv" do
    let(:valid_csv) { <<~CSV }
      id,email,name,last_login_at,default_group_id,created_at
      400000000000,tomatio@example.com,Tom A Tio,2020-04-24 17:03:44 UTC,360000000000,2020-04-23 22:41:46 UTC
    CSV

    before do
      allow(File).to receive(:read).with(fake_csv_path).and_return(valid_csv)
    end

    context "given a valid CSV" do
      it "returns a list of agents" do
        results = instance.parse_csv(fake_csv_path)
        expect(results.length).to eq(1)
        expect(results.first["id"]).to eq("400000000000")
        expect(results.first["email"]).to eq("tomatio@example.com")
      end
    end
  end
end
