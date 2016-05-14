require 'spec_helper'

describe Rating::CommentsController, type: :controller do
  render_views

  let(:valid_attributes) { { "text" => FFaker::CheesyLingo.sentence } }
  let(:valid_session) { {} }
  let(:user) { create(:user) }

  before do
    user.roles.create(name: 'reviewer')
    sign_in user
  end

  describe 'application comment' do
    let(:application) { create(:application) }
    let(:params) { {application_id: application.id} }

    context 'with valid params' do
      it 'creates a new Comment' do
        expect {
          post :create, {comment: params.merge(valid_attributes)}, valid_session
        }.to change(Comment, :count).by(1)
      end

      it 'redirects to comment on application page' do
        post :create, {comment: params.merge(valid_attributes)}, valid_session
        expect(response).to redirect_to([:rating, application, anchor: 'comment_1'])
      end
    end
    context 'with invalid params (no text)' do
      it 'does not create new Comment' do
        expect {
          post :create, {comment: params}, valid_session
        }.not_to change(Comment, :count)
      end

      it 'redirects to the application page with flash' do
        post :create, {comment: params}, valid_session
        expect(flash[:alert]).to be_present
        expect(response).to redirect_to([:rating, application])
      end
    end
  end
end