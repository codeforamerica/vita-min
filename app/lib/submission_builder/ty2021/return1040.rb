module SubmissionBuilder
  module Ty2021
    class Return1040 < SubmissionBuilder::Shared::Return1040
      def attached_documents
        @attached_documents ||= xml_documents
      end

      def xml_documents
        supported_documents.map { |item| item[:xml] if item[:include] }.compact
      end

      def pdf_documents
        supported_documents.map { |item| item[:pdf] if item[:include] }.compact
      end

      def supported_documents
        [
          {
            xml: SubmissionBuilder::Ty2021::Documents::Irs1040,
            pdf: Irs1040Pdf,
            include: true
          },
          {
            xml: SubmissionBuilder::Ty2021::Documents::Schedule8812,
            pdf: Irs8812Ty2021Pdf,
            include: @submission.has_outstanding_ctc?
          },
          {
            xml: SubmissionBuilder::Ty2021::Documents::ScheduleLep,
            pdf: Irs1040ScheduleLepPdf,
            include: @submission.intake.irs_language_preference.present?
          }
        ]
      end
    end
  end
end