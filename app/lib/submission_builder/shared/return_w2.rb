module SubmissionBuilder
  module Shared
    class ReturnW2 < SubmissionBuilder::Document

      def document
        w2 = @kwargs[:w2]
        build_xml_doc("IRSW2", documentId: "IRSW2-#{w2.id}") do |xml|
          xml.IRSW2 w2
        end
      end
    end
  end
end
