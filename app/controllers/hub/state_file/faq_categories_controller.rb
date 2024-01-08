module Hub
  module StateFile
    class FaqCategoriesController < Hub::FaqCategoriesController
      before_action :require_state_file

      def index
        @az_faq_categories = @faq_categories.where(product_type: :state_file_az)
        @ny_faq_categories = @faq_categories.where(product_type: :state_file_ny)
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