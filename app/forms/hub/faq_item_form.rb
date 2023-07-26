module Hub
  class FaqItemForm < Form
    include FormAttributes
    attr_accessor :faq_item
    set_attributes_for(
      :faq_item,
      :position,
      :slug,
      :question_en,
      :question_es,
      :answer_en,
      :answer_es,
      :faq_category_id
    )

    validates_presence_of :question_en
    validates_presence_of :position

    def initialize(faq_item, params = {})
      @faq_item = faq_item
      super(params)
    end

    def save
      attributes = attributes_for(:faq_item)
      attributes[:slug] = question_en.parameterize(separator: '_') unless attributes[:slug].present? || question_en.nil?
      @faq_item.assign_attributes(attributes)

      unless valid? & @faq_item.valid?
        @faq_item.errors.each { |error| self.errors.add(error.attribute, error.message) }
        return false
      end

      @faq_item.save
    end

    def self.from_record(record)
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(record, existing_attributes(record).slice(*attribute_keys))
    end

  end
end
