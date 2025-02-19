module StateFile
  module Questions
    class PostDataTransferController < QuestionsController
      skip_before_action :redirect_if_df_data_required

      def edit
        super
        if current_intake&.df_data_import_succeeded_at.nil?
          redirect_to StateFilePagesController.to_path_helper(action: :data_import_failed) and return
        end
        # Redirect to offboarding here if not eligible
        if current_intake&.has_disqualifying_eligibility_answer? ||
           current_intake&.disqualifying_df_data_reason.present?
          redirect_to next_path and return
        end
        # we need to remove duplicate associations here because sometimes we accidentally create duplicate records during data import
        remove_duplicate_w2s
        remove_duplicate_dependents

        StateFileEfileDeviceInfo.find_or_create_by!(
          event_type: "initial_creation",
          ip_address: ip_for_irs,
          intake: current_intake,
        )
      end

      private

      def remove_duplicate_w2s
        indices = []
        current_intake.state_file_w2s.each do |w2|
          current_index = w2.w2_index
          if indices.include?(current_index)
            w2.destroy!
          else
            indices.push(current_index)
          end
        end
      end

      def remove_duplicate_dependents
        ssns = []
        current_intake.dependents.each do |dependent|
          ssn = dependent.ssn
          if ssns.include?(ssn)
            dependent.destroy!
          else
            ssns.push(ssn)
          end
        end
      end

      def prev_path
        nil
      end
    end
  end
end
