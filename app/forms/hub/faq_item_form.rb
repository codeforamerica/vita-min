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
      attrs = attributes_for(:faq_item)
      attrs[:slug] = generate_slug(attrs)
      @faq_item.assign_attributes(attrs)

      unless valid? & @faq_item.valid?
        @faq_item.errors.each { |error| self.errors.add(error.attribute, error.message) }
        return false
      end

      @faq_item.save
    end

    def self.from_record(record)
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(record, existing_attributes(record, attribute_keys))
    end

    def self.existing_attributes(model, attribute_keys)
      HashWithIndifferentAccess[(attribute_keys || []).map { |k| [k, model.send(k)] }]
    end

    private

    def generate_slug(attrs)
      return attrs[:slug] if attrs[:slug].present? && slug_unique?(attrs, attrs[:slug])

      generated_slug = question_en.parameterize(separator: '_') unless question_en.nil?
      return generated_slug if slug_unique?(attrs, generated_slug)

      "#{generated_slug}_#{@faq_item.id}"
    end

    def slug_unique?(attrs, generated_slug)
      return false if generated_slug.nil?

      FaqItem.where(slug: generated_slug, faq_category_id: attrs[:faq_category_id])
             .where.not(id: @faq_item).empty?
    end
  end
end
