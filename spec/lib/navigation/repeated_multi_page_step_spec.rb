require "rails_helper"

RSpec.describe Navigation::RepeatedMultiPageStep do

  let(:first_controller_class) { Class.new }
  let(:second_controller_class) { Class.new }
  let(:object_for_flow) { double }
  let(:instance) { described_class.new(controllers, ->(object_for_flow) { object_for_flow.count }) }

  before do
    allow(object_for_flow).to receive(:count).and_return(num_items)
  end

  describe "#pages" do
    context "with multiple controllers and multiple items" do
      let(:num_items) { 2 }
      let(:controllers) { [first_controller_class, second_controller_class] }
      let(:expected_pages) {
        [
          { item_index: 0, controller: first_controller_class },
          { item_index: 0, controller: second_controller_class },
          { item_index: 1, controller: first_controller_class },
          { item_index: 1, controller: second_controller_class }
        ]
      }
      it "returns the correct sequence of pages" do
        expect(instance.pages(object_for_flow)).to eq(expected_pages)
      end
    end

    context "with multiple controllers and no items" do
      let(:num_items) { 0 }
      let(:controllers) { [first_controller_class, second_controller_class] }
      let(:expected_pages) { [] }
      it "returns the correct sequence of pages" do
        expect(instance.pages(object_for_flow)).to eq(expected_pages)
      end
    end

  end
end
