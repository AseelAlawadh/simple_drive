class Api::V1::BlobsController < ApplicationController
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
    @blobs = Blob.new(
      data: post_params[:data])
    if @blobs.save
      # render json: @blobs, status: :created, location:api_v1_blob_url(@blob)
      render json: @blobs, status: :created
    else
      render json: @blobs.errors, status: :unprocessable_entity
    end
  end

  # DELETE /blobs/:id
  def destroy
    @blobs.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_blob
    @blobs = Blob.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @blobs
  end

  # Only allow a trusted parameter "white list" through.
  def post_params
    params.require(:blob).permit(:data,)
  end
end
