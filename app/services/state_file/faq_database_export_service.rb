class StateFile::FaqDatabaseExportService
  AZ_QUESTIONS = {
    who_can_use_this_tool: [
      :in_order_to_file,
      :uncommon_situations_that_would_disqualify_you
    ],
    az_supported_credits_and_deductions: [
      :fyst_help,
      :irs_help
    ],
    unsupported_credits_and_deductions: [
      :not_supported,
      :additionally
    ],
    other_state_filing_options: [
      :options
    ]
  }.freeze

  NY_QUESTIONS = {
    who_can_use_this_tool: [
      :in_order_to_file,
      :uncommon_situations_that_would_disqualify_you
    ],
    ny_supported_credits_and_deductions: [
      :fyst_help,
      :irs_help
    ],
    unsupported_credits_and_deductions: [
      :not_supported,
      :additionally
    ],
    other_state_filing_options: [
      :options
    ]
  }.freeze

  def self.export_yml_to_database
    en_yml = YAML.load_file(Rails.root.join('app', 'services', "state_file", 'faq_database_export_en.yml'))['question_groups']
    es_yml = YAML.load_file(Rails.root.join('app', 'services', "state_file", 'faq_database_export_es.yml'))['question_groups']

    create_faqs_from_yml('az', en_yml, es_yml, AZ_QUESTIONS)
    create_faqs_from_yml('ny', en_yml, es_yml, NY_QUESTIONS)
  end

  private

  def self.create_faqs_from_yml(state, en_yml, es_yml, questions)
    category_position = 0
    product_type = state == 'az' ? :state_file_az : :state_file_ny

    questions.each do |section, questions|
      category_position += 1

      faq_category = FaqCategory.find_or_initialize_by(
        slug: section,
        product_type: product_type
      )

      faq_category.update(
        name_en: en_yml[state][section.to_s]['title'],
        name_es: es_yml[state][section.to_s]['title'],
        position: category_position
      )

      if en_yml[state][section.to_s]['description_html'].present?
        faq_category.update(description_en: en_yml[state][section.to_s]['description_html'],
                            description_es: es_yml[state][section.to_s]['description_html'])
      end

      question_position = 0
      questions.each do |question|
        question_position += 1
        faq_item = FaqItem.find_or_initialize_by(
          faq_category: faq_category,
          slug: question,
        )
        faq_item.update(
          position: question_position,
          question_en: en_yml[state][section.to_s][question.to_s]['question'],
          question_es: es_yml[state][section.to_s][question.to_s]['question'],
          answer_en: en_yml[state][section.to_s][question.to_s]['answer_html'],
          answer_es: es_yml[state][section.to_s][question.to_s]['answer_html'],
        )
      end
    end
  end
end