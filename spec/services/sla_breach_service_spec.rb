require 'rails_helper'

describe SLABreachService do
  describe "#breach_threshold_date" do
    around do |example|
      Timecop.freeze(t) do
        example.run
      end
    end

    context "running on a 2/11/21, Thursday at 10:05 UTC (2:05am PST)" do
      let(:t) { Time.utc(2021, 2, 11, 10, 5, 0) }

      it "time is 2/4/21, previous Wednesday at 10:05am UTC (2:05am PST)" do
        expect(subject.breach_threshold_date).to eq Time.utc(2021, 2, 3, 10, 5, 0)
      end
    end

    context "running on a Thursday at 6:05pm UTC (10:05am PST)" do
      let(:t) { Time.utc(2021, 2, 11, 18, 5, 0) }

      it "time is previous Wednesday at 6:05pm  UTC" do
        expect(subject.breach_threshold_date).to eq Time.utc(2021, 2, 3, 18, 5, 0)
      end
    end

    context "running on a Wednesday at 10:05am UTC" do
      let(:t) { Time.utc(2021, 2, 10, 10, 5, 0) }

      it "time is previous Tuesday at 10:05 am UTC" do
        expect(subject.breach_threshold_date).to eq Time.utc(2021, 2, 2, 10, 5)
      end
    end

    context "running on a Wednesday at 6:05pm UTC" do
      let(:t) { Time.utc(2021, 2, 10, 18, 5, 0) }

      it "time is previous Tuesday at 6:05pm UTC" do
        expect(described_class.new.breach_threshold_date).to eq Time.utc(2021, 2, 2, 18, 5)
      end
    end
  end

  describe "#active_sla_clients_count" do
    let(:vita_partners) { create_list(:organization, 2) }
    let(:clients_first) { create_list(:client, 3, vita_partner: vita_partners.first) }
    let(:clients_second) { create_list(:client, 2, vita_partner: vita_partners.second) }
    before do
      allow(Client).to receive(:sla_tracked).and_return Client.where(id: clients_first + clients_second)
    end

    it "relies directly on '.sla_tracked' and returns a hash by vita partner id" do
      expect(subject.active_sla_clients_count).to eq(
        {
          vita_partners.first.id => 3,
          vita_partners.second.id => 2,
        }
      )
    end
  end

  describe '.generate_report' do
    let(:t) { Time.utc(2021, 2, 5, 10, 5) }
    around do |example|
      Timecop.freeze(t) do
        example.run
      end
    end

    context "without any breaches" do
      it "returns a hash of attributes for the report" do
        report_hash = {
            breached_at: 6.business_days.before(t),
            generated_at: t,
            active_sla_clients_by_vita_partner_id: {},
            active_sla_clients_count: 0,
            communication_breaches_by_vita_partner_id: {},
            communication_breach_count: 0,
        }
        expect(SLABreachService.generate_report).to eq report_hash
      end
    end

    context "with current breaches" do
      let(:vita_partner_1) { create :organization }
      let(:vita_partner_2) { create :organization }
      before do
        # breaches at vita_partner_1
        _client1 = create(:client, last_outgoing_communication_at: 1.day.ago, intake: (build :intake), vita_partner_id: vita_partner_1.id, tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep)]) # within SLA
        _client1 = create(:client, last_outgoing_communication_at: 10.day.ago, intake: (build :intake), vita_partner_id: vita_partner_1.id, tax_returns: [build(:gyr_tax_return, :file_accepted)]) # excluded from SLA due to tax return state

        # breaches at vita_partner_2
        _client2 = create(:client, last_outgoing_communication_at: 1.day.ago, intake: (build :intake), vita_partner_id: vita_partner_2.id, tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep)]) # within SLA
        _client3 = create(:client, last_outgoing_communication_at: 1.day.ago, intake: (build :intake), vita_partner_id: vita_partner_2.id, tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep)]) # within SLA
        _client4 = create(:client, last_outgoing_communication_at: 10.day.ago, intake: (build :intake), vita_partner_id: vita_partner_2.id, tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep)]) # breached SLA
      end

      it "returns an accurate hash of attributes for the report" do
        report_hash = {
            breached_at: 6.business_days.before(t),
            generated_at: t,
            active_sla_clients_by_vita_partner_id: { vita_partner_1.id => 1, vita_partner_2.id => 3 },
            active_sla_clients_count: 4,
            communication_breaches_by_vita_partner_id: { vita_partner_2.id => 1 },
            communication_breach_count: 1,
        }
        expect(SLABreachService.generate_report).to eq report_hash
      end
    end
  end
end
