class Api::V1::PostsController < ApplicationController
  require 'base64'
  before_action :authenticate_request
  before_action :set_post, only: [:show, :destroy]

  # index renders all the posts in the table
  # GET /posts
  def index
    @posts = Post.all
  end

  # GET /Post s/:id
  def show
    @post = Post.find_by(id: params[:id])
    if @post
      render 'show', formats: [:json], handlers: [:jbuilder], status: :ok
    else
      render json: { error: "Post not found." }, status: :not_found
    end
  end

  # POST /Posts
  def create
    if params[:file].present?
      content = params[:file].read
      base64_content = Base64.strict_encode64(content)
      begin
        # decode the Base64 content to ensure it's valid
        decoded_content = Base64.strict_decode64(base64_content)

        @post = Post.new(file_content: base64_content, size: content.bytesize)

        if @post.save
          render json: @post, status: :created
        else
          render json: @post.errors, status: :unprocessable_entity
        end
      rescue ArgumentError => e
        # If the Base64 content is invalid
        render json: { error: 'Invalid file content' }, status: :bad_request
      end
    else
      render json: { error: 'File is missing' }, status: :bad_request
    end
  end

  # DELETE /posts/:id
  def destroy
    @posts.destroy
  end

  private

  def set_post
    @posts = Post.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @posts
  end

  def post_params
    params.require(:post).permit(:file_content)
  end
end