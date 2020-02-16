require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  context "#delete" do
    let!(:document) { create :document }
    let(:user) { create :user, intake: document.intake }

    it "requires authentication" do
      expect do
        delete :destroy, params: { id: document.id }
      end.not_to change(Document, :count)

      expect(response).to redirect_to(identity_questions_path)
    end

    context "with an authenticated user" do
      let(:params) do
        { id: document.id }
      end

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it "allows them to delete their own document and redirects back" do
        expect do
          delete :destroy, params: params
        end.to change(Document, :count).by(-1)

        expect(response).to redirect_to w2s_documents_path
      end

      context "with a document id that does not exist" do
        let(:params) do
          { id: 123874619823764 }
        end

        it "simply redirects to the documents overview page" do
          expect do
            delete :destroy, params: params
          end.not_to change(Document, :count)

          expect(response).to redirect_to(overview_documents_path)
        end
      end

      context "for another user's document" do
        let(:user) { create :user }
        let(:params) do
          { id: document.id }
        end

        it "does not delete the other document" do
          expect do
            delete :destroy, params: params
          end.not_to change(Document, :count)

          expect(response).to redirect_to(overview_documents_path)
        end
      end
    end
  end
end
