module SubmissionBuilder
  module Ty2021
    class Return1040 < SubmissionBuilder::Shared::Return1040
      def attached_documents
        return @attached_documents unless @attached_documents.nil?

        @attached_documents = [SubmissionBuilder::Ty2021::Documents::Irs1040]
        @attached_documents.push(SubmissionBuilder::Ty2021::Documents::Schedule8812) if @submission.has_outstanding_ctc?
        @attached_documents.push(SubmissionBuilder::Ty2021::Documents::ScheduleLep) if @submission.intake.irs_language_preference.present?

        @attached_documents
      end
    end
  end
end