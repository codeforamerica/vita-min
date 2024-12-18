module Hub
  module StateFile
    class FaqCategoriesController < Hub::FaqCategoriesController
      def index
        @state_faq_categories = ::StateFile::StateInformationService.active_state_codes.to_h do |state_code|
          [state_code, @faq_categories.where(product_type: "state_file_#{state_code}".to_sym)]
        end
      end

      private

      def load_faq_return_path
        @faq_return_path = :hub_state_file_faq_categories_path
      end

      def position_options
        (1..(FaqCategory.where.not(product_type: :gyr).all.count + 1)).to_a || [1]
      end
    end
  end
end