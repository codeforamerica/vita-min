module Hub
  class FaqCategoryForm < Form
    include FormAttributes
    attr_accessor :faq_category
    set_attributes_for(
      :faq_category,
      :position,
      :slug,
      :name_en,
      :name_es,
      :product_type
    )

    validates_presence_of :name_en
    validates_presence_of :position

    def initialize(faq_category, params = {})
      @faq_category = faq_category
      super(params)
    end

    def save
      attrs = attributes_for(:faq_category)
      attrs[:slug] = generate_slug(attrs)
      @faq_category.assign_attributes(attrs)

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

    private

    def generate_slug(attrs)
      return attrs[:slug] if attrs[:slug].present? && slug_unique?(attrs[:slug])

      generated_slug = name_en.parameterize(separator: '_') unless name_en.nil?
      return generated_slug if slug_unique?(generated_slug)

      "#{generated_slug}_#{@faq_category.id}"
    end

    def slug_unique?(generated_slug)
      return false if generated_slug.nil?

      FaqCategory.where(slug: generated_slug).where.not(id: @faq_category).empty?
    end
  end
end
