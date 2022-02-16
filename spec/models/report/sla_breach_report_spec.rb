# == Schema Information
#
# Table name: reports
#
#  id           :bigint           not null, primary key
#  data         :jsonb
#  generated_at :datetime
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_reports_on_generated_at  (generated_at)
#
require 'rails_helper'

RSpec.describe Report::SLABreachReport, type: :model, requires_default_vita_partners: true do
  describe ".generate!" do

    let(:fake_report) do
      t = Time.utc(2021, 2, 5, 10, 5)
      {
        breached_at: 3.business_days.before(t),
        generated_at: t,
        communication_breaches_by_vita_partner_id: { 1 => 1 },
        communication_breach_count: 1,
      }
    end

    before do
      allow(SLABreachService).to receive(:generate_report).and_return fake_report.clone
    end

    it "creates a new SLABreachReport object" do
      expect {
        described_class.generate!
      }.to change(described_class, :count).by(1)
    end

    it "saves the data as JSON" do
      report = described_class.generate!
      expect(report.data).to eq JSON.parse(fake_report.without(:generated_at).to_json)
      expect(report.generated_at).to eq fake_report[:generated_at]
    end
  end

  describe "#communication_breaches" do
    let(:report) do
      Report::SLABreachReport.create(data: {
          communication_breaches_by_vita_partner_id: { 2 => 1, 3 => 2 }
      }, generated_at: DateTime.current)
    end

    it "converts json keys into integers" do
      expect(report.data["communication_breaches_by_vita_partner_id"]).to eq({ "2" => 1, "3" => 2 })
      expect(report.unanswered_communication_breaches).to eq({ 2 => 1, 3 => 2 })
    end

    it "uses 0 as a default value for hash keys that cant be found" do
      expect(report.unanswered_communication_breaches[1000]).to eq 0
    end
  end

  describe "#communication_breach_count" do
    let(:vita_partner) { create :organization }
    let(:report) do
      Report::SLABreachReport.create(data: {
          communication_breaches_by_vita_partner_id: { vita_partner.id => 2, 1467580 => 3 },
          communication_breach_count: 5
      }, generated_at: DateTime.current)
    end

    context "without vita_partners param" do
      it "returns the raw count" do
        expect(report.unanswered_communication_breach_count).to eq 5
      end
    end

    context "with vita_partners param" do
      context "when breaches are found for the vita partners" do
        it "returns the limited count based on passed vita_partners" do
          expect(report.unanswered_communication_breach_count(VitaPartner.where(id: vita_partner.id ))).to eq 2
        end
      end

      context "when breaches aren't found for the vita partners" do
        it "returns 0" do
          expect(report.unanswered_communication_breach_count(VitaPartner.where.not(id: vita_partner.id))).to eq 0
        end
      end
    end
  end

  describe "#breached_at" do
    let(:t) { Time.utc(2021, 2, 5, 10, 5) }
    let(:report) do
      Report::SLABreachReport.create(data: {
          breached_at: t
      }, generated_at: DateTime.current)
    end

    it "returns the breached_at value from the json data, informed by set time zone" do
      Time.use_zone("Hawaii") do
        expect(report.breached_at).to eq t.in_time_zone('Hawaii')
      end
    end
  end
end
