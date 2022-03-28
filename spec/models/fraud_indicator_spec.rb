# == Schema Information
#
# Table name: fraud_indicators
#
#  id                   :bigint           not null, primary key
#  activated_at         :datetime
#  description          :text
#  indicator_attributes :string           default([]), is an Array
#  indicator_type       :string
#  list_model_name      :string
#  multiplier           :float
#  name                 :string
#  points               :integer
#  query_model_name     :string
#  reference            :string
#  threshold            :float
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
require "rails_helper"

describe FraudIndicator do
  before do
    stub_const("FraudIndicator::Bunny", Class.new do
      def self.safelist
        ["Bunny", "Peter", "Rabbit", "Bugs"]
      end

      def self.riskylist
        ["Dog", "Pluto", "Mickey", "Cat"]
      end
    end)
  end
  
  describe '#execute' do
    let(:indicator) { FraudIndicator.new(indicator_type: "average_threshold", indicator_attributes: ["something"], threshold: "5") }
    context "when the reference is the same type as the query_model_name" do
      let(:client) { create :client }
      let(:query_double) { double }
      before do
        indicator.reference = "client"
        indicator.query_model_name = "Client"
        allow(Client).to receive(:where).and_return query_double
        allow(query_double).to receive(:average)
      end

      it "builds the scoped query using a single object" do
        indicator.execute(client: client)
        expect(Client).to have_received(:where).with(id: client.id)
      end
    end

    context "when the reference is a different type than the query_model_name" do
      let(:client) { create :client }
      let(:query_double) { double }
      before do
        indicator.reference = "client"
        indicator.query_model_name = "Intake"
        allow(Intake).to receive(:where).and_return query_double
        allow(query_double).to receive(:average)
      end

      it "builds the scoped query using a single object" do
        indicator.execute(client: client)
        expect(Intake).to have_received(:where).with("client" => client)
      end
    end


    context "when the indicator type has a defined method" do
      before do
        allow(indicator).to receive(:average_threshold)
      end

      it "calls the indicator_type method on the class with passed reference" do
        indicator.execute(client: create(:client), tax_return: create(:tax_return), efile_submission: create(:efile_submission), intake: create(:ctc_intake), bank_account: create(:bank_account))
        expect(indicator).to have_received(:average_threshold).with({
                                                              client: an_instance_of(Client),
                                                              efile_submission: an_instance_of(EfileSubmission),
                                                              intake: an_instance_of(Intake::CtcIntake),
                                                              bank_account: an_instance_of(BankAccount),
                                                              tax_return: an_instance_of(TaxReturn)
                                                          })
      end

    end
  end

  describe "#average_threshold" do
    let(:fraud_indicator) { FraudIndicator.new(name: "too_short", indicator_type: "average_threshold", reference: "client", indicator_attributes: ["height"], threshold: "60", query_model_name: "Intake") }
    let(:query_double) { double }
    let(:client) { create :client }

    before do
      allow(Intake).to receive(:where).and_return query_double
      allow(query_double).to receive(:average).and_return 40
    end

    context "validations" do
      it "is not valid without the appropriate data" do
        indicator = FraudIndicator.new(indicator_type: "average_threshold")
        expect(indicator.valid?).to eq false
        expect(indicator.errors[:name]).to include "Can't be blank."
        expect(indicator.errors[:indicator_attributes]).to include "must have length of 1"
        expect(indicator.errors[:threshold]).to include "is not a number"
        expect(indicator.errors[:query_model_name]).to include "Can't be blank."
        expect(indicator.errors[:reference]).to include "Can't be blank."
      end
    end

    it "builds a proper query" do
      expect(fraud_indicator.execute(client: client)).to eq true
      expect(query_double).to have_received(:average).with("height")
    end

    context "when average query returns nil (there are no objects to average)" do
      before do
        allow(query_double).to receive(:average).and_return nil
      end

      it "returns true (yes, is indicator of potential fraudiness)" do
        expect(fraud_indicator.execute(client: client)).to eq true
      end
    end
  end

  describe "#not_in_safelist" do
    let(:fraud_indicator) { FraudIndicator.new(name: "fraudy_if_not_a_bunny_name", indicator_type: "not_in_safelist", reference: "intake", indicator_attributes: ["primary_first_name"], query_model_name: "Intake", list_model_name: "FraudIndicator::Bunny") }
    let(:query_double) { double }
    let(:intake) { create :intake, primary_first_name: "Tiger" }

    context "validations" do
      it "is not valid without the appropriate data" do
        indicator = FraudIndicator.new(indicator_type: "not_in_safelist")
        expect(indicator.valid?).to eq false
        expect(indicator.errors[:name]).to include "Can't be blank."
        expect(indicator.errors[:indicator_attributes]).to include "must have length of 1"
        expect(indicator.errors[:query_model_name]).to include "Can't be blank."
        expect(indicator.errors[:list_model_name]).to include "Can't be blank."
        expect(indicator.errors[:reference]).to include "Can't be blank."
      end
    end

    context "stubbing everything" do
      before do
        allow(Intake).to receive(:where).and_return query_double
        allow(query_double).to receive_message_chain(:where, :not).and_return query_double # ensure a ActiveRecord query object
        allow(query_double).to receive(:exists?)
      end

      it "builds the appropriate query" do
        fraud_indicator.execute(intake: intake)
        expect(query_double.where).to have_received(:not).with("primary_first_name" => FraudIndicator::Bunny.safelist)
      end
    end

    context "when the excluded name appears in the set" do
      it "returns true to indicate that there is something potential fraudulent occurring" do
        expect(fraud_indicator.execute(intake: intake)).to eq true
      end
    end
  end

  describe "#in_riskylist" do
    let(:fraud_indicator) { FraudIndicator.new(name: "not_a_bunny", indicator_type: "in_riskylist", reference: "intake", indicator_attributes: ["primary_first_name"], query_model_name: "Intake", list_model_name: "FraudIndicator::Bunny") }
    let(:query_double) { double }
    let(:intake) { create :intake, primary_first_name: "Mickey" }

    context "validations" do
      it "is not valid without the appropriate data" do
        indicator = FraudIndicator.new(indicator_type: "in_riskylist")
        expect(indicator.valid?).to eq false
        expect(indicator.errors[:name]).to include "Can't be blank."
        expect(indicator.errors[:indicator_attributes]).to include "must have length of 1"
        expect(indicator.errors[:query_model_name]).to include "Can't be blank."
        expect(indicator.errors[:list_model_name]).to include "Can't be blank."
        expect(indicator.errors[:reference]).to include "Can't be blank."
      end
    end

    context "stubbing everything" do
      before do
        allow(Intake).to receive(:where).and_return query_double
        allow(query_double).to receive_message_chain(:where).and_return query_double # ensure a ActiveRecord query object
        allow(query_double).to receive(:exists?)
      end

      it "builds the appropriate query" do
        fraud_indicator.execute(intake: intake)
        expect(query_double).to have_received(:where).with("primary_first_name" => FraudIndicator::Bunny.riskylist)
      end
    end

    context "when a name that is on the in_riskylist is included in the set" do
      it "returns true to indicate that there is something potential fraudulent occurring" do
        expect(fraud_indicator.execute(intake: intake)).to eq true
      end
    end
  end

  describe "#duplicates" do
    let(:query_double) { double }
    let(:intake) { create :ctc_intake }
    let(:client) { create :client }
    let(:fraud_indicator) { FraudIndicator.new(name: "duplicated_stuff", indicator_type: "duplicates", reference: "client", query_model_name: "Intake::CtcIntake", indicator_attributes: [:primary_first_name, :primary_last_name]) }

    context "validations" do
      it "is not valid without the appropriate data" do
        indicator = FraudIndicator.new(indicator_type: "duplicates")
        expect(indicator.valid?).to eq false
        expect(indicator.errors[:name]).to include "Can't be blank."
        expect(indicator.errors[:indicator_attributes]).to include "must have minimum length of 1"
        expect(indicator.errors[:query_model_name]).to include "Can't be blank."
        expect(indicator.errors[:reference]).to include "Can't be blank."
      end
    end

    before do
      allow(DeduplificationService).to receive(:duplicates).and_return query_double
      allow(query_double).to receive(:count).and_return 2
    end

    it "sets up the query correctly" do
      fraud_indicator.execute(intake: intake, client: client)
      expect(DeduplificationService).to have_received(:duplicates).with(client, "primary_first_name", "primary_last_name", from_scope: Intake::CtcIntake)
    end

    context "when there are duplicates" do
      it "returns the count of duplicates" do
        expect(fraud_indicator.execute(intake: intake, client: client)).to eq 2
      end
    end

    context "when there are no duplicates" do
      before do
        allow(query_double).to receive(:count).and_return 0
      end

      it "returns the count of duplicates" do
        expect(fraud_indicator.execute(intake: intake, client: client)).to eq false
      end
    end
  end

  describe "#missing" do
    let(:tax_return) { create :tax_return }
    let(:query_double) { double }
    let(:fraud_indicator) { FraudIndicator.create(name: "no_transitions", indicator_type: "missing", query_model_name: "EfileSubmission", reference: "tax_return", indicator_attributes: ["efile_submission_transitions"]) }
    before do
      allow(EfileSubmission).to receive(:where).and_return query_double
      allow(query_double).to receive_message_chain(:where, :missing).and_return query_double # ensure a ActiveRecord query object
      allow(query_double).to receive(:exists?).and_return true
    end

    context "validations" do
      it "is not valid without the appropriate data" do
        indicator = FraudIndicator.new(indicator_type: "missing")
        expect(indicator.valid?).to eq false
        expect(indicator.errors[:name]).to include "Can't be blank."
        expect(indicator.errors[:indicator_attributes]).to include "must have length of 1"
        expect(indicator.errors[:query_model_name]).to include "Can't be blank."
        expect(indicator.errors[:reference]).to include "Can't be blank."
      end
    end

    it "builds the appropriate query" do
      fraud_indicator.execute(tax_return: tax_return)
      expect(EfileSubmission).to have_received(:where).with({ "tax_return" => tax_return })
      expect(query_double.where).to have_received(:missing).with("efile_submission_transitions")
    end

    context "when elements with missing transitions exist" do
      it "returns true" do
        expect(fraud_indicator.execute(tax_return: tax_return)).to eq true
      end
    end
  end

  describe "#equals" do
    let(:fraud_indicator) { FraudIndicator.create(name: "no_accepted", indicator_type: "equals", query_model_name: "Intake", reference: "client", indicator_attributes: ["primary_first_name", "Martin"]) }
    let(:query_double) { double }
    let(:client) { create :client }
    before do
      allow(Intake).to receive(:where).and_return query_double
      allow(query_double).to receive(:where).and_return query_double # ensure a ActiveRecord query object
      allow(query_double).to receive(:exists?).and_return true
    end

    context "validations" do
      it "is not valid without the appropriate data" do
        indicator = FraudIndicator.new(indicator_type: "equals")
        expect(indicator.valid?).to eq false
        expect(indicator.errors[:name]).to include "Can't be blank."
        expect(indicator.errors[:indicator_attributes]).to include "must have length of 2"
        expect(indicator.errors[:query_model_name]).to include "Can't be blank."
        expect(indicator.errors[:reference]).to include "Can't be blank."
      end
    end

    it "builds the appropriate query" do
      fraud_indicator.execute(client: client)
      expect(Intake).to have_received(:where).with({ "client" => client })
      expect(query_double).to have_received(:where).with({ "primary_first_name" => "Martin" })
    end
  end
end
