module Hub
  class FaqItemsController < Hub::BaseController
    before_action :require_admin
    before_action :set_paper_trail_whodunnit
    before_action :load_faq_category
    load_and_authorize_resource
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
        flash_message = "Unable to create '#{@faq_item.question_en}'"
        render :new, error: flash_message
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
        flash_message = "Unable to update '#{@faq_item.question_en}'"
        render :edit, error: flash_message
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
      redirect_to hub_faq_categories_path
    end

    private

    def faq_item_params
      params.fetch(:hub_faq_item_form, {}).permit(*form_class.attribute_names)
    end

    def load_faq_category
      @faq_category = FaqCategory.find(params[:faq_category_id])
    end

    def form_class
      Hub::FaqItemForm
    end
  end
end
