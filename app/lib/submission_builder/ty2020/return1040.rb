module SubmissionBuilder
  module Ty2020
    class Return1040 < SubmissionBuilder::Shared::Return1040
      def attached_documents
        %w[
            SubmissionBuilder::Ty2020::Documents::Irs1040
          ]
      end
    end
  end
end