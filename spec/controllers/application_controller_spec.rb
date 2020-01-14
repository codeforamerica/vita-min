require "rails_helper"

RSpec.describe ApplicationController do
  describe "#include_google_analytics?" do
    it "returns false" do
      expect(subject.include_google_analytics?).to eq false
    end
  end
end
