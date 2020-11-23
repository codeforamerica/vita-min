# == Schema Information
#
# Table name: tax_returns
#
#  id                  :bigint           not null, primary key
#  certification_level :integer
#  is_hsa              :boolean
#  status              :integer          default("intake_before_consent"), not null
#  year                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  assigned_user_id    :bigint
#  client_id           :bigint           not null
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
          expect(I18n.t("hub.tax_returns.status.#{status}")).not_to include("translation missing")
        end
      end
    end

    context "spanish" do
      before do
        I18n.locale = "es"
      end

      it "has a key for each tax_return status" do
        described_class.statuses.each_key do |status|
          expect(I18n.t("hub.tax_returns.status.#{status}")).not_to include("translation missing")
        end
      end
    end
  end

  describe "#advance_to" do
    let(:tax_return) { create :tax_return, status: "intake_open" }

    context "with a status that comes before the current status" do
      let(:status) { "intake_in_progress" }

      it "does not change the status" do
        expect do
          tax_return.advance_to(status)
        end.not_to change(tax_return, :status)
      end
    end

    context "with a status that comes after the current status" do
      let(:status) { "finalize_signed" }

      it "changes to the new status" do
        expect do
          tax_return.advance_to(status)
        end.to change(tax_return, :status).from("intake_open").to "finalize_signed"
      end
    end
  end

  describe ".grouped_statuses" do
    let(:result) { TaxReturnStatus::STATUSES_BY_STAGE }

    it "returns a hash with all stage keys" do
      expect(result).to have_key("intake")
      expect(result).to have_key("prep")
      expect(result).to have_key("review")
      expect(result).to have_key("finalize")
      expect(result).to have_key("filed")
    end

    it "includes all intake statuses except before consent" do
      expect(result["intake"].length).to eq 6
      expect(result["intake"]).not_to include "intake_before_consent"
    end

    it "includes all prep statuses" do
      expect(result["prep"].length).to eq 4
    end

    it "includes all review statuses" do
      expect(result["review"].length).to eq 3
    end

    it "includes all finalize statuses" do
      expect(result["finalize"].length).to eq 2
    end

    it "includes all filed statuses" do
      expect(result["filed"].length).to eq 4
    end
  end
end
