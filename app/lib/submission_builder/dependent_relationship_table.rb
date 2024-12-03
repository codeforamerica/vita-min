# frozen_string_literal: true
module SubmissionBuilder
  module DependentRelationshipTable
    # "direct file relationship" => "State XML relationship"
    DF_TO_STATE_XML_RELATIONSHIPS = {
      "biologicalChild" => "CHILD",
      "adoptedChild" => "CHILD",
      "stepChild" => "CHILD",
      "fosterChild" => "FOSTERCHILD",
      "grandChildOrOtherDescendentOfChild" => "GRANDCHILD",
      "childInLaw" => "CHILD",
      "sibling" => "SIBLING",
      "childOfSibling" => "NIECENEPHEW",
      "halfSibling" => "HALFSIBLING",
      "childOfHalfSibling" => "NIECENEPHEW",
      "stepSibling" => "STEPSIBLING",
      "childOfStepSibling" => "NIECENEPHEW",
      "otherDescendantOfSibling" => "NIECENEPHEW",
      "siblingInLaw" => "SIBLING",
      "parent" => "PARENT",
      "grandParent" => "GRANDPARENT",
      "otherAncestorOfParent" => "GRANDPARENT",
      "stepParent" => "PARENT",
      "parentInLaw" => "PARENT",
      "noneOfTheAbove" => "OTHER",
      "siblingOfParent" => "PARENTSIB",
      "otherDescendantOfHalfSibling" => "NIECENEPHEW",
      "otherDescendantOfStepSibling" => "NIECENEPHEW",
      "fosterParent" => "FOSTPARENT",
      "siblingsSpouse" => "SIBSPOUSE",
    }.freeze

    # returns the corresponding State XML relationship string for the
    # input Direct File relationship key
    def relationship_key(direct_file_relationship)
      DF_TO_STATE_XML_RELATIONSHIPS[direct_file_relationship]
    end
  end
end
