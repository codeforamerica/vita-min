module SubmissionBuilder
  module TY2020
    class Return1040 < SubmissionBuilder::Composite1040Builder
      def attached_documents
        %w[
            SubmissionBuilder::TY2020::AdvCtcIrs1040
          ]
      end
    end
  end
end