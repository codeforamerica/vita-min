require "rails_helper"

RSpec.describe Questions::FileWithHelpController do
  describe "#next_path" do
    context "without an intake in the session" do
      it "returns the backtaxes controller" do
        expect(subject.next_path).to eq backtaxes_questions_path
      end
    end
  end
end
