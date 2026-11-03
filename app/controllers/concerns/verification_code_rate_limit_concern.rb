module VerificationCodeRateLimitConcern
  extend ActiveSupport::Concern

  included do
    rate_limit to: 5, within: 1.hour, name: "verification-code-by-target",
               by: :rate_limit_target, with: :render_rate_limited, only: :edit, if: :rate_limit_target
    rate_limit to: 10, within: 1.hour, name: "verification-code-by-ip", with: :render_rate_limited, only: :edit
  end

  private

  def rate_limit_target
    contact_info = verification_contact_info.to_s.strip.downcase
    Digest::SHA256.hexdigest(contact_info) if contact_info.present?
  end

  def render_rate_limited
    DatadogApi.increment("#{controller_name}.verification_codes.rate_limited")
    @form = initialized_edit_form
    @form.errors.add(:verification_code, I18n.t("views.questions.verification.too_many_requests"))
    render :edit, status: :too_many_requests
  end
end
