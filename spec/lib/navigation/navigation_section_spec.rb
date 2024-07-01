require "rails_helper"

RSpec.describe Navigation::NavigationSection do

  let!(:steps) do
    [
      Navigation::NavigationStep.new(StateFile::Questions::LandingPageController),
      Navigation::NavigationStep.new(StateFile::Questions::AzEligibilityResidenceController, false),
    ]
  end

  it "initializes correctly" do
    section = Navigation::NavigationSection.new("a_section", steps, false)
    expect(section.title).to eq("a_section")
    expect(section.steps).to eq(steps)
    expect(section.increment_step).to be_falsey
  end

  it "initializes default attributes correctly" do
    section = Navigation::NavigationSection.new("a_section", steps)
    expect(section.title).to eq("a_section")
    expect(section.steps).to eq(steps)
    expect(section.increment_step).to be_truthy
  end

  it "produces an array of controllers" do
    section = Navigation::NavigationSection.new("a_section", steps)
    expect(section.controllers).to eq [
      StateFile::Questions::LandingPageController,
      StateFile::Questions::AzEligibilityResidenceController,
    ]
  end
end