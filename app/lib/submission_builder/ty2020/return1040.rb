module SubmissionBuilder
  module Ty2020
    class Return1040 < SubmissionBuilder::Composite1040Builder
      def attached_documents
        %w[
            SubmissionBuilder::Ty2020::AdvCtcIrs1040
          ]
      end
    end
  end
end