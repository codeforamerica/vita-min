# app/controllers/concerns/fyst_sunset_redirect.rb
module FystSunsetRedirect
  extend ActiveSupport::Concern

  if Flipper.enabled?(:fyst_sunset)
    before_action :ma
  end
  private

  def maybe_redirect_due_to_sunset!
    return unless FystSunset.live?           # do nothing unless flag/date is live
    return if request_get_or_head?           # we only care about GET/HEAD pages

    # For non-GET (POST to sign-in, uploads, etc.) we ALSO want to block,
    # because nobody should be doing app-y stuff anymore.
    # So don't early return for POST etc. We'll handle them below.
    # fall through
    enforce_sunset_redirect!
  end

  def enforce_sunset_redirect!
    return if allowed_public_path?(request)

    # Prevent infinite loops: if you're already on root, don't redirect again.
    return if request.path == root_path

    redirect_to root_path, allow_other_host: false
  end

  # Update this method to match YOUR actual routes.
  def allowed_public_path?(req)
    path = req.path

    return true if path == root_path

    # FAQs:
    # - /faq
    # - /faq/some-article
    return true if path == faq_index_path
    return true if path.match?(/\A#{Regexp.escape(faq_index_path)}\/.+\z/)
    # e.g. /faq/how-do-i-get-my-return

    # Privacy Policy:
    return true if path == privacy_policy_path

    # SMS Terms:
    return true if path == sms_terms_path

    # assets/healthchecks/etc. (optional but usually needed)
    return true if path.start_with?("/assets")
    return true if path.start_with?("/packs") # webpacker / js packs
    return true if path.start_with?("/robots.txt")
    return true if path.start_with?("/favicon.ico")
    return true if path.start_with?("/health") # if you have uptime pings
    return true if path.start_with?("/rails/active_storage") # blobs, etc.

    false
  end
end
