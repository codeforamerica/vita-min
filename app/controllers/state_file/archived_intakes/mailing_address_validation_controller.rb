require 'csv'

module StateFile
  module ArchivedIntakes
    class MailingAddressValidationController < ArchivedIntakeController
      def edit
        create_state_file_access_log("issued_mailing_address_challenge")
        @addresses = generate_address_options
        @form = MailingAddressValidationForm.new(addresses: @addresses, current_address: current_archived_intake.full_address)
      end

      def update
        @form = MailingAddressValidationForm.new(mailing_address_validation_form_params, addresses: @addresses, current_address: current_archived_intake.full_address)

        if @form.valid?
          create_state_file_access_log("correct_mailing_address")
          # this should take us to the download
          redirect_to root_path
        else
          create_state_file_access_log("incorrect_mailing_address")
          current_request.lock_access!
          #this should be to the offboaring page
          redirect_to faq_path
        end
      end

      def generate_address_options
        if Rails.env == "development"
          file_path = Rails.root.join('app', 'lib', 'challenge_addresses', 'test_addresses.csv')
        else
          bucket = select_bucket
          file_key = "challenge_addresses/#{current_archived_intake.mailing_state.downcase}_addresses.csv"
          file_path = File.join(Rails.root, "tmp", "#{current_archived_intake.mailing_state.downcase}_addresses.csv")

          download_file_from_s3(bucket, file_key, file_path) unless File.exist?(file_path)
        end
        addresses = CSV.read(file_path, headers: false).flatten
        random_addresses = addresses.sample(2)
        (random_addresses + [current_archived_intake.full_address]).shuffle
      end

      private

      def mailing_address_validation_form_params
        params.require(:state_file_archived_intakes_mailing_address_validation_form).permit(:selected_address)
      end

      def download_file_from_s3(bucket, file_key, file_path)
        s3_client = Aws::S3::Client.new(region: 'us-east-1', credentials: s3_credentials)
        s3_client.get_object(
          response_target: file_path,
          bucket: bucket,
          key: file_key
        )
      end

      def s3_credentials
        if ENV["AWS_ACCESS_KEY_ID"].present?
          Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
        else
          Aws::Credentials.new(
            Rails.application.credentials.dig(:aws, :access_key_id),
            Rails.application.credentials.dig(:aws, :secret_access_key)
          )
        end
      end

      def select_bucket
        case Rails.env
        when 'production'
          'vita-min-prod-docs'
        when 'staging'
          'vita-min-staging-docs'
        when 'demo'
          'vita-min-demo-docs'
        when 'heroku'
          'vita-min-heroku-docs'
        end
      end
    end
  end
end
