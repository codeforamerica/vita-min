require "rails_helper"

RSpec.describe BackfillAppropriateLastInteractionValue, type: :job do
  describe "#perform" do
    context "with a client with a non-nil last_outgoing_interaction_at" do
      it "does not update it" do

      end
    end
  end
end
