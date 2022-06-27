require "rails_helper"

describe RelationshipsHelper do
  let(:default_relationship_options) do
    [
      ["Daughter", "daughter"],
      ["Son", "son"],
      ["Parent", "parent"],
      ["Grandchild", "grandchild"],
      ["Niece", "niece"],
      ["Nephew", "nephew"],
      ["Foster Child", "foster_child"],
      ["Aunt", "aunt"],
      ["Uncle", "uncle"],
      ["Sister", "sister"],
      ["Brother", "brother"],
      ["Stepchild", "stepchild"],
      ["Stepbrother", "stepbrother"],
      ["Stepsister", "stepsister"],
      ["Half brother", "half_brother"],
      ["Half sister", "half_sister"],
      ["Grandparent", "grandparent"],
      ["Great-grandchild", "great_grandchild"],
      ["Step parent", "step_parent"],
      ["In law", "in_law"],
      # ["Other descendants of my siblings", "siblings_descendant"],
      ["Other relationship not listed", "other"]
    ]
  end

  describe '#dependent_relationship_options' do
    it 'provides the correct options' do
      expect(helper.dependent_relationship_options).to eq(default_relationship_options)
    end

    context "with freeform entry" do
      it "provides the original freeform entry as an option" do
        expect(helper.dependent_relationship_options(current_relationship: "My adopted son")).to(
          eq(default_relationship_options + [["Other: My adopted son", "My adopted son"]]))
      end
    end

    context "with a relationship from the default list" do
      it "does not register as free form label" do
        expect(helper.dependent_relationship_options(current_relationship: "son")).to eq(default_relationship_options)
      end
    end
  end

  describe "#relationship_label" do
    context "with matching relationship from translation list (valet form)" do
      it "responds with the translated value" do
        expect(helper.relationship_label("aunt")).to eq "Aunt"
      end
    end

    context "with free response (GYR intake flow)" do
      it "responds with the free response value" do
        expect(helper.relationship_label("my sister's son")).to eq "my sister's son"
      end
    end

    context "with nil (incomplete dependent)" do
      it "responds with nil" do
        expect(helper.relationship_label(nil)).to eq nil
      end
    end
  end
end
