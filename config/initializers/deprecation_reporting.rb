# Forwards Rails deprecation warnings to Sentry.
#
# Deployed environments set `config.active_support.deprecation = :notify`
# (config/environments/shared_deployment_config.rb), which only emits an
# ActiveSupport::Notifications event named "deprecation.<gem_name>". Nothing subscribed
# to it -- not our code, and not sentry-rails -- so every deprecation warning in
# staging, demo and production was being silently discarded. That is the main
# early-warning signal during a Rails upgrade, so subscribe to it here.
#
# Two non-obvious constraints, both worth preserving if you edit this:
#
# 1. All the detail goes in the message string. config/initializers/sentry.rb has a
#    `before_send` that runs `event.extra&.clear` and strips all but a few tags for PII
#    scrubbing, so anything attached as extra/tags would arrive empty.
# 2. Deprecations can fire on every request, so identical warnings are reported once per
#    process. Without that, a single deprecation in a hot path would flood Sentry.
#
# Matches any "deprecation.*" event, not just "deprecation.rails", so deprecators
# belonging to gems are captured too.

Rails.application.config.after_initialize do
  reported = Concurrent::Set.new

  ActiveSupport::Notifications.subscribe(/\Adeprecation\./) do |_name, _start, _finish, _id, payload|
    # Rails' own message already starts with "DEPRECATION WARNING: "; drop it so the
    # summary below does not read "DEPRECATION (...): DEPRECATION WARNING: ...".
    message = payload[:message].to_s.sub(/\ADEPRECATION WARNING:\s*/, "")
    gem_name = payload[:gem_name] || "unknown"
    horizon = payload[:deprecation_horizon]

    # The message embeds its own call site ("(called from ... at foo.rb:12)"), so this
    # fingerprint yields one Sentry issue per deprecation *per call site*. That is
    # deliberate: when clearing deprecations ahead of a Rails upgrade the call site is
    # the unit of work, and the count of distinct call sites is small and finite.
    # Reporting is deduplicated per process, so a deprecation in a hot path still only
    # reports once rather than on every request.
    fingerprint = ["deprecation", gem_name.to_s, message]

    if reported.add?(fingerprint.join("|"))
      # Only app frames -- gem frames are noise and the deprecation is almost always
      # actionable at our own call site.
      app_frames = Array(payload[:callstack])
                     .map(&:to_s)
                     .select { |frame| frame.include?(Rails.root.to_s) }
                     .first(5)
                     .map { |frame| frame.sub("#{Rails.root}/", "") }

      summary = +"DEPRECATION (#{gem_name}"
      summary << ", removed in #{horizon}" if horizon.present?
      summary << "): #{message}"
      summary << "\n\n" << app_frames.join("\n") if app_frames.any?

      Sentry.with_scope do |scope|
        scope.set_fingerprint(fingerprint)
        scope.set_level(:warning)
        Sentry.capture_message(summary)
      end
    end
  end
end
