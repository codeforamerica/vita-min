module Routes
  class CtcDomain
    def matches?(request)
      Rails.application.config.ctc_domains.values.any? do |matcher|
        matcher.is_a?(Regexp) ? matcher.match?(request.host) : matcher == request.host
      end
    end
  end
end
