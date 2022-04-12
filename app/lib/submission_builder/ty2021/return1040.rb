module SubmissionBuilder
  module TY2021
    class Return1040 < SubmissionBuilder::Composite1040Builder
      def attached_documents
        %w[
          SubmissionBuilder::TY2021::LapsedFilerIrs1040
          SubmissionBuilder::TY2021::Form8812
        ]
      end
    end
  end
end