require "rails_helper"

RSpec.describe Questions::HadDependentsController do
  let(:had_dependents) { "unfilled" }
  let(:intake) { create :intake, had_dependents: had_dependents }

  before do
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#next_path" do
    context "when the user had dependents" do
      let(:had_dependents) { "yes" }

      it "returns the dependents path" do
        expect(subject.next_path).to eq dependents_path
      end
    end

    context "when the user didn't have dependents" do
      let(:had_dependents) { "no" }

      it "returns the default next navigation path" do
        expect(subject.next_path).to eq job_count_questions_path
      end
    end
  end
end

