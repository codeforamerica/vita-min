require "rails_helper"

describe EfileSubmissionTransition do
  describe "#initiated_by" do
    context "when a transition includes initiated_by metadata" do
      let(:user) { create :user }
      let(:transition) { EfileSubmissionTransition.new(metadata: { initiated_by_id: user.id })}
      it "returns the user associated with the initiated_by_id" do
        expect(transition.initiated_by).to eq user
      end
    end

    context "when a transition does not include initiated_by metadata" do
      let(:transition) { EfileSubmissionTransition.new }
      it "returns nil" do
        expect(transition.initiated_by).to eq nil
      end
    end
  end

  describe "#error_message" do
    context "when error message metadata is present" do
      let(:transition) { EfileSubmissionTransition.new(metadata: { error_message: "Something went wrong." })}

      it "returns the error_message" do
        expect(transition.error_message).to eq "Something went wrong."
      end
    end

    context "when error message metadata is not present" do
      let(:transition) { EfileSubmissionTransition.new }
      it "returns nil" do
        expect(transition.error_message).to be_nil
      end
    end
  end

  describe "#error_code" do
    context "when error_code metadata is present" do
      let(:transition) { EfileSubmissionTransition.new(metadata: { error_code: "R2D2" })}

      it "returns the error_code contents" do
        expect(transition.error_code).to eq "R2D2"
      end
    end

    context "when error_code metadata is not present" do
      let(:transition) { EfileSubmissionTransition.new(metadata: { other: "R2D2" })}

      it "returns nil" do
        expect(transition.error_code).to be_nil
      end
    end
  end
end