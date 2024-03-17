class Api::V1::BlobsController < ApplicationController
  require 'base64'
  before_action :authenticate_request
  before_action :set_blob, only: [:show, :destroy]


  # index renders all the blobs in the table
  # GET /blobs
  def index
    @blobs = Blob.all
    render json: @blobs, status: :ok
  end

  # # This
  # method looks up the data by the uuid,
  # if found render the json object
  #  Otherwise render an error object.
  # GET /blobs/:id
  def show
    @blob = Blob.find_by(id: params[:id])
    if @blob
      render json: @blob, status: :ok
    else
      render json: { error: "Blob not found." }, status: :not_found
    end
  end

  # POST /blobs
  def create
    if params[:file].present?
      file_content = params[:file].read
      base64_content = Base64.strict_encode64(file_content)
      begin
        # decode the Base64 content to ensure it's valid
        decoded_content = Base64.strict_decode64(base64_content)

        @blob = Blob.new(data: base64_content, size: file_content.bytesize)

        if @blob.save
          render json: @blob, status: :created
        else
          render json: @blob.errors, status: :unprocessable_entity
        end
      rescue ArgumentError => e
        # If the Base64 content is  invalid
        render json: { error: 'Invalid file content ' }, status: :bad_request
      end
    else
      render json: { error: 'File is missing' }, status: :bad_request
    end
  end

  # DELETE /blobs/:id
  def destroy
    @blobs.destroy
  end

  private

  def set_blob
    @blobs = Blob.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @blobs
  end

  def blob_params
    params.require(:blob).permit(:data)
  end
end
