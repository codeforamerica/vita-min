module SubmissionBuilder
  module Ty2021
    class Return1040 < SubmissionBuilder::Composite1040Builder
      def attached_documents
        %w[
          SubmissionBuilder::Ty2021::LapsedFilerIrs1040
          SubmissionBuilder::Ty2021::Form8812
        ]
      end
    end
  end
end