require 'rails_helper'

describe TaxReturnCardHelper do
  describe "#tax_return_status_to_props" do
    (TaxReturnStateMachine.states - ['intake_before_consent']).each do |state|
      context "when the tax return is in #{state}" do
        let(:tax_return) { instance_double(TaxReturn) }

        before do
          allow(tax_return).to receive(:current_state).and_return(state)
          allow(tax_return).to receive(:ready_for_8879_signature?).and_return(false)
          allow(tax_return).to receive(:intake).and_return(Intake.new)
          allow(tax_return).to receive(:time_accepted).and_return(DateTime.now)
        end

        it "returns help text to show in the client portal" do
          expect(helper.tax_return_status_to_props(tax_return)).to match(hash_including(:help_text))
        end
      end
    end
  end
end
