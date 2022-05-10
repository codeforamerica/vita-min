require "rails_helper"

Rails.application.load_tasks

describe "not_ready:remind" do
  after(:each) do
    Rake::Task["not_ready:remind"].reenable
  end

  before do
    allow(Rails.configuration).to receive(:end_of_intake).and_return Date.tomorrow
  end

  it "is successful" do
    Rake::Task["not_ready:remind"].invoke
  end
end