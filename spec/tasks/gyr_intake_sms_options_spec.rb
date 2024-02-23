require "rails_helper"

describe "gyr_intake_sms_options:update" do
  include_context "rake"

  context "with signup objects marked with the sent_at attribute" do
    before do
      allow(UpdateGyrIntakeSmsOptionsJob).to receive(:perform_now)
    end

    it "deletes only those objects" do
      task.invoke
      expect(UpdateGyrIntakeSmsOptionsJob).to have_received(:perform_now)
    end
  end
end
