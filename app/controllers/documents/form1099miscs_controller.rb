module Documents
  class Form1099miscsController < DocumentUploadQuestionController
    def self.show?(intake)
      # Retaining this controller for approx 1 day, so that if someone is on
      # this URL, they are able to use it successfully.
      false
    end

    def self.document_type
      "1099-MISC"
    end
  end
end
