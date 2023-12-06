require "rails_helper"

RSpec.feature "Visit State File home page" do
  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  it "has content" do
    visit "/"
    expect(page).to have_text "FileYourStateTaxes"
  end
end
