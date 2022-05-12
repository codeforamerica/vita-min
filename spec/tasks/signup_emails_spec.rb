require "rails_helper"

describe "signup_emails:delete_followed_up" do
  include_context "rake"

  context "with signup objects marked with sent_followup as true" do
    let!(:followed_up) { create :signup, sent_followup: true }
    let!(:not_followed_up) { create :signup, sent_followup: false }

    it "deletes only those objects" do
      task.invoke
      expect(Signup.all).not_to include followed_up
      expect(Signup.all).to include not_followed_up
    end
  end
end