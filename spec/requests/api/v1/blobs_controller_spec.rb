require 'rails_helper'

RSpec.describe "Api::V1::BlobsController", type: :request do
  before do
    @user = users(:first_user)
    @token = token_for_user(@user)
  end
  let(:valid_attributes) {
    { file: fixture_file_upload('spec/fixtures/files/test_file.txt', 'text/plain') }
  }
  let(:invalid_attributes) {
    { file: nil }
  }
  include ActionDispatch::TestProcess

  describe "GET /blobs" do
    it "renders a successful response" do
      Blob.create! valid_attributes
      get api_v1_blobs_url, headers: { Authorization: "Bearer #{@token}",
                                       Accept: 'application/json'}
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /blobs/:id" do
    it "renders a successful response for existing blob" do
      blob = Blob.create! valid_attributes
      get api_v1_blob_url(blob),headers: { Authorization: "Bearer #{@token}" }
      expect(response).to have_http_status(:success)
    end

    it "renders a not found response for non-existing blob" do
      get api_v1_blob_url(id: 999), headers: { Authorization: "Bearer #{@token}" }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /blobs" do
    context "with valid parameters" do
      it "creates a new Blob and returns created status" do
        expect {
          post api_v1_blobs_url, params: { file: valid_attributes[:file] }, headers: { Authorization: "Bearer #{@token}" }
        }.to change(Blob, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Blob and returns bad request status" do
        post api_v1_blobs_url, params: invalid_attributes, headers: { Authorization: "Bearer #{@token}" }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

end