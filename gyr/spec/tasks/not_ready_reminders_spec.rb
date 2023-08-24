require "rails_helper"

describe "not_ready_reminders:remind" do
  include_context "rake"
  after(:each) do
    Rake::Task["not_ready_reminders:remind"].reenable
  end

  before do
    allow(Rails.configuration).to receive(:end_of_intake).and_return Date.tomorrow
  end

  it "is successful" do
    Rake::Task["not_ready_reminders:remind"].invoke
  end
end