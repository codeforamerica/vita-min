module Ctc
  class CtcPagesController < CtcController
    FAQ_QUESTIONS = [
      :what_is_the_child_tax_credit_ctc,
      :is_the_child_tax_credit_ctc_going_away,
      :how_do_i_get_my_child_tax_credit_ctc_payments,
      :what_do_i_do_if_someone_else_has_claimed_my,
      :what_if_i_dont_have_any_income_or_only_income,
      :how_much_is_the_child_tax_credit_in_2022,
      :do_i_qualify_for_the_child_tax_credit_ctc,
      :am_i_eligible_for_child_tax_credit_if_i_dont,
    ].freeze

    def home
      # redirect to home hiding original source param
      redirect_to root_path and return if params[:source].present?

      case session[:source]
      when "cactc", "fed", "child"
        redirect_to action: :help
      when "eip", "cagov", "state"
        redirect_to action: :stimulus_navigator
      when "credit", "ca", "castate"
        redirect_to action: :stimulus
      end
    end

    def help
      session[:source] = "help" unless session[:source].present?
      @needs_help_banner = true
      render :home
    end

    def stimulus
      session[:source] = "stimulus" unless session[:source].present?
      render :stimulus_home
    end

    def stimulus_navigator
      session[:source] = "stimulus-navigator" unless session[:source].present?
      @needs_help_banner = true
      render :stimulus_home
    end

    def navigators
      file_name = params[:locale] == "es" ? "navigators_es.md" : "navigators.md"
      @markdown_content = markdown_content_from_file(file_name)
    end

    def privacy_policy; end

    def california_benefits; end

    def what_will_i_need_to_submit; end

    def check_payment_status; end

    def what_will_happen_and_when; end

    def how_do_i_know_what_i_received_for_the_stimulus; end

    def will_i_ever_have_to_pay_this_money_back; end

    def parents_with_shared_custody; end

    def no_income_or_income_from_benefits_programs; end

    def are_daca_recipients_eligible; end

    def will_it_affect_my_immigration_status; end

    def how_do_i_get_an_itin; end

    def completed; end

    def puerto_rico
      redirect_to action: :home and return unless Flipper.enabled?(:puerto_rico_home_location)

      if params[:locale].nil?
        I18n.with_locale('es') do
          render :puerto_rico and return
        end
      end
    end

    private

    def markdown_content_from_file(file_name)
      renderer = Redcarpet::Render::HTML.new(link_attributes: { target: '_blank', rel: 'noopener' })
      markdown = Redcarpet::Markdown.new(renderer, tables: true)
      markdown.render(File.read(Rails.root.join("app", "views", "ctc", "ctc_pages", file_name))).html_safe
    end
  end
end
