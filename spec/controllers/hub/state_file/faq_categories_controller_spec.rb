require "rails_helper"

describe Hub::StateFile::FaqCategoriesController do
  let(:user) { create :state_file_admin_user }
  let(:faq_category) { create :faq_category, position: 1, product_type: :state_file_az }
  let(:faq_category_2) { create :faq_category, name_en: "what what?", slug: "what_what", position: 2, product_type: :state_file_az }
  let(:faq_category_ny) { create :faq_category, name_en: "new york category", slug: "new_york_category", position: 2, product_type: :state_file_ny }
  let(:faq_category_nc) { create :faq_category, name_en: "nc category", slug: "north_carolina_category", position: 1, product_type: :state_file_nc }
  let!(:faq_item) { create :faq_item, faq_category: faq_category }
  let!(:faq_item_2) { create :faq_item, faq_category: faq_category_2, slug: "there_there" }

  describe "#index" do
    it_behaves_like :an_action_for_admins_only, action: :index, method: :get

    before do
      sign_in user
    end

    it "renders index" do
      get :index
      expect(response).to render_template :index
      expect(assigns(:az_faq_categories)).to match_array [faq_category, faq_category_2]
      expect(assigns(:ny_faq_categories)).to match_array [faq_category_ny]
      expect(assigns(:nc_faq_categories)).to match_array [faq_category_nc]
    end
  end

  describe "#edit" do
    let(:params) { { id: faq_category.id } }

    it_behaves_like :an_action_for_admins_only, action: :edit, method: :get
    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "renders edit" do
        get :edit, params: params
        expect(assigns(:faq_category)).to eq faq_category
        expect(response).to render_template :edit
      end
    end
  end

  describe "#update" do
    let(:slug) { "when_slug" }
    let(:params) do
      {
        id: faq_category.id,
        hub_faq_category_form: {
          slug: slug,
          name_en: "when when",
          name_es: "cuando cuando",
          position: 2,
          product_type: :state_file_az,
        }
      }
    end
    it_behaves_like :an_action_for_admins_only, action: :update, method: :put

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "updates the object based on passed params" do
        put :update, params: params
        faq_category.reload
        expect(faq_category.position).to eq 2
        expect(faq_category.name_en).to eq "when when"
        expect(faq_category.name_es).to eq "cuando cuando"
        expect(faq_category.slug).to eq "when_slug"
        expect(response).to redirect_to hub_state_file_faq_categories_path
      end

      it "shift other positions after it" do
        put :update, params: params
        faq_category.reload
        expect(faq_category.position).to eq 2
        expect(faq_category_2.reload.position).to eq 1
      end

      it "records a paper trail" do
        put :update, params: params
        faq_category.reload
        expect(faq_category.versions.last.event).to eq "update"
        expect(faq_category.versions.last.whodunnit).to eq user.id.to_s
        expect(faq_category.versions.last.item_id).to eq faq_category.id
        expect(faq_category.versions.last.item_type).to eq "FaqCategory"
      end

      context "slug is empty" do
        let!(:slug) { "" }

        it "saves an auto-generated response anyways" do
          put :update, params: params
          expect(response).to be_redirect
          faq_category.reload
          expect(faq_category.slug).to eq "when_when"
        end
      end

    end
  end

  describe "#new" do

    it_behaves_like :an_action_for_admins_only, action: :new, method: :get
    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "renders new" do
        get :new
        expect(response).to render_template :new
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
        hub_faq_category_form: {
          name_en: "Third added category",
          name_es: "",
          position: 2,
          product_type: "gyr",
        }
      }
    end
    it_behaves_like :an_action_for_admins_only, action: :create, method: :post

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "creates a new object based on the params" do
        expect do
          post :create, params: params
        end.to change(FaqCategory, :count).by 1

        created_category = FaqCategory.reorder('').last

        expect(created_category.name_en).to eq "Third added category"
        expect(created_category.name_es).to eq ""
        expect(created_category.position).to eq 2
        expect(created_category.slug).to eq "third_added_category"
        expect(faq_category.position).to eq 1
        expect(faq_category_2.reload.position).to eq 2
      end

      it "records a paper trail" do
        expect do
          post :create, params: params
        end.to change(PaperTrail::Version, :count).by 1

        expect(PaperTrail::Version.last.event).to eq "create"
        expect(PaperTrail::Version.last.whodunnit).to eq user.id.to_s
        expect(PaperTrail::Version.last.item_id).to eq FaqCategory.reorder('').last.id
        expect(PaperTrail::Version.last.item_type).to eq "FaqCategory"
      end
    end
  end

  describe "#destroy" do
    let(:params) do
      { id: faq_category.id }
    end
    it_behaves_like :an_action_for_admins_only, action: :destroy, method: :delete

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "deletes the faq category and all the associated faq items" do
        expect do
          delete :destroy, params: params
        end.to change(FaqCategory, :count).by(-1).and change(FaqItem, :count).by(-1)

        expect(response).to redirect_to hub_state_file_faq_categories_path
        expect(flash[:notice]).to eq "Deleted 'MyString' category and associated items"

        expect do
          faq_category.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "shifts the positions after it" do
        delete :destroy, params: params
        expect(faq_category_2.reload.position).to eq 1
      end

      it "records a paper trail" do
        expect do
          post :destroy, params: params
        end.to change(PaperTrail::Version, :count).by 2

        expect(PaperTrail::Version.last.event).to eq "destroy"
        expect(PaperTrail::Version.last.whodunnit).to eq user.id.to_s
        expect(PaperTrail::Version.last.item_id).to eq faq_category.id
        expect(PaperTrail::Version.last.item_type).to eq "FaqCategory"
      end
    end
  end
end