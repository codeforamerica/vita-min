require "rails_helper"

describe Hub::FaqItemsController do
  let(:user) { create :admin_user }
  let(:faq_category) { create :faq_category }
  let!(:faq_item) { create :faq_item, faq_category: faq_category, position: 1, question_en: "What is the square root of pi?", slug: "sq_root" }
  let!(:faq_item_2) { create :faq_item, faq_category: faq_category, slug: "there_there", position: 2 }

  describe "#edit" do
    let(:params) { {
      faq_category_id: faq_category.id,
      id: faq_item.id
    } }

    it_behaves_like :an_action_for_admins_only, action: :edit, method: :get
    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "renders edit" do
        get :edit, params: params
        expect(assigns(:faq_item)).to eq faq_item
        expect(assigns(:position_options)).to eq [1, 2]
        expect(response).to render_template :edit
      end
    end
  end

  describe "#update" do
    let(:slug) { "how_moon" }
    let(:params) do
      {
        faq_category_id: faq_category.id,
        id: faq_item.id,
        faq_item: {
          faq_category_id: faq_category.id,
          position: 2,
          slug: slug,
          question_en: "How will I go to the moon?",
          question_es: "¿Cómo voy a ir a la luna?",
          answer_en: "<div>In a tea cup</div>",
          answer_es: "<div>En una taza de te</div>",
        } }
    end
    it_behaves_like :an_action_for_admins_only, action: :update, method: :put

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "updates the object based on passed params" do
        put :update, params: params
        faq_item.reload
        expect(faq_item.position).to eq 2
        expect(faq_item.question_en).to eq "How will I go to the moon?"
        expect(faq_item.question_es).to eq "¿Cómo voy a ir a la luna?"
        expect(faq_item.answer_en).to be_an_instance_of ActionText::RichText
        expect(faq_item.answer_en.body.to_s).to include "<div>In a tea cup</div>"
        expect(faq_item.answer_es).to be_an_instance_of ActionText::RichText
        expect(faq_item.answer_es.body.to_s).to include "<div>En una taza de te</div>"
        expect(faq_item.slug).to eq "how_moon"
        expect(response).to render_template :show
      end

      it "shift other positions after it" do
        put :update, params: params
        faq_item.reload
        expect(faq_item.position).to eq 2
        expect(faq_item_2.reload.position).to eq 1
      end

      context "slug is empty" do
        let!(:slug) { "" }
        it "updates the slug to the parameterized version of the name" do
          put :update, params: params
          faq_item.reload
          expect(faq_item.slug).to eq "how_will_i_go_to_the_moon"
        end
      end
    end
  end

  describe "#new" do
    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "renders new" do
        get :new, params: {faq_category_id: faq_category.id}
        expect(assigns(:position_options)).to eq [1, 2, 3]
        expect(response).to render_template :new
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
        faq_category_id: faq_category.id,
        id: faq_item.id,
        faq_item: {
          faq_category_id: faq_category.id,
          position: 2,
          question_en: "How will I go to the moon?",
          question_es: "¿Cómo voy a ir a la luna?",
          answer_en: "<div>In a tea cup</div>",
          answer_es: "<div>En una taza de te</div>",
        } }
    end
    it_behaves_like :an_action_for_admins_only, action: :create, method: :post

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "creates a new object based on the params" do
        expect do
          post :create, params: params
        end.to change(FaqItem, :count).by 1

        expect(FaqItem.last.question_en).to eq "How will I go to the moon?"
        expect(FaqItem.last.question_es).to eq "¿Cómo voy a ir a la luna?"
        expect(FaqItem.last.answer_en).to be_an_instance_of ActionText::RichText
        expect(FaqItem.last.answer_en.body.to_s).to include "<div>In a tea cup</div>"
        expect(FaqItem.last.answer_es).to be_an_instance_of ActionText::RichText
        expect(FaqItem.last.answer_es.body.to_s).to include "<div>En una taza de te</div>"
        expect(FaqItem.last.position).to eq 2
        expect(FaqItem.last.slug).to eq "how_will_i_go_to_the_moon"
        expect(faq_item.position).to eq 1
        expect(faq_item_2.reload.position).to eq 3
      end
    end
  end

  describe "#destroy" do
    let(:params) do
      {
        faq_category_id: faq_category.id,
        id: faq_item.id
      }
    end
    it_behaves_like :an_action_for_admins_only, action: :destroy, method: :delete

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "deletes the faq category and all the associated faq items" do
        expect do
          delete :destroy, params: params
        end.to change(FaqItem, :count).by -1

        expect(response).to redirect_to hub_faq_categories_path
        expect(flash[:notice]).to eq "Deleted 'What is the square root of pi?'"

        expect do
          faq_item.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "shifts the positions after it" do
        delete :destroy, params: params
        expect(faq_item_2.reload.position).to eq 1
      end
    end
  end
end