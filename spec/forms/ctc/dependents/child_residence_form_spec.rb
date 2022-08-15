require 'rails_helper'

describe Ctc::Dependents::ChildResidenceForm do
  describe "#save" do
    let(:intake) { create :ctc_intake, claim_eitc: claim_eitc }
    let(:claim_eitc) { "yes" }
    let(:dependent) { create :dependent, intake: intake }

    context "when the client is claiming EITC" do
      context "when dependent has lived with a client for 8 months" do
        it "saves number of months as 8" do
          expect {
            form = described_class.new(dependent, { months_in_home: 8 })
            form.save
          }.to change(dependent, :months_in_home).to(8)
        end
      end
    end

    context "when the client is not claiming EITC" do
      let(:claim_eitc){ "no" }
      context "when dependent has lived with a client more than 6 months" do
        it "saves number of months as 7" do
          expect {
            form = described_class.new(dependent, { months_in_home: 10 })
            form.save
          }.to change(dependent, :months_in_home).to(7)
        end
      end

      context "when dependent has lived with a client less than 6 months" do
        it "saves number of months as 6" do
          expect {
            form = described_class.new(dependent, { months_in_home: 3 })
            form.save
          }.to change(dependent, :months_in_home).to(6)
        end
      end
    end
  end
end