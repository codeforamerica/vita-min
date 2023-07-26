module Hub
  class FaqCategoryForm < Form
    include FormAttributes
    attr_accessor :faq_category
    set_attributes_for(
      :faq_category,
      :position,
      :slug,
      :name_en,
      :name_es
    )

    validates_presence_of :name_en
    validates_presence_of :position

    def initialize(faq_category, params = {})
      @faq_category = faq_category
      super(params)
    end

    def save
      attributes = attributes_for(:faq_category)
      attributes[:slug] = name_en.parameterize(separator: '_') unless attributes[:slug].present? || name_en.nil?
      @faq_category.assign_attributes(attributes)

      unless valid? & @faq_category.valid?
        @faq_category.errors.each { |error| self.errors.add(error.attribute, error.message) }
        return false
      end

      @faq_category.save
    end

    def self.from_record(record)
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(record, existing_attributes(record).slice(*attribute_keys))
    end

  end
end
