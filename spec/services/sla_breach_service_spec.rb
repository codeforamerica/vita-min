require 'rails_helper'

describe SLABreachService do
  describe "#breach_threshold" do
    after do
      Timecop.return
    end

    context "running on a 2/11/21, Thursday at 10:05 UTC (2:05am PST)" do
      before do
        t = Time.utc(2021, 2, 11, 10, 5, 0)
        Timecop.freeze(t)
      end

      it "time is 2/8/11, Monday at 10:05am UTC (2:05am PST)" do
        expect(subject.breach_threshold).to eq Time.utc(2021, 2, 8, 10, 5, 0)
      end
    end

    context "running on a Thursday at 6:05pm UTC (10:05am PST)" do
      before do
        t = Time.utc(2021, 2, 11, 18, 5, 0)
        Timecop.freeze(t)
      end

      it "time is Monday at 6:05pm  UTC" do
        expect(subject.breach_threshold).to eq Time.utc(2021, 2, 8, 18, 5, 0)
      end
    end

    context "running on a Wednesday at 10:05am UTC" do
      before do
        t = Time.utc(2021, 2, 10, 10, 5, 0)
        Timecop.freeze(t)
      end

      it "time is previous Friday at 10:05 am UTC" do
        expect(subject.breach_threshold).to eq Time.utc(2021, 2, 5, 10, 5)
      end
    end

    context "running on a Wednesday at 6:05pm UTC" do
      before do
        t = Time.utc(2021, 2, 10, 18, 5, 0)
        Timecop.freeze(t)
      end

      it "time is previous Friday at 6:05pm UTC" do
        expect(described_class.new.breach_threshold).to eq Time.utc(2021, 2, 5, 18, 5)
      end
    end
  end

  describe '.attention_needed_breach' do
    let(:vita_partner_1) { create(:organization) }
    let(:vita_partner_2) { create(:organization) }

    context "processing on a Friday @ 10:05am UTC" do
      before do
        t = Time.utc(2021, 2, 6, 10, 5) # 2/6/21, Saturday
        Timecop.freeze(t.prev_occurring(:friday)) # 2/5/21, Friday
        # breaches at vita_partner_1
        create(:client, attention_needed_since: t.prev_occurring(:monday), vita_partner_id: vita_partner_1.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # breach

        # breaches at vita_partner_2
        create(:client, attention_needed_since: 6.days.ago, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        create(:client, attention_needed_since: t.prev_occurring(:monday), vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach

        # not in breach
        create(:client, attention_needed_since: t.prev_occurring(:wednesday), vita_partner_id: vita_partner_2.id,  tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
        create(:client, attention_needed_since: nil, vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
      end

      after do
        Timecop.return
      end

      it 'returns a hash of total SLA breaches of attention_needed_breach_since by vita_partner_id' do
        expect(subject.attention_needed_breach).to eq(
          {
              vita_partner_1.id => 1,
              vita_partner_2.id => 2
          }
        )
      end
    end

    context "processing on a Monday" do
      before do
        t = Time.utc(2021, 2, 6, 0, 0, 0) # 2/6/21
        Timecop.freeze(t.next_occurring(:monday) + 10.hours + 5.minutes) # 2/8/21, Monday 10:05am
        # breaches at vita_partner_1
        create(:client, attention_needed_since: t.prev_occurring(:monday), vita_partner_id: vita_partner_1.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        # breaches at vita_partner_2
        create(:client, attention_needed_since: 6.days.ago, vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        wednesday_1am = t.prev_occurring(:wednesday) + 1.hour # Wednesday 2/3/21 @ 1:00am UTC
        create(:client, attention_needed_since: wednesday_1am, vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach

        wednesday_1055am = t.prev_occurring(:wednesday) + 10.hour + 55.minutes # Wednesday 2/3/21 @ 10:55am UTC
        create(:client, attention_needed_since: wednesday_1055am, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # not in breach t1, in breach t2

        # not in breach
        create(:client, attention_needed_since: nil, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
      end

      after do
        Timecop.return
      end

      context "on Monday @10:05am UTC"
      it 'returns a hash of total SLA breaches of attention_needed_breach_since by vita_partner_id' do
        expect(subject.breach_threshold).to eq(Time.utc(2021, 2, 3, 10, 5)) # Wednesday 2/3/21 @ 10:05am UTC
        expect(subject.attention_needed_breach).to eq(
          {
              vita_partner_1.id => 1,
              vita_partner_2.id => 2
          }
        )
      end

      context "on Monday @ 11:25am UTC" do
        it "trips the 10:55am client into SLA breach" do
          t = Time.utc(2021, 2, 6, 0, 0, 0) # 2/6/21
          Timecop.freeze(t.next_occurring(:monday) + 11.hours + 25.minutes) do
            expect(subject.breach_threshold).to eq(Time.utc(2021, 2, 3, 11, 25)) # Wednesday 2/3/21 @ 11:25am UTC
            expect(subject.attention_needed_breach).to eq(
              {
                vita_partner_1.id => 1,
                vita_partner_2.id => 3
              }
            )
          end
        end
      end
    end
  end
end