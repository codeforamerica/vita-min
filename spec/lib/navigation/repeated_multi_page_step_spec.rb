require "rails_helper"

RSpec.describe Navigation::RepeatedMultiPageStep do

  let(:first_controller_class) { Class.new }
  let(:second_controller_class) { Class.new }
  let(:visitor_record) { double }
  let(:instance) { described_class.new("step_name", controllers, ->(visitor_record) { visitor_record.count }) }

  before do
    allow(visitor_record).to receive(:count).and_return(num_items)
  end

  describe "#pages" do
    context "with multiple controllers and multiple items" do
      let(:num_items) { 2 }
      let(:controllers) { [first_controller_class, second_controller_class] }
      let(:expected_pages) {
        [
          { item_index: 0, controller: first_controller_class, step: "step_name" },
          { item_index: 0, controller: second_controller_class, step: "step_name" },
          { item_index: 1, controller: first_controller_class, step: "step_name" },
          { item_index: 1, controller: second_controller_class, step: "step_name" }
        ]
      }
      it "returns the correct sequence of pages" do
        expect(instance.pages(visitor_record)).to eq(expected_pages)
      end
    end

    context "with multiple controllers and no items" do
      let(:num_items) { 0 }
      let(:controllers) { [first_controller_class, second_controller_class] }
      let(:expected_pages) { [] }
      it "returns the correct sequence of pages" do
        expect(instance.pages(visitor_record)).to eq(expected_pages)
      end
    end

  end
end
