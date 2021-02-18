require "singleton"

##
# a service object for communicating with Mixpanel, implemented
# as a Singleton.
#
# the singleton can be referenced using `MixpanelService.instance`
#
class MixpanelService
  include Singleton

  def initialize
    mixpanel_key = Rails.application.credentials.dig(:mixpanel_token)
    return if mixpanel_key.nil?

    @tracker = Mixpanel::Tracker.new(mixpanel_key)
    # silence local SSL errors
    if Rails.env.development?
      Mixpanel.config_http do |http|
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
  end

  ##
  # track an event, given an id, name, and the data to submit
  #
  # @param [String] unique_id: the id of the event
  # @param [String] event_name: name of the event, or event type
  # @param [Hash] data: (optional, defaults to {}) data to be sent to mixpanel
  #
  def run(unique_id:, event_name:, data: {})
    @tracker.track(unique_id, event_name, data)
  rescue StandardError => err
    Rails.logger.error "Error tracking analytics event #{err}"
  end

  ##
  # see MixpanelService.data_from(obj)
  #
  def data_from(obj)
    self.class.data_from(obj)
  end

  class << self
    ##
    # convenience method for stripping a list of substrings from a string
    #
    # @param [String] target the string to be strippped
    # @param [Enumerable(String)] exclusions list of strings to be removed from target
    #
    # @example
    #
    #   MixpanelService.strip_all_from('what a day', ['a', 'w'])
    #   # => 'ht  dy'
    def strip_all_from_string(target, exclusions)
      return unless target.present?

      exclusions.reduce(target) { |acc, ex| acc.gsub(ex.to_s, '') }
    end

    ##
    # convenience method for stripping a list of substrings from a url while
    # preserving its structure and query string structure
    #
    # @param [String] target the url to be strippped
    # @param [Enumerable(String)] exclusions list of strings to be removed from target
    #
    # @example
    #
    #   MixpanelService.strip_all_from('/this/dang/thing?query=remove-me', ['dang', 'remove-me'])
    #   # => '/this/***/thing?query=***'
    def strip_all_from_url(url, exclusions)
      exclusions = exclusions.map(&:to_s)
      return unless url.present?
      return url if exclusions.empty?

      path, querystring = url.split('?')
      path = path.split('/').map { |part| exclusions.include?(part) ? '***' : part }.join('/')

      if querystring.present?
        path << '?'
        path <<  querystring.split('&').map do |pair|
          k, v = pair.split('=')
          [(exclusions.include?(k) ? '***' : k), (exclusions.include?(v) ? '***' : v)].join('=')
        end.join('&')
      end
      path
    end

    ##
    # sends event to MixPanel
    #
    # @param [String] event_id: the id of the event
    # @param [String] event_name: event name or type
    # @param [Hash] data: (optional, default {}) the data to be sent with the event
    # @param [any] subject: the subject of the event. if the subject has a corresponding data_from dispatch, it will
    # be merged into the data
    # @param [ActionDispatch::Request] request: if included, request information will be merged into data
    # @param [ActionController::Base subclass] source: if included, controller information will be merged into data
    # @param [Enumerable(String)] path_exclusions: list of strings to be stripped from paths in data
    def send_event(event_id:,
                   event_name:,
                   data: {},
                   subject: nil,
                   request: nil,
                   source: nil,
                   path_exclusions: [])
      default_data = {}
      default_data[:locale] = I18n.locale.to_s
      default_data.merge!(data_from(request, path_exclusions: path_exclusions))
      default_data.merge!(data_from(source))
      default_data.merge!(data_from(subject))

      MixpanelService.instance.run(
        unique_id: event_id,
        event_name: event_name,
        data: default_data.merge(data),
      )
    end

    def send_tax_return_event(tax_return, event_name, additional_data = {})
      user_data = tax_return.status_last_changed_by.present? ? data_from_user(tax_return.status_last_changed_by) : {}
      MixpanelService.instance.run(
        unique_id: tax_return.client.intake.visitor_id,
        event_name: event_name,
        data: data_from_tax_return(tax_return).merge(data_from_client(tax_return.client)).merge(user_data).merge(additional_data)
      )
    end

    def send_status_change_event(tax_return)
      send_tax_return_event(tax_return, "status_change", { from_status: tax_return.status_before_last_save })
    end

    def send_file_accepted_event(tax_return)
      send_file_completed_event(tax_return, "filing_completed")
    end

    def send_file_rejected_event(tax_return)
      send_file_completed_event(tax_return, "filing_rejected")
    end

    ##
    # creates Mixpanel-specific data from objects submitted, stripping included path exclusions.
    # data will be merged in the order it is submitted: the last object included in `objs` will overwrite
    # the data in previous objects.
    #
    # @param [Enumerable(Object)] objs objects for which data will be created
    # @param [Enumerable(String)] path_exclusions: (optional, default []) strings to be stripped form paths
    def data_from(objs, path_exclusions: [])
      return {} unless objs

      obj_list = objs.is_a?(Enumerable) ? objs : [objs]

      obj_list.reduce({}) do |data, entry|
        case entry
        when Intake
          data.merge!(data_from_stimulus_triage_for_intake(entry))
            .merge!(data_from_intake(entry))
        when ActionController::Base
          data.merge!(data_from_controller(entry))
        when ActionDispatch::Request
          data.merge!(data_from_request(entry, path_exclusions: path_exclusions))
        when StimulusTriage
          data.merge!(data_from_stimulus_triage(entry))
        when TaxReturn
          data.merge!(data_from_tax_return(entry))
        when User
          data.merge!(data_from_user(entry))
        when Client
          data.merge!(data_from_client(entry))
        else
          {}
        end
      end
    end

    ##
    # creates Mixpanel data from a controller object
    def data_from_controller(source)
      {
        source: source.source,
        utm_state: source.utm_state,
        controller_name: source.class.name.sub("Controller", ""),
        controller_action: "#{source.class.name}##{source.action_name}",
        controller_action_name: source.action_name,
      }
    end

    ##
    # creates Mixpanel data from a request object
    def data_from_request(source, path_exclusions: [])
      user_agent = DeviceDetector.new(source.user_agent)
      major_browser_version = user_agent.full_version.try { |v| v.partition('.').first } rescue ""
      os_major_version = user_agent.os_full_version.try { |v| v.partition('.').first } rescue ""
      {
        browser_name: user_agent.name,
        browser_full_version: user_agent.full_version,
        browser_major_version: major_browser_version,
        os_name: user_agent.os_name,
        os_full_version: user_agent.os_full_version,
        os_major_version: os_major_version,
        is_bot: user_agent.bot?,
        bot_name: user_agent.bot_name,
        device_brand: user_agent.device_brand,
        device_name: user_agent.device_name,
        device_type: user_agent.device_type,
        device_browser_version: "#{user_agent.os_name} #{user_agent.device_type} #{user_agent.name} #{major_browser_version}",
        full_user_agent: source.user_agent,
        path: strip_all_from_url(source.path, path_exclusions),
        full_path: strip_all_from_url(source.fullpath, path_exclusions),
        referrer: strip_all_from_url(source.referrer, path_exclusions),
        referrer_domain: strip_all_from_url((URI.parse(source.referrer).host || "None" rescue "None"), path_exclusions),
      }
    end

    ##
    # creates Mixpanel data from an intake object
    def data_from_intake(intake)
      {
        intake_source: intake.source,
        intake_referrer: intake.referrer,
        intake_referrer_domain: intake.referrer_domain,
        primary_filer_age_at_end_of_tax_year: intake.age_end_of_tax_year.to_s,
        spouse_age_at_end_of_tax_year: intake.spouse_age_end_of_tax_year.to_s,
        primary_filer_disabled: intake.had_disability_yes? ? "yes" : "no",
        spouse_disabled: intake.spouse_had_disability_yes? ? "yes" : "no",
        had_dependents: intake.dependents.empty? ? "no" : "yes",
        number_of_dependents: intake.dependents.size.to_s,
        had_dependents_under_6: intake.had_dependents_under?(6) ? "yes" : "no",
        filing_joint: intake.filing_joint,
        had_earned_income: intake.had_earned_income? ? "yes" : "no",
        state: intake.state_of_residence,
        zip_code: intake.zip_code,
        needs_help_2020: intake.needs_help_2020,
        needs_help_2019: intake.needs_help_2019,
        needs_help_2018: intake.needs_help_2018,
        needs_help_2017: intake.needs_help_2017,
        needs_help_2016: intake.needs_help_2016,
        needs_help_backtaxes: intake.needs_help_with_backtaxes? ? "yes" : "no",
        vita_partner_name: intake.vita_partner&.name,
        triaged_from_stimulus: intake.triaged_from_stimulus? ? "yes" : "no",
        timezone: intake.timezone,
        csat: intake.satisfaction_face,
        eip_only: intake.eip_only,
        claimed_by_another: intake.claimed_by_another,
        already_applied_for_stimulus: intake.already_applied_for_stimulus,
        no_ssn: intake.no_ssn,
      }
    end

    ##
    # creates Mixpanel data from a stimulus triage object
    def data_from_stimulus_triage(stimulus_triage)
      {
        stimulus_triage_source: stimulus_triage.source,
        stimulus_triage_referrer: stimulus_triage.referrer,
        chose_to_file: stimulus_triage.chose_to_file,
        filed_prior_years: stimulus_triage.filed_prior_years,
        filed_recently: stimulus_triage.filed_recently,
        need_to_correct: stimulus_triage.need_to_correct,
        need_to_file: stimulus_triage.need_to_file
      }
    end

    def data_from_tax_return(tax_return)
      {
        year: tax_return.year.to_s,
        certification_level: tax_return.certification_level,
        service_type: tax_return.service_type,
        status: tax_return.status,
      }
    end

    def data_from_user(user)
      site = nil
      organization = nil
      coalition = nil

      case user.role_type
      when CoalitionLeadRole::TYPE
        coalition = user.role.coalition
      when OrganizationLeadRole::TYPE
        organization = user.role.organization
        coalition = organization.coalition
      when TeamMemberRole::TYPE, SiteCoordinatorRole::TYPE
        site = user.role.site
        organization = site.parent_organization
        coalition = organization.coalition
      end

      {
        user_id: user.id,
        user_site_name: site&.name,
        user_site_id: site&.id,
        user_organization_name: organization&.name,
        user_organization_id: organization&.id,
        user_coalition_name: coalition&.name,
        user_coalition_id: coalition&.id,
      }
    end

    def data_from_client(client)
      site = client.vita_partner&.site? ? client.vita_partner : nil
      organization = site ? site.parent_organization : client.vita_partner
      {
        client_organization_name: organization&.name,
        client_organization_id: organization&.id,
        client_site_name: site&.name,
        client_site_id: site&.id,
      }
    end

    ##
    # creates Mixpanel data from a stimulus triage object
    def data_from_stimulus_triage_for_intake(intake)
      return {} unless intake.triaged_from_stimulus?

      stimulus_triage = intake.triage_source
      {
          stimulus_triage_source: stimulus_triage.source,
          stimulus_triage_referrer: stimulus_triage.referrer,
          stimulus_triage_chose_to_file: stimulus_triage.chose_to_file,
          stimulus_triage_filed_prior_years: stimulus_triage.filed_prior_years,
          stimulus_triage_filed_recently: stimulus_triage.filed_recently,
          stimulus_triage_need_to_correct: stimulus_triage.need_to_correct,
          stimulus_triage_need_to_file: stimulus_triage.need_to_file
      }
    end

    private

    def send_file_completed_event(tax_return, event_name)
      user_data = tax_return.status_last_changed_by.present? ? data_from_user(tax_return.status_last_changed_by) : {}

      if tax_return.ready_for_prep_at.present?
        hours_since_ready_for_prep = (DateTime.current.to_time - tax_return.ready_for_prep_at.to_time) / 1.hour
        days_since_ready_for_prep = (hours_since_ready_for_prep / 24).floor
        hours_since_ready_for_prep = hours_since_ready_for_prep.floor
      else
        hours_since_ready_for_prep = days_since_ready_for_prep = "N/A"
      end

      hours_since_tax_return_created = ((DateTime.current.to_time - tax_return.created_at.to_time) / 1.hour).floor
      days_since_tax_return_created = (hours_since_tax_return_created / 24).floor

      MixpanelService.instance.run(
        unique_id: tax_return.client.intake.visitor_id,
        event_name: event_name,
        data: data_from_tax_return(tax_return).merge(data_from_client(tax_return.client)).merge(user_data).merge(
          {
            days_since_ready_for_prep: days_since_ready_for_prep,
            hours_since_ready_for_prep: hours_since_ready_for_prep,
            days_since_tax_return_created: days_since_tax_return_created,
            hours_since_tax_return_created: hours_since_tax_return_created
          }
        )
      )
    end
  end
end
