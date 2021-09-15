class FlowsController < ApplicationController
  FLOW_CONFIG = {
    gyr: { emoji: "💵", name: "GetYourRefund Flow" },
    ctc: { emoji: "👶", name: "CTC Flow" },
  }
  SAMPLE_GENERATOR_TYPES = {
    ctc: [:single, :married_filing_jointly, :married_filing_jointly_with_dependents],
  }.freeze

  def index
    @page_title = 'GetYourRefund Flows'
    @flow_config = FLOW_CONFIG
  end

  def generate
    unless FLOW_CONFIG.keys.map(&:to_s).include?(params[:type])
      raise ActionController::RoutingError.new('Not Found')
    end

    type = params[:type].to_sym
    if type == :ctc
      intake = SampleCtcIntakeGenerator.new.generate_ctc_intake(params)
      sign_in(intake.client)

      redirect_to flow_path(id: :ctc)
    end
  end

  def show
    unless FLOW_CONFIG.keys.map(&:to_s).include?(params[:id])
      raise ActionController::RoutingError.new('Not Found')
    end

    if params[:id] == 'ctc' && !Rails.application.config.ctc_domains.values.include?(request.host)
      return redirect_to flow_url(id: :ctc, host: Rails.application.config.ctc_domains[Rails.env.to_sym])
    end

    type = params[:id].to_sym
    @page_title = "#{FLOW_CONFIG[type][:emoji]} #{FLOW_CONFIG[type][:name]}"
    @sample_types = SAMPLE_GENERATOR_TYPES[type]
    @flow_params = FlowParams.for(type, self)
    respond_to do |format|
      format.html { render layout: 'flow_explorer' }
      format.js
    end
  end

  private

  def screenshot_path(controller)
    screenshot_filename = "#{controller.name}.png"
    if Rails.env.development? && File.exist?(Rails.root.join('public', 'assets', 'flow_screenshots', I18n.locale.to_s, screenshot_filename))
      "/assets/flow_screenshots/#{I18n.locale}/#{screenshot_filename}"
    else
      "https://vita-min-flow-explorer-screenshots.s3.us-west-1.amazonaws.com/#{I18n.locale}/#{screenshot_filename}"
    end
  end
  helper_method :screenshot_path

  class FlowParams
    attr_reader :reference_object
    attr_reader :controllers
    attr_reader :form

    def self.for(type, controller)
      if type == :gyr
        FlowParams.new(
          controller: controller,
          reference_object: controller.current_intake&.is_a?(Intake::GyrIntake) ? controller.current_intake : nil,
          controller_list: QuestionNavigation::FLOW
        )
      elsif type == :ctc
        FlowParams.new(
          controller: controller,
          reference_object: controller.current_intake&.is_a?(Intake::CtcIntake) ? controller.current_intake : nil,
          controller_list: CtcQuestionNavigation::FLOW,
          form: SampleCtcIntakeGenerator.new.form
        )
      end
    end

    def initialize(controller:, reference_object:, controller_list:, form: nil)
      @reference_object = reference_object
      @controllers = DecoratedControllerList.new(
        controller_list,
        controller,
        @reference_object
      )
      @form = form
    end

    def pretty_reference_object
      parts = [@reference_object.class.name, "##{@reference_object.id}", "(name: #{@reference_object.preferred_name})"]
      parts.join(' ')
    end

    def title_i18n_params
      { count: 1 }
    end
  end

  class DecoratedControllerList
    def initialize(controller_list, current_controller, reference_object)
      @controllers = controller_list
      @current_controller = current_controller
      @reference_object = reference_object
    end

    def decorated
      @controllers.map do |controller_class|
        DecoratedController.new(controller_class, @current_controller)
      end
    end

    class DecoratedController < Delegator
      def initialize(controller_class, current_controller)
        @controller_class = controller_class
        @current_controller = current_controller
      end

      def __getobj__
        @controller_class
      end

      def controller_url
        @controller_url ||= begin
          url_params = {
            controller: controller_path,
            action: navigation_entry_action,
            _recall: {},
          }.merge(navigation_entry_params(@current_controller))
          if controller_path.start_with?('ctc') && Rails.application.config.ctc_domains[Rails.env.to_sym].present?
            url_params[:host] = Rails.application.config.ctc_domains[Rails.env.to_sym]
          else
            url_params[:only_path] = true
          end
          if respond_to?(:resource_name) && resource_name.present?
            url_params[:id] = "fake-#{resource_name}-id"
          end
          @current_controller.url_for(url_params)
        end
      end

      def navigation_entry_action
        :edit
      end

      def navigation_entry_params(_)
        {}
      end

      def navigation_entry_action_title(i18n_params = {})
        possible_paths = %W(
          #{i18n_base_path}.title
          #{i18n_base_path}.title_html
          #{i18n_base_path}.page_title
        )

        existing_path = possible_paths.find { |path| I18n.exists?(path) }
        if existing_path
          begin
            I18n.t(existing_path, i18n_params)
          rescue I18n::MissingInterpolationArgument => e
            e.string
          end
        else
          if controller_path.start_with?('ctc') && !deprecated_controller?
            raise "Could not find title for: #{controller_path}"
          else
            controller_name.titleize.singularize
          end
        end
      end

      def unreachable?(current_controller)
        !show?(model_for_show_check(current_controller))
      end
    end
  end

  class SampleCtcIntakeForm
    include ActiveModel::Model

    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :sms_phone_number
    attr_accessor :email_address

    def initialize(first_name:, last_name:, sms_phone_number:, email_address:)
      @first_name = first_name
      @last_name = last_name
      @sms_phone_number = sms_phone_number
      @email_address = email_address
    end
  end

  class SampleCtcIntakeGenerator
    def form
      SampleCtcIntakeForm.new(
        first_name: 'Testuser',
        last_name: 'Testuser',
        sms_phone_number: nil,
        email_address: 'testuser@example.com',
      )
    end

    def generate_ctc_intake(params)
      type = params.keys.find { |k| k.start_with?('submit_') }&.sub('submit_', '')&.to_sym
      first_name = params[:flows_controller_sample_ctc_intake_form][:first_name]
      last_name = params[:flows_controller_sample_ctc_intake_form][:last_name]
      sms_phone_number = params[:flows_controller_sample_ctc_intake_form][:sms_phone_number]
      email_address = params[:flows_controller_sample_ctc_intake_form][:email_address]

      intake_attributes = {
        type: Intake::CtcIntake.to_s,
        visitor_id: SecureRandom.hex(26),
        filed_2020: 'no',
        filed_2019: 'did_not_file',
        primary_birth_date: 30.years.ago,
        primary_tin_type: 'ssn',
        primary_ssn: '555112222',
        primary_last_four_ssn: '2222',
        primary_first_name: first_name,
        primary_last_name: last_name,
        sms_phone_number: sms_phone_number.presence,
        email_address: email_address.presence,
        email_address_verified_at: (email_address.present? && email_address.end_with?('@example.com')) ? DateTime.now : nil,
        eip1_amount_received: 0,
        eip2_amount_received: 0,
        street_address: '123 Main St',
        city: 'Los Angeles',
        state: 'CA',
        zip_code: '90210',
      }
      client = Client.create!(
        intake_attributes: intake_attributes,
        efile_security_informations_attributes: [{
          ip_address: '127.0.0.1',
          device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
          user_agent: "GeckoFox",
          browser_language: "en-US",
          platform: "iPad",
          timezone_offset: "+240",
          client_system_time: "2021-07-28T21:21:32.306Z"
        }],
        tax_returns_attributes: [{ year: 2020, is_ctc: true, filing_status: 'single' }],
      )

      if type == :married_filing_jointly || type == :married_filing_jointly_with_dependents
        client.intake.tax_returns.last.update(filing_status: 'married_filing_jointly')
        client.intake.update(
          spouse_tin_type: 'ssn',
          spouse_birth_date: 31.years.ago + 51.days,
          spouse_ssn: '555113333',
          spouse_last_four_ssn: '3333',
          spouse_first_name: "#{first_name}Spouse",
          spouse_last_name: last_name,
          spouse_active_armed_forces: 'no'
        )
      end

      if type == :married_filing_jointly_with_dependents
        client.intake.update(
          had_dependents: 'yes'
        )
        client.intake.dependents.create(
          first_name: 'Childy',
          last_name: last_name,
          relationship: %w[son daughter].sample,
          provided_over_half_own_support: 'no',
          filed_joint_return: 'no',
          lived_with_more_than_six_months: 'yes',
          cant_be_claimed_by_other: 'yes',
          birth_date: 12.years.ago,
          tin_type: 'ssn',
          ssn: '555114444'
        )
        client.intake.dependents.create(
          first_name: 'Relly',
          last_name: last_name,
          relationship: %w[aunt uncle].sample,
          permanently_totally_disabled: 'yes',
          meets_misc_qualifying_relative_requirements: 'yes',
          birth_date: 52.years.ago,
          tin_type: 'ssn',
          ssn: '555115555'
        )
      end

      client.intake
    end
  end
end
