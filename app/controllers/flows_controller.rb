class FlowsController < ApplicationController
  FLOW_CONFIGS = {
    gyr: { emoji: "💵", name: "GetYourRefund Flow", host: :gyr },
    diy: { emoji: "📝", name: "DIY Flow", host: :gyr },
    state_file_az: { emoji: "🌵", name: "State File - Arizona", host: :statefile },
    state_file_ny: { emoji: "🍎", name: "State File - New York", host: :statefile },
  }
  SAMPLE_GENERATOR_TYPES = {
    ctc: [:single, :married_filing_jointly],
    gyr: [:single, :married_filing_jointly],
    state_file_az: [:single, :married_filing_jointly, :qualifying_widow, :married_filing_separately, :head_of_household],
    state_file_ny: [:head_of_household],
  }.freeze

  def index
    @page_title = 'GetYourRefund Flows'
    @flow_configs = FLOW_CONFIGS
  end

  def generate
    unless FLOW_CONFIGS.keys.map(&:to_s).include?(params[:type])
      raise ActionController::RoutingError.new('Not Found')
    end

    type = params[:type].to_sym
    intake = nil
    if type == :gyr
      intake = SampleGyrIntakeGenerator.new.generate_gyr_intake(params)
    elsif type == :state_file_az
      intake = SampleStateFileIntakeGenerator.new('az').generate_state_file_intake(params)
    elsif type == :state_file_ny
      intake = SampleStateFileIntakeGenerator.new('ny').generate_state_file_intake(params)
    end

    if intake
      if intake.respond_to?(:client)
        sign_in(intake.client)
      elsif [:state_file_az, :state_file_ny].include?(type)
        intake.create_state_file_analytics!
        sign_in intake
      end
    else
      flash[:alert] = "Unable to create intake, maybe your name or email or phone number was bad?"
    end

    redirect_to flow_path(id: type)
  end

  def show
    flow_config = FLOW_CONFIGS[params[:id].to_sym]
    raise ActionController::RoutingError.new('Not Found') if flow_config.nil?

    on_canonical_host = request.host == MultiTenantService.new(flow_config[:host]).host
    unless on_canonical_host
      return redirect_to(flow_url(id: params[:id], host: MultiTenantService.new(flow_config[:host]).host), allow_other_host: true)
    end

    type = params[:id].to_sym
    @page_title = "#{flow_config[:emoji]} #{flow_config[:name]}"

    @sample_types = SAMPLE_GENERATOR_TYPES[type]
    @flow_params = FlowParams.for(type, self)
    respond_to do |format|
      format.html { render layout: 'flow_explorer' }
      format.js
    end
  end

  def current_intake
    if %w[state_file_az state_file_ny].include?(params[:id] || params[:type])
      send("current_#{params[:id] || params[:type]}_intake")
    else
      super
    end
  end

  private

  class FlowParams
    attr_reader :reference_object
    attr_reader :controllers
    attr_reader :form

    def self.for(type, controller)
      case type
      when :gyr
        gyr_flow = Navigation::GyrQuestionNavigation::FLOW.dup

        last_page_before_docs_index = gyr_flow.index(Questions::MailingAddressController)
        gyr_flow.insert(last_page_before_docs_index + 1, *Navigation::DocumentNavigation::FLOW)

        FlowParams.new(
          controller: controller,
          reference_object: controller.current_intake&.is_a?(Intake::GyrIntake) ? controller.current_intake : nil,
          controller_list: gyr_flow,
          form: SampleGyrIntakeGenerator.new.form
        )
      when :diy
        FlowParams.new(
          controller: controller,
          reference_object: nil,
          controller_list: Navigation::DiyNavigation::FLOW,
          form: nil
        )
      else
        if type.to_s.starts_with?('state_file_')
          state_code = type.to_s.split('_').last
          intake_class = StateFile::StateInformationService.intake_class(state_code)
          FlowParams.new(
            controller: controller,
            reference_object: controller.current_intake&.is_a?(intake_class) ? controller.current_intake : nil,
            controller_list: StateFile::StateInformationService.navigation_class(state_code).controllers,
            form: SampleStateFileIntakeGenerator.new(state_code).form
          )
        end
      end
    end

    def initialize(controller:, reference_object:, controller_list:, form:)
      @reference_object = reference_object
      @controllers = DecoratedControllerList.new(
        controller_list,
        controller,
        @reference_object
      )
      @form = form
    end

    def pretty_reference_object
      parts = [@reference_object.class.name, "##{@reference_object.id}"]
      parts << "(name: #{@reference_object.preferred_name})" if @reference_object.respond_to?(:preferred_name)
      parts.join(' ')
    end

    def title_i18n_params
      { count: 1 }
    end
  end

  class DecoratedControllerList
    def initialize(controller_list, current_controller, reference_object)
      @controllers = controller_list.reject { |c| c.deprecated_controller? }
      @current_controller = current_controller
      @reference_object = reference_object
    end

    def controller_actions
      @controllers.map do |controller_class|
        controller_class.navigation_actions.map do |controller_action|
          DecoratedController.new(controller_class, controller_action, @current_controller, @reference_object)
        end
      end.flatten
    end

    class DecoratedController < Delegator
      def initialize(controller_class, controller_action, current_controller, reference_object)
        @controller_class = controller_class
        @controller_action = controller_action
        @current_controller = current_controller
        @reference_object = reference_object
      end

      def __getobj__
        @controller_class
      end

      def screenshot_filename
        if @controller_action == :edit
          "#{@controller_class}.png"
        else
          "#{@controller_class}-#{@controller_action}.png"
        end
      end

      def pretty_name
        if @controller_action == :edit
          @controller_class.to_s
        else
          "#{@controller_class}##{@controller_action}"
        end
      end

      def screenshot_path
        if Rails.env.development? && File.exist?(Rails.root.join('public', 'assets', 'flow_screenshots', I18n.locale.to_s, screenshot_filename))
          "/assets/flow_screenshots/#{I18n.locale}/#{screenshot_filename}"
        else
          "https://vita-min-flow-explorer-screenshots.s3.us-west-1.amazonaws.com/#{I18n.locale}/#{screenshot_filename}"
        end
      end

      def controller_url
        @controller_url ||= begin
          url_params = {
            controller: controller_path,
            action: @controller_action,
            _recall: {},
          }.merge(navigation_entry_params(@current_controller))
          if controller_path.start_with?('ctc') && MultiTenantService.new(:ctc).host.present?
            url_params[:host] = MultiTenantService.new(:ctc).host
          else
            url_params[:only_path] = true
          end
          if respond_to?(:resource_name) && resource_name.present?
            url_params[:id] = "fake-#{resource_name}-id"
          end
          @current_controller.url_for(url_params)
        end
      end

      def navigation_entry_params(_)
        {}
      end

      def page_title(i18n_params = {})
        possible_paths = %W(
          #{i18n_base_path}.title
          #{i18n_base_path}.title_html
          #{i18n_base_path}.page_title
          #{i18n_base_path}.#{@controller_action}.title
        )

        existing_path = possible_paths.find { |path| I18n.exists?(path) }
        if existing_path
          begin
            I18n.t(existing_path, **i18n_params)
          rescue I18n::MissingInterpolationArgument => e
            e.string
          end
        else
          if controller_path.start_with?('ctc')
            raise "Could not find title for: #{controller_path}"
          else
            controller_name.titleize.singularize
          end
        end
      end

      def unreachable?(current_controller)
        if @controller_class.method(:show?).arity > 1
          !show?(
            model_for_show_check(current_controller),
            current_controller
          )
        else
          !show?(
            model_for_show_check(current_controller)
          )
        end
      end
    end
  end

  class SampleIntakeForm
    include ActiveModel::Model

    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :sms_phone_number
    attr_accessor :email_address
    attr_accessor :claiming_eitc
    attr_accessor :with_dependents
    attr_accessor :submission_rejected
    attr_accessor :submission_accepted

    def initialize(first_name:, last_name:, sms_phone_number:, email_address:, claiming_eitc: nil, with_dependents: nil, submission_rejected: nil, submission_accepted: nil)
      @first_name = first_name
      @last_name = last_name
      @sms_phone_number = sms_phone_number
      @email_address = email_address
      @claiming_eitc = claiming_eitc
      @with_dependents = with_dependents
      @submission_rejected = submission_rejected
      @submission_accepted = submission_accepted
    end
  end

  class SampleGyrIntakeGenerator
    def form
      SampleIntakeForm.new(
        first_name: 'Testuser',
        last_name: 'Testuser',
        sms_phone_number: nil,
        email_address: "testuser+#{Time.now.to_i.to_s(36)}@example.com",
      )
    end

    def generate_gyr_intake(params)
      form_params = params.require(:flows_controller_sample_intake_form).permit(:first_name, :last_name, :sms_phone_number, :email_address, :with_dependents)
      type = params.keys.find { |k| k.start_with?('submit_') }&.sub('submit_', '')&.to_sym
      first_name = form_params[:first_name]
      last_name = form_params[:last_name]
      sms_phone_number = PhoneParser.normalize(form_params[:sms_phone_number])
      email_address = form_params[:email_address]
      with_dependents = form_params[:with_dependents] == "1"

      intake_attributes = {
        type: Intake::GyrIntake.to_s,
        product_year: Rails.configuration.product_year,
        visitor_id: SecureRandom.hex(26),
        filed_prior_tax_year: 'did_not_file',
        primary_birth_date: 30.years.ago,
        primary_tin_type: 'ssn',
        primary_ssn: '555112222',
        primary_last_four_ssn: '2222',
        primary_first_name: first_name,
        primary_last_name: last_name,
        preferred_name: "#{first_name} #{last_name}",
        sms_phone_number: sms_phone_number.presence,
        email_address: email_address.presence,
        email_address_verified_at: (email_address.present? && email_address&.end_with?('@example.com')) ? DateTime.now : nil,
        eip1_amount_received: 0,
        eip2_amount_received: 0,
        street_address: '123 Main St',
        city: 'Los Angeles',
        state: 'CA',
        zip_code: '90210',
        filing_joint: 'no',
        current_step: Questions::MailingAddressController.to_path_helper
      }
      client = Client.create(
        consented_to_service_at: Time.zone.now,
        intake_attributes: intake_attributes,
        tax_returns_attributes: [{ year: MultiTenantService.new(:gyr).current_tax_year, is_ctc: false }],
      )
      unless client.valid?
        return
      end

      client.tax_returns.last.transition_to!(:intake_in_progress)

      if type == :married_filing_jointly
        client.intake.update(
          spouse_birth_date: 31.years.ago + 51.days,
          spouse_last_four_ssn: '3333',
          spouse_first_name: "#{first_name} Spouse",
          spouse_last_name: last_name,
          filing_joint: 'yes',
        )
      end

      if with_dependents
        client.intake.update(
          had_dependents: 'yes'
        )
        default_attributes = {
          months_in_home: 12,
          us_citizen: 'yes',
          was_married: 'no',
          was_student: 'no',
          north_american_resident: 'no',
          disabled: 'no',
        }
        client.intake.dependents.create(default_attributes.merge(
          first_name: 'Childy',
          last_name: last_name,
          relationship: %w[son daughter].sample,
          birth_date: 12.years.ago,
        ))
        client.intake.dependents.create(default_attributes.merge(
          first_name: 'Relly',
          last_name: last_name,
          relationship: %w[aunt uncle].sample,
          birth_date: 52.years.ago,
        ))
      end

      client.intake
    end
  end

  class SampleStateFileIntakeGenerator
    def initialize(us_state)
      @us_state = us_state
    end

    def form
      SampleIntakeForm.new(
        first_name: 'Testuser',
        last_name: 'Testuser',
        sms_phone_number: nil,
        email_address: "testuser+#{Time.now.to_i.to_s(36)}@example.com",
      )
    end

    def self.common_attributes
      {
        created_at: 1.minute.ago,
        updated_at: 1.minute.ago,
        visitor_id: SecureRandom.hex(26),
        referrer: "None",
        primary_esigned: "yes",
        primary_esigned_at: 1.minute.ago,
        spouse_esigned: "yes",
        spouse_esigned_at: 1.minute.ago,
        payment_or_deposit_type: "mail",
        account_type: 'unfilled',
        routing_number: '111111111',
        account_number: '2222222222',
        current_step: "/en/questions/confirmation",
        eligibility_lived_in_state: "yes",
        eligibility_out_of_state_income: "no",
        federal_submission_id: "12345202201011234570",
        federal_return_status: "accepted",
        consented_to_terms_and_conditions: "yes",
        current_sign_in_at: nil,
        current_sign_in_ip: nil,
        failed_attempts: 0,
        last_sign_in_at: nil,
        last_sign_in_ip: nil,
        sign_in_count: 0,
        df_data_import_succeeded_at: 30.seconds.ago,
        hashed_ssn: SsnHashingService.hash("555002222"), # hash PrimarySSN from raw_direct_file_data
        consented_to_sms_terms: "yes",
      }
    end

    def self.ny_attributes(first_name: 'Testuser', last_name: 'Testuser', filing_status: :single)
      common_attributes.merge(
        confirmed_permanent_address: "no",
        confirmed_third_party_designee: "unfilled",
        contact_preference: "text",
        eligibility_part_year_nyc_resident: "no",
        eligibility_withdrew_529: "no",
        eligibility_yonkers: "no",
        household_rent_own: "unfilled",
        nursing_home: "unfilled",
        nyc_residency: "none",
        nyc_maintained_home: "no",
        occupied_residence: "unfilled",
        permanent_apartment: "B",
        permanent_city: "New York",
        permanent_street: "321 Peanut Way",
        permanent_zip: "11102",
        email_address: "user@codeforamerica.org",
        email_address_verified_at: 1.minute.ago,
        primary_birth_date: Date.parse('1978-06-21'),
        primary_first_name: first_name,
        primary_last_name: last_name,
        property_over_limit: "unfilled",
        public_housing: "unfilled",
        raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.old_xml_sample,
        raw_direct_file_intake_data: StateFile::DirectFileApiResponseSampleService.new.old_json_sample,
        residence_county: "Nassau",
        sales_use_tax_calculation_method: "unfilled",
        school_district_id: 441,
        school_district: "Bellmore-Merrick CHS",
        school_district_number: 46,
        spouse_birth_date: Date.parse('1979-06-22'),
        spouse_first_name: "Taliesen",
        spouse_last_name: "Testerson",
        spouse_state_id_id: 2,
        untaxed_out_of_state_purchases: "no",
        permanent_address_outside_ny: "no",
        message_tracker: {},
        locale: 'en',
        unfinished_intake_ids: [],
        df_data_imported_at: 2.hours.ago,
        email_notification_opt_in: "yes",
        phone_number: "+15005550006",
        sms_notification_opt_in: "yes",
      )
    end

    def self.az_attributes(first_name: 'Testuser', last_name: 'Testuser', filing_status: :single)
      base_attributes = common_attributes.merge(
        armed_forces_member: "yes",
        armed_forces_wages_amount: 100,
        charitable_cash_amount: 123,
        charitable_contributions: "yes",
        charitable_noncash_amount: 123,
        contact_preference: "email",
        eligibility_529_for_non_qual_expense: "no",
        eligibility_married_filing_separately: "no",
        email_address: "someone@example.com",
        email_address_verified_at: 1.minute.ago,
        has_prior_last_names: "yes",
        primary_birth_date: Date.parse('1978-06-21'),
        primary_first_name: first_name,
        primary_last_name: last_name,
        prior_last_names: "Jordan, Pippen, Rodman",
        tribal_member: "yes",
        tribal_wages_amount: 100,
        primary_was_incarcerated: "no",
        spouse_was_incarcerated: "no",
        was_incarcerated: "no", # TODO: remove when column is ignored
        household_excise_credit_claimed: "no",
        message_tracker: {},
        locale: 'en',
        unfinished_intake_ids: [],
        raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.az_xml_sample(filing_status),
        raw_direct_file_intake_data: StateFile::DirectFileApiResponseSampleService.new.old_json_sample,
        df_data_imported_at: 2.hours.ago,
        email_notification_opt_in: "yes",
        phone_number: "+15005550006",
        sms_notification_opt_in: "yes",
        made_az322_contributions: "yes",
        extension_payments_amount: 0,
        paid_extension_payments: "no",
        paid_federal_extension_payments: "no",
      )
      status_specific_attributes = case filing_status
                                   when :married_filing_jointly, :married_filing_separately
                                     {
                                       spouse_first_name: "Spouse",
                                       spouse_last_name: last_name,
                                       spouse_birth_date: Date.parse('1979-06-22'),
                                       spouse_was_incarcerated: "no",
                                     }
                                   when :head_of_household
                                     {dependents_attributes: [{
                                                                first_name: "Dependent",
                                                                last_name: last_name,
                                                                relationship: "biologicalChild",
                                                                dob: Date.new(Date.today.year - 10),
                                                                months_in_home: 12,
                                                              }]}
                                   else
                                     {}
                                   end

      base_attributes.merge(status_specific_attributes)
    end

    def generate_efile_device_info(intake)
      StateFileEfileDeviceInfo.find_or_create_by!(
        event_type: "initial_creation",
        ip_address: "72.34.67.178",
        device_id: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        intake: intake
      )
      StateFileEfileDeviceInfo.find_or_create_by!(
        event_type: "submission",
        ip_address: "72.34.67.178",
        device_id: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        intake: intake
      )
    end

    def generate_state_file_intake(params)
      _type = params.keys.find { |k| k.start_with?('submit_') }&.sub('submit_', '')&.to_sym
      attributes = self.class.send("#{@us_state}_attributes",
        first_name: params[:flows_controller_sample_intake_form][:first_name],
        last_name: params[:flows_controller_sample_intake_form][:last_name],
                                   filing_status: _type
      )
      intake_class = StateFile::StateInformationService.intake_class(@us_state)
      intake = intake_class.create(attributes)

      generate_efile_device_info(intake)

      intake
    end
  end
end
