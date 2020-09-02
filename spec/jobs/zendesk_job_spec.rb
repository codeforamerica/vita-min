require 'rails_helper'

RSpec.describe ZendeskJob, type: :job do
  describe "#max_attempts" do
    it "retries 5 times" do
      expect(subject.max_attempts).to eq(5)
    end
  end
end

