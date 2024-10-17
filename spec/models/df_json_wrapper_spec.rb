require 'rails_helper'

class DfJsonTest < DfJsonWrapper
  json_reader dict_one: { type: :boolean, key: "dictOfNumbers one" }
  json_reader list_of_numbers: { type: :list, key: "listOfNumbers" }
end

class DfJsonTestSubclass < DfJsonTest
  json_reader dict_two: { type: :boolean, key: "dictOfNumbers two" }
end

describe DfJsonWrapper do
  let(:json) { JSON.parse(json_string) }
  let(:instance) { DfJsonTest.new(json) }
  let(:subclass_instance) { DfJsonTestSubclass.new(json) }

  describe "#define_json_readers" do
    context "when the JSON has the correct structure" do
      let(:json_string) {
        <<~JSON
          {
            "listOfNumbers": [ 1, 3],
            "dictOfNumbers": { "one": true, "two": false, "three": true }
          }
        JSON
      }
      it "reads the values from the JSON" do
        expect(instance.dict_one).to be(true)
        expect(instance.list_of_numbers).to eq([1, 3])
      end

      it "subclasses can still access their superclass json_readers" do
        expect(subclass_instance.dict_one).to be(true)
        expect(subclass_instance.dict_two).to be(false)
      end
    end

    context "when the JSON is missing elements" do
      let(:json_string) {
        <<~JSON
          {
            "listOfBooleans": [ true, false, true],
            "dictOfColors": { "sky": "blue", "treeTrunk": "brown", "orange": "orange" }
          }
        JSON
      }
      it "returns nil" do
        expect(instance.dict_one).to be_nil
        expect(instance.list_of_numbers).to be_nil
      end
    end
  end
end