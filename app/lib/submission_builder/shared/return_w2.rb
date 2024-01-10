module SubmissionBuilder
  module Shared
    class ReturnW2 < SubmissionBuilder::Document

      def document
        w2 = @kwargs[:w2]
        Nokogiri::XML(w2.node.to_xml)
      end
    end
  end
end
