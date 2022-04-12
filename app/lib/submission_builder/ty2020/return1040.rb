module SubmissionBuilder
  module Ty2020
    class Return1040 < SubmissionBuilder::Shared::Return1040
      def self.attached_documents
        [SubmissionBuilder::Ty2020::Documents::Irs1040]
      end
    end
  end
end