require "rails_helper"

describe RelationshipsHelper do
  describe '#dependent_relationship_options' do
    it 'provides the correct options' do
      expect(helper.dependent_relationship_options).to eq(
        [
          ["Daughter", :daughter],
          ["Son", :son],
          ["Parent", :parent],
          ["Grandchild", :grandchild],
          ["Niece", :niece],
          ["Nephew", :nephew],
          ["Foster Child", :foster_child],
          ["Aunt", :aunt],
          ["Uncle", :uncle],
          ["Sister", :sister],
          ["Brother", :brother],
          ["Stepchild", :stepchild],
          ["Stepbrother", :stepbrother],
          ["Stepsister", :stepsister],
          ["Half brother", :half_brother],
          ["Half sister", :half_sister],
          ["Grandparent", :grandparent],
          ["Great-grandchild", :great_grandchild],
          ["Step parent", :step_parent],
          ["In law", :in_law],
          ["Other descendants of my siblings", :siblings_descendant],
          ["Other relationship not listed", :other]
        ]
      )
    end

    context "with freeform entry" do
      it "provides the original freeform entry as an option" do
        expect(helper.dependent_relationship_options(current_relationship: "My adopted son")).to eq(
          [
            ["Daughter", :daughter],
            ["Son", :son],
            ["Parent", :parent],
            ["Grandchild", :grandchild],
            ["Niece", :niece],
            ["Nephew", :nephew],
            ["Foster Child", :foster_child],
            ["Aunt", :aunt],
            ["Uncle", :uncle],
            ["Sister", :sister],
            ["Brother", :brother],
            ["Stepchild", :stepchild],
            ["Stepbrother", :stepbrother],
            ["Stepsister", :stepsister],
            ["Half brother", :half_brother],
            ["Half sister", :half_sister],
            ["Grandparent", :grandparent],
            ["Great-grandchild", :great_grandchild],
            ["Step parent", :step_parent],
            ["In law", :in_law],
            ["Other descendants of my siblings", :siblings_descendant],
            ["Other relationship not listed", :other],
            ["Other: My adopted son", "My adopted son"]
          ]
        )
      end
    end
  end

  describe "#translated_relationship" do
    context "with matching relationship from translation list (valet form)" do
      it "responds with the translated value" do
        expect(helper.translated_relationship(:aunt)).to eq "Aunt"
      end
    end

    context "with free response (GYR intake flow)" do
      it "responds with the free response value" do
        expect(helper.translated_relationship("my sister's son")).to eq "my sister's son"
      end
    end

    context "with nil (incomplete dependent)" do
      it "responds with nil" do
        expect(helper.translated_relationship(nil)).to eq nil
      end
    end
  end
end
