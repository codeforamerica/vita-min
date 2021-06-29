require "rails_helper"

describe RelationshipsHelper do
  describe '#dependent_relationship_options' do
    it 'provides the correct options' do
      expect(helper.dependent_relationship_options(nil)).to eq (
                                                              [
                                                                  ["Child", :child],
                                                                  ["Parent", :parent],
                                                                  ["Sibling", :sibling],
                                                                  ["Aunt/Uncle", :aunt_uncle],
                                                                  ["Niece/Nephew", :niece_nephew],
                                                                  ["Grandchild", :grandchild],
                                                                  ["Grandparent", :grandparent],
                                                                  ["Other", :other]
                                                              ]
                                                          )
    end

    context "with freeform entry" do
      it "provides the original freeform entry as an option" do
        expect(helper.dependent_relationship_options("My adopted son")).to eq (
                                                                                  [
                                                                                      ["Child", :child],
                                                                                      ["Parent", :parent],
                                                                                      ["Sibling", :sibling],
                                                                                      ["Aunt/Uncle", :aunt_uncle],
                                                                                      ["Niece/Nephew", :niece_nephew],
                                                                                      ["Grandchild", :grandchild],
                                                                                      ["Grandparent", :grandparent],
                                                                                      ["Other", :other],
                                                                                      ["Other: My adopted son", "My adopted son"]
                                                                                  ]
                                                                              )
      end

    end
  end

  describe "#translated_relationship" do
    context "with matching relationship from translation list (valet form)" do
      it "responds with the translated value" do
        expect(helper.translated_relationship(:aunt_uncle)).to eq "Aunt/Uncle"
      end
    end

    context "with free response (GYR intake flow)" do
      it "responds with the free response value" do
        expect(helper.translated_relationship("my sister's son")).to eq "my sister's son"
      end
    end
  end
end