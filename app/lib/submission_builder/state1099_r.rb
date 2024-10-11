module SubmissionBuilder
  class State1099R < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods

    def document
      form1099r = @kwargs[:form1099r]

      build_xml_doc("IRS1099R", documentId: "IRS1099R-#{form1099r.id}") do |xml|
      end
    end
  end
end
