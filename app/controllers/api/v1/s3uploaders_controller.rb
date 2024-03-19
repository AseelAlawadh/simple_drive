class Api::V1::S3uploadersController < ApplicationController

  require 'base64'
  skip_before_action :authenticate_request, only: [:index, :show]

  # index renders all the s3s in the table
  # GET /s3s
  def index
    access_key = ENV['OCI_ACCESS_KEY_ID']
    secret_key = ENV['OCI_SECRET_ACCESS_KEY']
    bucket = ENV['OCI_BUCKET_NAME']
    region = ENV['OCI_REGION']
    endpoint = ENV['OCI_ENDPOINT']
    namespace = ENV['OCI_NAMESPACE']

    client = ObjectStorageUploader.new(access_key, secret_key, bucket, region, endpoint, namespace)
    # print the list of objects in the bucket
    result = client.list_objects
    print "result = #{:result}"
    render json: result, status: :ok
  end

  # GET /s3s/:id
  def show
    print 'showing s3 object'
    print params[:id]
    access_key = ENV['OCI_ACCESS_KEY_ID']
    secret_key = ENV['OCI_SECRET_ACCESS_KEY']
    bucket = ENV['OCI_BUCKET_NAME']
    region = ENV['OCI_REGION']
    endpoint = ENV['OCI_ENDPOINT']
    namespace = ENV['OCI_NAMESPACE']

    client = ObjectStorageUploader.new(access_key, secret_key, bucket, region, endpoint, namespace)
    result = client.get_object(params[:id])

    render json: result, status: :ok

  end

  private

  def set_s3
    @s3s = S3.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @s3s
  end

  def s3_params
    params.require(:s3).permit(:file_content)
  end
end
