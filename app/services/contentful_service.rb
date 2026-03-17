class ContentfulService
  def self.client(preview: false)
    environment = ENV['CONTENTFUL_ENVIRONMENT'] || 'master'

    if preview
      ::Contentful::Client.new(
        space: Rails.application.credentials.dig(:contentful, :space_id),
        access_token: Rails.application.credentials.dig(:contentful, :preview_access_token),
        api_url: 'preview.contentful.com',
        environment: environment
      )
    else
      ::Contentful::Client.new(
        space: Rails.application.credentials.dig(:contentful, :space_id),
        access_token: Rails.application.credentials.dig(:contentful, :delivery_access_token),
        environment: environment
      )
    end
  end

  LOCALE_MAP = {
    'en' => 'en-US',
    'es' => 'es'
  }.freeze

  def self.contentful_locale
    LOCALE_MAP[I18n.locale.to_s] || 'en-US'
  end

  def self.interpolate(template, vars)
    template.gsub(/\{(\w+)\}/) { vars[$1.to_sym] || vars[$1] || '' }
  end

  def self.faq_categories
    Rails.cache.fetch("contentful_faq_categories_#{contentful_locale}", expires_in: 1.hour) do
      client.entries(content_type: 'faqCategory', order: 'fields.order', locale: contentful_locale).to_a
    end
  end

  def self.faq_category_by_slug(slug)
    Rails.cache.fetch("contentful_faq_category_#{slug}_#{contentful_locale}", expires_in: 1.hour) do
      client.entries(content_type: 'faqCategory', 'fields.slug' => slug, locale: contentful_locale).first
    end
  end

  def self.faq_items(search: nil, category_id: nil)
    cache_key = "contentful_faq_items_#{search}_#{category_id}_#{contentful_locale}"
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      query = { content_type: 'faqItem', include: 2, locale: contentful_locale, order: 'fields.order' }
      query['fields.faqCategory.sys.id'] = category_id if category_id
      query['query'] = search if search.present?
      client.entries(query).to_a
    end
  end

  def self.faq_item_by_slug(section_slug:, question_slug:)
    cache_key = "contentful_faq_item_#{section_slug}_#{question_slug}_#{contentful_locale}"
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      category = faq_category_by_slug(section_slug)
      return nil unless category

      client.entries(
        content_type: 'faqItem',
        'fields.slug' => question_slug,
        'fields.faqCategory.sys.id' => category.id,
        include: 2,
        locale: contentful_locale
      ).first
    end
  end

  def self.flow_page_content(page_key)
    Rails.cache.fetch("contentful_flow_page_#{page_key}_#{contentful_locale}", expires_in: 1.minute) do
      client.entries(content_type: 'flowPage', 'fields.pageKey' => page_key, locale: contentful_locale).first
    end
  end
end