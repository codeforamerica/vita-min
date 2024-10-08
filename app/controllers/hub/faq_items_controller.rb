module Hub
  class FaqItemsController < Hub::BaseController
    load_and_authorize_resource :faq_category
    before_action :build_faq_item, only: [:new, :create]
    load_and_authorize_resource

    before_action :set_paper_trail_whodunnit
    before_action :load_faq_return_path
    layout "hub"

    def new
      @form = form_class.new(@faq_category, {})
    end

    def create
      @form = form_class.new(@faq_item, faq_item_params.merge(faq_category_id: @faq_category.id))

      if @form.save
        flash[:notice] = "Successfully created '#{@faq_item.question_en}'"
        redirect_to hub_faq_category_faq_item_path(@faq_category.id, @faq_item.id)
      else
        flash.now[:alert] = "Unable to create '#{@faq_item.question_en}'"
        render :new
      end
    end

    def edit
      @form = form_class.from_record(@faq_item)
    end

    def update
      @form = form_class.new(@faq_item, faq_item_params.merge(faq_category_id: @faq_category.id))

      if @form.save
        flash[:notice] = "Successfully updated '#{@faq_item.question_en}'"
        redirect_to hub_faq_category_faq_item_path(@faq_category.id, @faq_item.id)
      else
        flash.now[:alert] = "Unable to update '#{@faq_item.question_en}'"
        render :edit
      end
    end

    def show; end

    def destroy
      begin
        ActiveRecord::Base.transaction do
          @faq_item.destroy!
        end
        flash[:notice] = "Deleted '#{@faq_item.question_en}'"
      rescue ActiveRecord::InvalidForeignKey
        flash[:error] = "Unable to delete '#{@faq_item.question_en}'"
      end
      redirect_to send(@faq_return_path)
    end

    private

    def faq_item_params
      params.fetch(:hub_faq_item_form, {}).permit(*form_class.attribute_names)
    end

    def build_faq_item
      @faq_item = FaqItem.new(faq_category: @faq_category)
    end

    def load_faq_return_path
      @faq_return_path = @faq_category.product_type_gyr? ? :hub_faq_categories_path : :hub_state_file_faq_categories_path
    end

    def form_class
      Hub::FaqItemForm
    end
  end
end
