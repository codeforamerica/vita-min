#!/usr/bin/env ruby

require_relative "../config/environment"

# Quick and dirty script to run notifications from the command line to smoke test/copy-check them
class SendMessage < Thor
  all_message_classes = StateFile::AutomatedMessage.constants.select { |c| StateFile::AutomatedMessage.const_get(c).is_a? Class }

  all_message_classes.each do |klass|
    method_name = klass.to_s.underscore

    desc method_name, "Sends the #{method_name} notification. Messages are created in a transaction due to intakes being required"
    method_option :sms_number, aliases: '-s', desc: 'Number to send an sms to. Requires valid twilio credentials', type: :string
    method_option :email_address, aliases: '-e', desc: 'Email address to send an email to. Requires the rails application to be configured to emit emails.', type: :string
    method_option :body_args, aliases: '-b', desc: 'Body arguments. Pass multiple at once', type: :hash, default: {}

    define_method(method_name) do
      ActiveRecord::Base.transaction do
        say "Creating disposable intake to test notification", :cyan

        intake = StateFileAzIntake.create(
          primary_first_name: "Testa",
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
          email: !!options[:email_address],
          sms: !!options[:sms_number],
          body_args: body_args
        ).send_message

        raise ActiveRecord::Rollback
      end
    end
  end
end

SendMessage.start
