module Routes
  # GetCTC is retired, but getctc.org is still a live domain pointed at this app.
  # This constraint is deliberately kept so that domain can continue to serve:
  #   - the archive redirect to GetYourRefund (Ctc::CtcPagesController#home)
  #   - the Identrust EV certificate validation (PublicPagesController#pki_validation)
  #
  # It matches on the domain directly rather than reading Rails.configuration.ctc_url,
  # because the rest of the GetCTC configuration is being removed.
  class CtcDomain
    LEGACY_DOMAIN = "getctc.org".freeze

    def matches?(request)
      host = request.host.to_s
      host == LEGACY_DOMAIN || host.end_with?(".#{LEGACY_DOMAIN}")
    end
  end
end
