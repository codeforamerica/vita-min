module StateFile
  module Questions
    class ConfirmationController < QuestionsController
      layout "state_file/question"

      def edit
        @download_link = case params[:us_state]
                        when "ny"
                          ny_state_file_questions_download_ny_xml_path
                        when "az"
                          az_state_file_questions_download_az_xml_path
                        end
        super
      end

      def download_xml
        submission = EfileSubmission.where(data_source: current_intake).first
        # TODO could instead get the attached submission_bundle from efile submission?
        submission_content = case params[:us_state]
                             when "ny"
                               SubmissionBuilder::Ty2022::States::Ny::IndividualReturn.build(submission).document
                             when "az"
                               SubmissionBuilder::Ty2022::States::Az::IndividualReturn.build(submission).document
                             end
        File.open("/tmp/#{params[:us_state]}_return.xml", "wb") do |f|
          f.write submission_content
        end
        send_file "/tmp/#{params[:us_state]}_return.xml", type: "application/xml", x_sendfile: true
      end

      def illustration_path; end

      private

      def next_path
        root_path
      end

      def after_update_success
        session[:state_file_intake] = nil
        flash[:notice] = "Submitted efile submission"
      end
    end
  end
end
