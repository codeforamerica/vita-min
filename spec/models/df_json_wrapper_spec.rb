require 'rails_helper'

class DfJsonTest < DfJsonWrapper
  def self.selectors = {
    dict_one: { type: :boolean, key: "dictOfNumbers one" },
    list_of_numbers: { type: :list, key: "listOfNumbers" }
  }

  define_json_readers
end

describe DfJsonWrapper do
  let(:json) { JSON.parse(json_string) }
  let(:instance) { DfJsonTest.new(json) }

  describe "#define_json_readers" do
    context "when the JSON has the correct structure" do
      let(:json_string) {
        <<~JSON_STRING
          {
            "listOfNumbers": [ 1, 3],
            "dictOfNumbers": { "one": true, "two": false, "three": true }
          }
        JSON_STRING
      }
      it "reads the values from the JSON" do
        expect(instance.dict_one).to be(true)
        expect(instance.list_of_numbers).to eq([1, 3])
      end
    end

    context "when the JSON is missing elements" do
      let(:json_string) {
        <<~JSON_STRING
          {
            "listOfBooleans": [ true, false, true],
            "dictOfColors": { "sky": "blue", "treeTrunk": "brown", "orange": "orange" }
          }
        JSON_STRING
      }
      it "returns nil" do
        expect(instance.dict_one).to be_nil
        expect(instance.list_of_numbers).to be_nil
      end
    end
  end
end