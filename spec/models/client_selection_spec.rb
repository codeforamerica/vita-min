# == Schema Information
#
# Table name: client_selections
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe ClientSelection, type: :model do
  describe "#clients" do
    let(:client_selection) { create(:client_selection) }
    let(:clients) { create_list(:client, 2) }

    it "has many through association" do
      clients.each do |client|
        client_selection.clients << client
      end

      expect(client_selection.clients.count).to eq 2
    end
  end
end
