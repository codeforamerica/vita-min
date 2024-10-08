module SubmissionBuilder
  module Ty2021
    class Return1040 < SubmissionBuilder::Return1040
      def attached_documents
        @attached_documents ||= xml_documents.map { |doc| { xml_class: doc.xml, kwargs: doc.kwargs } }
      end

      def xml_documents
        included_documents.map { |item| item if item.xml }.compact
      end

      def pdf_documents
        included_documents.map { |item| item if item.pdf }.compact
      end

      def included_documents
        supported_documents.map { |item| OpenStruct.new(**item, kwargs: item[:kwargs] || {}) if item[:include] }.compact
      end

      def supported_documents
        supported_docs = [
          {
            xml: SubmissionBuilder::Ty2021::Documents::Irs1040,
            pdf: PdfFiller::Irs1040Pdf,
            include: true
          },
          {
            xml: nil,
            pdf: PdfFiller::AdditionalDependentsPdf,
            include: @submission.qualifying_dependents.count > 4,
            kwargs: { start_node: 4 }
          },
          {
            xml: nil,
            pdf: PdfFiller::AdditionalDependentsPdf,
            include: @submission.qualifying_dependents.count > 26,
            kwargs: { start_node: 26 }
          },
          {
            xml: SubmissionBuilder::Ty2021::Documents::Schedule8812,
            pdf: PdfFiller::Irs8812Ty2021Pdf,
            include: @submission.benefits_eligibility.outstanding_ctc_amount.positive?
          },
          {
            xml: SubmissionBuilder::Ty2021::Documents::ScheduleEic,
            pdf: PdfFiller::Irs1040ScheduleEicPdf,
            include: @submission.benefits_eligibility.claiming_and_qualified_for_eitc? && @submission.qualifying_dependents.any?(&:qualifying_eitc?)
          },
          {
            xml: SubmissionBuilder::Ty2021::Documents::ScheduleLep,
            pdf: PdfFiller::Irs1040ScheduleLepPdf,
            include: @submission.intake.irs_language_preference.present? && @submission.intake.irs_language_preference != "english"
          },
        ]
        w2_docs = submission.intake.completed_w2s.map do |w2|
          {
            xml: SubmissionBuilder::Ty2021::Documents::IrsW2,
            pdf: nil,
            include: @submission.benefits_eligibility.claiming_and_qualified_for_eitc?,
            kwargs: { w2: w2 }
          }
        end
        supported_docs.push(*w2_docs)
      end
    end
  end
end
