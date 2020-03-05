require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#you_or_spouse" do
    let(:filing_joint) { "no" }
    let(:intake) { create :intake, filing_joint: filing_joint }

    context "single filer" do
      it "returns 'you'" do
        expect(helper.you_or_spouse(intake)).to eq "you"
      end
    end

    context "joint filers" do
      let(:filing_joint) { "yes" }

      it "returns 'you or your spouse'" do
        expect(helper.you_or_spouse(intake)).to eq "you or your spouse"
      end
    end

    context "unknown whether filing jointly" do
      let(:filing_joint) { "unfilled" }

      it "returns 'you'" do
        expect(helper.you_or_spouse(intake)).to eq "you"
      end
    end
  end
end
