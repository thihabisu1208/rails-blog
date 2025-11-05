class PostsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show ]
  before_action :set_post, only: [ :edit, :update, :destroy ]

  def index
    # Show all posts including soft deleted ones
    # Eager load categories to prevent N+1 queries
    @posts = current_user.posts.with_discarded.includes(:categories).order(created_at: :desc)
  end

  def show
    # Only show published posts to public
    @post = Post.published.find_by!(slug: params[:id])

    # Atomic increment to prevent race conditions
    # This executes: UPDATE posts SET views_count = views_count + 1 WHERE id = ?
    Post.increment_counter(:views_count, @post.id)
  end

  def new
    @post = current_user.posts.build
    @categories = Category.all
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to @post, notice: "Post created successfully"
    else
      @categories = Category.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.all
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated successfully"
    else
      @categories = Category.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.discard
    redirect_to posts_path, notice: "Post deleted"
  end

  def restore
    @post = current_user.posts.with_discarded.find_by!(slug: params[:id])
    @post.undiscard
    redirect_to posts_path, notice: "Post restored"
  end

  private

  def set_post
    @post = current_user.posts.find_by!(slug: params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :excerpt, :featured_image_url, :is_published, category_ids: [])
  end
end
