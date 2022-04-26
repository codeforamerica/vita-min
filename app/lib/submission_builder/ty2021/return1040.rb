module SubmissionBuilder
  module Ty2021
    class Return1040 < SubmissionBuilder::Shared::Return1040
      def attached_documents
        @attached_documents ||= if @submission.has_outstanding_ctc?
                                  [
                                    SubmissionBuilder::Ty2021::Documents::Irs1040,
                                    SubmissionBuilder::Ty2021::Documents::Schedule8812
                                  ]
                                else
                                  [
                                    SubmissionBuilder::Ty2021::Documents::Irs1040
                                  ]
                                end
      end
    end
  end
end