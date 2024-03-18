require 'rails_helper'

RSpec.describe 'Api::V1::Authentication', type: :request do
  describe 'POST /signup' do
    let(:user_params) { { email: 'newuser@test.com', password: 'password', password_confirmation: 'password' } }

    it 'creates a new user and returns a token' do
      expect { post '/api/v1/signup', params: user_params }.to change(User, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(json_response['token']).not_to be_nil
    end
  end

  describe 'POST /login' do
    # let(:user) { users(:first_user) }
    before do
      @user = User.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password')
    end

    context 'with valid credentials' do
      it 'logs in the user and returns a token' do
        post '/api/v1/login', params: { email: @user.email, password: 'password' }
        expect(response).to have_http_status(:ok)
        expect(json_response['token']).not_to be_nil
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized status' do
        post '/api/v1/login', params: { email: @user.email, password: 'wrong_password' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
