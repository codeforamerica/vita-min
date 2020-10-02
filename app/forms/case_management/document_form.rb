module CaseManagement
  class DocumentForm < Form
    include FormAttributes
    set_attributes_for :document, :display_name
    validates :display_name, presence: true, allow_blank: false

    def initialize(document, params = {})
      @document = document
      super(params)
    end

    def save
      @document.update(attributes_for(:document))
    end
  end
end