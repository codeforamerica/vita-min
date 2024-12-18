#!/usr/bin/env ruby

# You probably always want this, right? Opens emails in browser
ENV['LETTER_OPENER'] = '1'

require_relative "../config/environment"

# Horrible hack to enable emails to send within the transaction

# Reopen app/models/state_file_notification_email.rb
class StateFileNotificationEmail
  # This is after_create_commit in the unmodified class which never fires
  # because nothing ever gets commited in the transaction
  after_create :deliver

  private

  def deliver
    # This is #perform_later in the unmodified class. Obviously we don't have a
    # job queue running for this task
    StateFile::SendNotificationEmailJob.perform_now(id)
  end
end

# Quick and dirty script to run notifications from the command line to smoke test/copy-check them
class SendMessage < Thor
  def self.exit_on_failure? = true

  all_message_classes = StateFile::AutomatedMessage.constants.select { |c| StateFile::AutomatedMessage.const_get(c).is_a? Class }

  all_message_classes.each do |klass|
    method_name = klass.to_s.underscore

    desc method_name, "Sends the #{method_name} notification. Messages are created in a transaction due to intakes being required"
    method_option :sms_number, aliases: '-s', desc: 'Number to send an sms to. Requires valid twilio credentials', type: :string
    method_option :email_address, aliases: '-e', desc: 'Email address to send an email to. Requires the rails application to be configured to emit emails.', type: :string
    method_option :body_args, aliases: '-b', desc: 'Body arguments. Pass multiple at once', type: :hash, default: {}
    method_option :locale, aliases: '-l', desc: 'Pass the locale to be used. Defaults to en', type: :string, enum: ['en', 'es']

    define_method(method_name) do
      ActiveRecord::Base.transaction do
        say "Creating disposable intake to test notification", :cyan

        intake = StateFileAzIntake.create(
          primary_first_name: "Test",
          primary_last_name: "Testerson",
          email_address: options.fetch(:email_address, nil),
          email_address_verified_at: 1.minute.ago,
          phone_number: options.fetch(:sms_number, nil),
          phone_number_verified_at: 1.minute.ago,
          message_tracker: {},
          hashed_ssn: "nonsense"
        )

        # Horrible hack, but this enables us to avoid having to stub a submission
        message = Class.new StateFile::AutomatedMessage.const_get(klass) do
          def self.after_transition_notification?
            false
          end
        end

        body_args = {
          intake_id: intake.id
        }.merge(options[:body_args].symbolize_keys)

        say "Sending message #{klass}", :cyan
        say "Using email #{options[:email_address]}", :cyan if options[:email_address].present?
        say "Using sms number #{options[:sms_number]}", :cyan if options[:sms_number].present?
        say "Using body arguments #{body_args}", :cyan if options[:body_args].present?
        StateFile::MessagingService.new(
          message:,
          intake:,
          locale: options[:locale],
          email: !!options[:email_address],
          sms: !!options[:sms_number],
          body_args: body_args
        ).send_message
      rescue I18n::MissingInterpolationArgument => e
        say_error "Missing #{e.key}", :red
        say_error "📝 Correct by using -b #{e.key}:'some_value' some_other_key:'some_other_value'", :red
      ensure
        raise ActiveRecord::Rollback
      end
    end
  end
end

SendMessage.start
