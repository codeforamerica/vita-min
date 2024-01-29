# frozen_string_literal: true
module SubmissionBuilder
  module Ty2023
    module States
      module Az
        module DependentRelationshipTable
          # "direct file relationship" => "AZ XML relationship"
          DF_TO_AZ_XML_RELATIONSHIPS = {
            "DAUGHTER" => "CHILD",
            "STEPCHILD" => "CHILD",
            "FOSTER CHILD" => "FOSTERCHILD",
            "GRANDCHILD" => "GRANDCHILD",
            "SISTER" => "SIBLING",
            "NEPHEW" => "NIECENEPHEW",
            "HALF SISTER" => "HALFSIBLING",
            "STEPBROTHER" => "STEPSIBLING",
            "GRANDPARENT" => "GRANDPARENT",
            "PARENT" => "PARENT",
            "NONE" => "OTHER"
          }.freeze

          # returns the corresponding AZ XML relationship string for the
          # input Direct File relationship key
          def relationship_key(direct_file_relationship)
            DF_TO_AZ_XML_RELATIONSHIPS[direct_file_relationship]
          end
        end
      end
    end
  end
end