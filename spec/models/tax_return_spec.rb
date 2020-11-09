# == Schema Information
#
# Table name: tax_returns
#
#  id               :bigint           not null, primary key
#  status           :integer
#  year             :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  assigned_user_id :bigint
#  client_id        :bigint           not null
#
# Indexes
#
#  index_tax_returns_on_assigned_user_id    (assigned_user_id)
#  index_tax_returns_on_client_id           (client_id)
#  index_tax_returns_on_year_and_client_id  (year,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assigned_user_id => users.id)
#  fk_rails_...  (client_id => clients.id)
#
require "rails_helper"

describe TaxReturn do
  describe "validations" do
    let(:client) { create :client }

    it "does not allow multiple tax returns with the same year on the same client" do
      described_class.create(client: client, year: 2019)

      expect {
        described_class.create!(client: client, year: 2019)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "translation keys" do
    context "english keys" do
      it "has a key for each tax_return status" do
        described_class.statuses.each_key do |status|
          expect(I18n.t("case_management.tax_returns.status.#{status}")).not_to include("translation missing")
        end
      end
    end

    context "spanish" do
      before do
        I18n.locale = "es"
      end

      it "has a key for each tax_return status" do
        described_class.statuses.each_key do |status|
          expect(I18n.t("case_management.tax_returns.status.#{status}")).not_to include("translation missing")
        end
      end
    end


  end
end
