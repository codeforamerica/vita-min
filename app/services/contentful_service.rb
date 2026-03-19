class ContentfulService
  def self.client(preview: false)
    environment = Rails.configuration.contentful_environment || 'master'

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

  def self.env
    Rails.configuration.contentful_environment || 'master'
  end

  def self.cache_key(*parts, preview: false)
    mode = preview ? "preview" : "delivery"
    ["contentful", mode, env, *parts, contentful_locale].compact.join(":")
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

  def self.faq_categories(preview: false)
    Rails.cache.fetch(cache_key("faq_categories", preview: preview), expires_in: 1.hour) do
      client(preview: preview).entries(
        content_type: 'faqCategory',
        order: 'fields.order',
        locale: contentful_locale
      ).to_a
    end
  end

  def self.faq_category_by_slug(slug, preview: false)
    Rails.cache.fetch(cache_key("faq_category", slug, preview: preview), expires_in: 1.hour) do
      client(preview: preview).entries(
        content_type: 'faqCategory',
        'fields.slug' => slug,
        locale: contentful_locale
      ).first
    end
  end

  def self.faq_items(search: nil, category_id: nil, preview: false)
    Rails.cache.fetch(cache_key("faq_items", search, category_id, preview: preview), expires_in: 1.hour) do
      query = {
        content_type: 'faqItem',
        include: 2,
        locale: contentful_locale,
        order: 'fields.order'
      }
      query['fields.faqCategory.sys.id'] = category_id if category_id
      query['query'] = search if search.present?

      client(preview: preview).entries(query).to_a
    end
  end

  def self.faq_item_by_slug(section_slug:, question_slug:, preview: false)
    Rails.cache.fetch(cache_key("faq_item", section_slug, question_slug, preview: preview), expires_in: 1.hour) do
      category = faq_category_by_slug(section_slug, preview: preview)
      return nil unless category

      client(preview: preview).entries(
        content_type: 'faqItem',
        'fields.slug' => question_slug,
        'fields.faqCategory.sys.id' => category.id,
        include: 2,
        locale: contentful_locale
      ).first
    end
  end

  def self.review_box(flow_page, preview: false)
    Rails.cache.fetch(cache_key("review_box", flow_page, preview: preview), expires_in: 1.hour) do
      client(preview: preview).entries(
        content_type: 'reviewBox',
        'fields.flowPage' => flow_page,
        locale: contentful_locale
      ).first
    end
  end

  def self.flow_page_content(page_key, preview: false)
    Rails.cache.fetch(cache_key("flow_page", page_key, preview: preview), expires_in: 1.minute) do
      client(preview: preview).entries(
        content_type: 'flowPage',
        'fields.pageKey' => page_key,
        locale: contentful_locale
      ).first
    end
  end
end