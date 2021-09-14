module Ctc
  class CtcPagesController < CtcController
    def home
      if params[:ctc_beta] == "1" && ENV['DISABLE_CTC_BETA_PARAM'].blank?
        cookies.permanent[:ctc_intake_ok] = "yes"
        redirect_to Ctc::Questions::OverviewController.to_path_helper
      end
    end

    def source_routing
      # allow before_action to stash the source, then go to the homepage
      redirect_to root_path(ctc_beta: params[:ctc_beta])
    end

    def navigators
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      file_name = params[:locale] == "es" ? "navigators_es.md" : "navigators.md"
      @markdown_content = markdown.render(File.read(Rails.root.join("app", "views", "ctc", "ctc_pages", file_name))).html_safe
    end

    def privacy_policy
    end

    def what_will_i_need_to_submit
    end

    def check_payment_status
    end

    def what_will_happen_and_when
    end

    def how_do_i_know_what_i_received_for_the_stimulus
    end

    def will_i_ever_have_to_pay_this_money_back
    end

    def parents_with_shared_custody
    end

    def no_income_or_income_from_benefits_programs
    end

    def are_daca_recipients_eligible
    end

    def will_it_affect_my_immigration_status
    end
  end
end
