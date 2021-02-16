require 'rails_helper'

describe SLABreachService do
  describe "#breach_threshold_date" do
    after do
      Timecop.return
    end

    context "running on a 2/11/21, Thursday at 10:05 UTC (2:05am PST)" do
      before do
        t = Time.utc(2021, 2, 11, 10, 5, 0)
        Timecop.freeze(t)
      end

      it "time is 2/8/11, Monday at 10:05am UTC (2:05am PST)" do
        expect(subject.breach_threshold_date).to eq Time.utc(2021, 2, 8, 10, 5, 0)
      end
    end

    context "running on a Thursday at 6:05pm UTC (10:05am PST)" do
      before do
        t = Time.utc(2021, 2, 11, 18, 5, 0)
        Timecop.freeze(t)
      end

      it "time is Monday at 6:05pm  UTC" do
        expect(subject.breach_threshold_date).to eq Time.utc(2021, 2, 8, 18, 5, 0)
      end
    end

    context "running on a Wednesday at 10:05am UTC" do
      before do
        t = Time.utc(2021, 2, 10, 10, 5, 0)
        Timecop.freeze(t)
      end

      it "time is previous Friday at 10:05 am UTC" do
        expect(subject.breach_threshold_date).to eq Time.utc(2021, 2, 5, 10, 5)
      end
    end

    context "running on a Wednesday at 6:05pm UTC" do
      before do
        t = Time.utc(2021, 2, 10, 18, 5, 0)
        Timecop.freeze(t)
      end

      it "time is previous Friday at 6:05pm UTC" do
        expect(described_class.new.breach_threshold_date).to eq Time.utc(2021, 2, 5, 18, 5)

      end
    end
  end

  describe '.attention_needed_breaches' do
    let(:vita_partner_1) { create(:organization) }
    let(:vita_partner_2) { create(:organization) }

    context "processing on a Friday @ 10:05am UTC" do
      before do
        t = Time.utc(2021, 2, 6, 10, 5) # 2/6/21, Saturday
        Timecop.freeze(t.prev_occurring(:friday)) # 2/5/21, Friday
        # breaches at vita_partner_1

        client1 = create(:client, vita_partner_id: vita_partner_1.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t.prev_occurring(:monday)) { client1.set_attention_needed }

        # breaches at vita_partner_2
        client2 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(6.days.ago) { client2.set_attention_needed }

        client3 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t.prev_occurring(:monday)) { client3.set_attention_needed }

        # not in breach
        client4 = create(:client, vita_partner_id: vita_partner_2.id,  tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
        Timecop.freeze(t.prev_occurring(:wednesday)) { client4.set_attention_needed }

        client5 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
        client5.clear_attention_needed
      end

      after do
        Timecop.return
      end

      it 'returns a hash of total SLA breaches of attention_needed breaches by vita_partner_id' do
        expect(subject.attention_needed_breaches).to eq(
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
        client1 = create(:client, vita_partner_id: vita_partner_1.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t.prev_occurring(:monday)) { client1.set_attention_needed }

        # breaches at vita_partner_2
        client2 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(6.days.ago) { client2.set_attention_needed }

        wednesday_1am = t.prev_occurring(:wednesday) + 1.hour # Wednesday 2/3/21 @ 1:00am UTC
        client3 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(wednesday_1am) { client3.set_attention_needed }

        wednesday_1055am = t.prev_occurring(:wednesday) + 10.hour + 55.minutes # Wednesday 2/3/21 @ 10:55am UTC
        client4 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # not in breach t1, in breach t2
        Timecop.freeze(wednesday_1055am) { client4.set_attention_needed }

        # not in breach
        create(:client, attention_needed_since: nil, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
      end

      after do
        Timecop.return
      end

      context "on Monday @10:05am UTC" do
        it 'returns a hash of total SLA breaches of attention_needed_breach_since by vita_partner_id' do
          expect(subject.breach_threshold_date).to eq(Time.utc(2021, 2, 3, 10, 5)) # Wednesday 2/3/21 @ 10:05am UTC
          expect(subject.attention_needed_breaches).to eq(
            {
              vita_partner_1.id => 1,
              vita_partner_2.id => 2
            }
          )
        end
      end

      context "on Monday @ 11:25am UTC" do
        it "trips the 10:55am client into SLA breach" do
          t = Time.utc(2021, 2, 6, 0, 0, 0) # 2/6/21
          Timecop.freeze(t.next_occurring(:monday) + 11.hours + 25.minutes) do
            expect(subject.breach_threshold_date).to eq(Time.utc(2021, 2, 3, 11, 25)) # Wednesday 2/3/21 @ 11:25am UTC
            expect(subject.attention_needed_breaches).to eq(
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

  describe '.outgoing_communication_breaches' do
    let(:vita_partner_1) { create(:organization) }
    let(:vita_partner_2) { create(:organization) }

    context "processing on a Friday @ 10:05am UTC" do
      before do
        t = Time.utc(2021, 2, 6, 10, 5) # 2/6/21, Saturday
        Timecop.freeze(t.prev_occurring(:friday)) # 2/5/21, Friday
        # breaches at vita_partner_1
        client1 = create(:client, vita_partner_id: vita_partner_1.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t.prev_occurring(:monday)) { client1.tax_returns.first.record_incoming_interaction }

        # breaches at vita_partner_2
        client2 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t - 6.days) { client2.tax_returns.first.record_incoming_interaction }

        client3 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t - 6.days) { client3.tax_returns.first.record_incoming_interaction }
        # not in breach
        client4 = create(:client, vita_partner_id: vita_partner_2.id,  tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
        Timecop.freeze(t.prev_occurring(:wednesday)) { client4.tax_returns.first.record_incoming_interaction }

        client5 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
        Timecop.freeze(t) { client5.tax_returns.first.record_outgoing_interaction }
      end

      after do
        Timecop.return
      end

      it 'returns a hash of total SLA breaches of outgoing communication breaches by vita_partner_id' do
        expect(subject.outgoing_communication_breaches).to eq(
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
        client1 = create(:client, vita_partner_id: vita_partner_1.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t.prev_occurring(:wednesday)) { client1.tax_returns.first.record_incoming_interaction }

        # breaches at vita_partner_2
        client2 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t - 6.days) { client2.tax_returns.first.record_incoming_interaction }

        wednesday_1am = t.prev_occurring(:wednesday) + 1.hour # Wednesday 2/3/21 @ 1:00am UTC
        client3 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(wednesday_1am) { client3.tax_returns.first.record_incoming_interaction }

        wednesday_1055am = t.prev_occurring(:wednesday) + 10.hour + 55.minutes # Wednesday 2/3/21 @ 10:55am UTC
        client4 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # not in breach t1, in breach t2
        Timecop.freeze(wednesday_1055am) { client4.tax_returns.first.record_incoming_interaction }

        # not in breach
        client5 =create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
        Timecop.freeze(t) { client5.tax_returns.first.record_outgoing_interaction }
      end

      after do
        Timecop.return
      end

      context "on Monday @10:05am UTC" do
        it 'returns a hash of total SLA breaches of attention needed breaches by vita_partner_id' do
          expect(subject.breach_threshold_date).to eq(Time.utc(2021, 2, 3, 10, 5)) # Wednesday 2/3/21 @ 10:05am UTC
          expect(subject.outgoing_communication_breaches).to eq(
            {
              vita_partner_1.id => 1,
              vita_partner_2.id => 2
            }
          )
        end
      end

      context "on Monday @ 11:25am UTC" do
        it "trips the 10:55am client into SLA breach" do
          t = Time.utc(2021, 2, 6, 0, 0, 0) # 2/6/21
          Timecop.freeze(t.next_occurring(:monday) + 11.hours + 25.minutes) do
            expect(subject.breach_threshold_date).to eq(Time.utc(2021, 2, 3, 11, 25)) # Wednesday 2/3/21 @ 11:25am UTC
            expect(subject.outgoing_communication_breaches).to eq(
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

  describe ".outgoing_interaction_breaches" do
    let(:vita_partner_1) { create(:organization) }
    let(:vita_partner_2) { create(:organization) }

    context "processing on a Friday @ 10:05am UTC" do
      before do
        t = Time.utc(2021, 2, 5, 10, 5) # 2/5/21, Friday
        Timecop.freeze(t)
        # # breaches at vita_partner_1
        client1 = create(:client, vita_partner_id: vita_partner_1.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t.prev_occurring(:monday)) { client1.tax_returns.first.record_incoming_interaction }
        client1.update(last_internal_or_outgoing_interaction_at: nil)


        # breaches at vita_partner_2
        client2 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        # Timecop doesn't play too nicely with "ago", so do some old-fashioned subtraction
        Timecop.freeze(t - 7.days) { client2.tax_returns.first.record_internal_interaction }
        Timecop.freeze(t - 6.days) { client2.tax_returns.first.record_incoming_interaction }

        client3 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t.prev_occurring(:monday)) { client3.tax_returns.first.record_incoming_interaction }
        Timecop.freeze(t - 15.years) { client3.tax_returns.first.record_internal_interaction }
        # # not in breach
        client4 = create(:client, vita_partner_id: vita_partner_2.id,  tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
        Timecop.freeze(t.prev_occurring(:monday)) { client4.tax_returns.first.record_incoming_interaction }
        Timecop.freeze(t) { client4.tax_returns.first.record_internal_interaction }

        client5 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
        client5.tax_returns.first.record_outgoing_interaction
      end

      after do
        Timecop.return
      end

      it 'returns a hash of total SLA breaches of outgoing communication breaches by vita_partner_id' do
        expect(subject.outgoing_interaction_breaches).to eq(
         {
           vita_partner_1.id => 1,
           vita_partner_2.id => 2
         }
       )
      end
    end

    context "processing on a Monday @ 10:05am UTC" do
      before do
        t = Time.utc(2021, 2, 6, 0, 0, 0) # 2/6/21
        Timecop.freeze(t.next_occurring(:monday) + 10.hours + 5.minutes) # 2/8/21, Monday 10:05am
        # breaches at vita_partner_1

        client1 = create(:client, vita_partner_id: vita_partner_1.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t.prev_occurring(:monday)) { client1.tax_returns.first.record_incoming_interaction }
        Timecop.freeze(t - 12.days) { client1.tax_returns.first.record_internal_interaction }

        # breaches at vita_partner_2
        client2 = create(:client,  vita_partner_id: vita_partner_2.id, tax_returns:  [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        Timecop.freeze(t - 6.days) { client2.tax_returns.first.record_incoming_interaction }
        Timecop.freeze(t - 12.days) { client2.tax_returns.first.record_internal_interaction }

        wednesday_1am = t.prev_occurring(:wednesday) + 1.hour # Wednesday 2/3/21 @ 1:00am UTC
        client3 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # breach
        client3.update(last_internal_or_outgoing_interaction_at: nil)
        Timecop.freeze(wednesday_1am) { client3.tax_returns.first.record_incoming_interaction }

        wednesday_1055am = t.prev_occurring(:wednesday) + 10.hour + 55.minutes # Wednesday 2/3/21 @ 10:55am UTC
        client4 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # not in breach t1, in breach t2
        Timecop.freeze(wednesday_1055am) { client4.tax_returns.first.record_incoming_interaction }
        Timecop.freeze(t - 18.days) { client4.tax_returns.first.record_internal_interaction}

        # not in breach
        client5 = create(:client, vita_partner_id: vita_partner_2.id, tax_returns: [create(:tax_return, status: 'prep_ready_for_prep')]) # no breach
        Timecop.freeze(t - 1.day) { client5.tax_returns.first.record_outgoing_interaction }
      end

      after do
        Timecop.return
      end

      context "on Monday @10:05am UTC" do
        it 'returns a hash of total SLA breaches of attention_needed_breacheseses_since by vita_partner_id' do
          expect(subject.breach_threshold_date).to eq(Time.utc(2021, 2, 3, 10, 5)) # Wednesday 2/3/21 @ 10:05am UTC
          expect(subject.outgoing_interaction_breaches).to eq(
           {
             vita_partner_1.id => 1,
             vita_partner_2.id => 2
           }
         )
        end
      end

      context "on Monday @ 11:25am UTC" do
        it "trips the 10:55am client into SLA breach" do
          t = Time.utc(2021, 2, 6, 0, 0, 0) # 2/6/21
          Timecop.freeze(t.next_occurring(:monday) + 11.hours + 25.minutes) do
            expect(subject.breach_threshold_date).to eq(Time.utc(2021, 2, 3, 11, 25)) # Wednesday 2/3/21 @ 11:25am UTC
            expect(subject.outgoing_interaction_breaches).to eq(
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