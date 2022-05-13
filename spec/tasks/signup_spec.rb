require "rails_helper"

describe "signup:delete_messaged" do
  include_context "rake"
  context "with signup objects marked with the sent_at attribute" do
      let!(:followed_up) { create :signup, ctc_2022_open_message_sent_at: DateTime.now }
      let!(:not_followed_up) { create :signup, ctc_2022_open_message_sent_at: nil }

      it "deletes only those objects" do
        ARGV.replace ["delete_messaged", "ctc_2022_open_message"]

        task.invoke
        expect(Signup.all).not_to include followed_up
        expect(Signup.all).to include not_followed_up
      end
    end
end

describe "signup:send_messages" do
  before do
    allow(SendSignupMessageJob).to receive(:perform_later)
  end

  include_context "rake"
  context "with signup objects that have not been sent the message" do
    it "enqueues a job" do
      ARGV.replace ["delete_messaged", "ctc_2022_open_message", "1000"]

      task.invoke
      expect(SendSignupMessageJob).to have_received(:perform_later).with("ctc_2022_open_message", 1000)
    end
  end
end