require "rails_helper"

RSpec.describe Navigation::NavigationSection do

  let(:first_controller_class) { Class.new }
  let(:second_controller_class) { Class.new }
  let(:first_repeated_controller_class) { Class.new }
  let(:second_repeated_controller_class) { Class.new }
  let(:visitor_record) { double }
  let(:num_items) { 2 }
  let!(:steps) do
    [
      Navigation::NavigationStep.new(first_controller_class),
      Navigation::NavigationStep.new(second_controller_class),
      Navigation::RepeatedMultiPageStep.new(
        [
          first_repeated_controller_class,
          second_repeated_controller_class
        ], ->(visitor_record) { visitor_record.count }
      )
    ]
  end

  before do
    allow(visitor_record).to receive(:count).and_return(num_items)
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

  it "produces an array of unique controllers" do
    section = Navigation::NavigationSection.new("a_section", steps)
    expect(section.controllers).to eq([
                                        first_controller_class,
                                        second_controller_class,
                                        first_repeated_controller_class,
                                        second_repeated_controller_class
                                      ])
  end

  it "produces an array of potentially non-unique pages" do
    section = Navigation::NavigationSection.new("a_section", steps)
    expect(section.pages(visitor_record)).to eq([
                                                   { controller: first_controller_class },
                                                   { controller: second_controller_class },
                                                   { item_index: 0, controller: first_repeated_controller_class },
                                                   { item_index: 0, controller: second_repeated_controller_class },
                                                   { item_index: 1, controller: first_repeated_controller_class },
                                                   { item_index: 1, controller: second_repeated_controller_class }
                                                 ])
  end
end
