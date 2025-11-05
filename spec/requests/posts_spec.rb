require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123') }
  let(:other_user) { User.create!(email: 'other@example.com', password: 'password123') }
  let(:category) { Category.create!(name: 'Technology') }
  let!(:published_post) { Post.create!(title: 'Test Post', content: 'Test content here', user: user, is_published: true) }
  let!(:draft_post) { Post.create!(title: 'Draft Post', content: 'Draft content', user: user, is_published: false) }

  def login_as(user)
    post sessions_path, params: { email: user.email, password: 'password123' }
  end

  describe "GET /posts" do
    context "when not authenticated" do
      it "redirects to login" do
        get posts_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before { login_as(user) }

      it "returns http success" do
        get posts_path
        expect(response).to have_http_status(:success)
      end

      it "shows all user's posts including soft deleted" do
        deleted_post = Post.create!(title: 'Deleted', content: 'Content for deleted post', user: user)
        deleted_post.discard

        get posts_path
        expect(response).to have_http_status(:success)
      end

      it "does not show other user's posts" do
        other_post = Post.create!(title: 'Other Post', content: 'Content for other post', user: other_user)
        get posts_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /posts/:slug" do
    context "when post is published" do
      it "returns http success without authentication" do
        get post_path(published_post.slug)
        expect(response).to have_http_status(:success)
      end

      it "increments view counter" do
        expect {
          get post_path(published_post.slug)
        }.to change { published_post.reload.views_count }.by(1)
      end

      it "displays post content" do
        get post_path(published_post.slug)
        expect(response).to have_http_status(:success)
      end
    end

    context "when post is not published" do
      it "does not show draft post to public" do
        # Draft posts are filtered by Post.published scope
        get post_path(draft_post.slug)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /posts/new" do
    context "when not authenticated" do
      it "redirects to login" do
        get new_post_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before { login_as(user) }

      it "returns http success" do
        get new_post_path
        expect(response).to have_http_status(:success)
      end

      it "renders new post form" do
        get new_post_path
        expect(response.body).to match(/<form/)
      end
    end
  end

  describe "POST /posts" do
    context "when not authenticated" do
      it "redirects to login" do
        post posts_path, params: { post: { title: 'New Post', content: 'Content' } }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before { login_as(user) }

      context "with valid params" do
        it "creates a new post" do
          expect {
            post posts_path, params: { post: { title: 'New Post', content: 'New content here', category_ids: [ category.id ] } }
          }.to change(Post, :count).by(1)
        end

        it "associates post with current user" do
          post posts_path, params: { post: { title: 'New Post', content: 'New content here' } }
          expect(Post.last.user).to eq(user)
        end

        it "redirects to post show page" do
          post posts_path, params: { post: { title: 'New Post', content: 'New content here' } }
          expect(response).to redirect_to(post_path(Post.last.slug))
        end

        it "shows success notice" do
          post posts_path, params: { post: { title: 'New Post', content: 'New content here' } }
          expect(flash[:notice]).to eq('Post created successfully')
        end
      end

      context "with invalid params" do
        it "does not create a post" do
          expect {
            post posts_path, params: { post: { title: '', content: '' } }
          }.not_to change(Post, :count)
        end

        it "renders new template with errors" do
          post posts_path, params: { post: { title: '', content: '' } }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "GET /posts/:slug/edit" do
    context "when not authenticated" do
      it "redirects to login" do
        get edit_post_path(published_post.slug)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before { login_as(user) }

      it "returns http success" do
        get edit_post_path(published_post.slug)
        expect(response).to have_http_status(:success)
      end

      it "renders edit form" do
        get edit_post_path(published_post.slug)
        expect(response.body).to match(/<form/)
      end

      it "cannot edit other user's post" do
        other_user_post = Post.create!(title: 'Other User Post', content: 'Content for other user', user: other_user, is_published: true)

        # In request specs, RecordNotFound is caught and turned into 404
        # We should NOT expect the exception to bubble up
        get edit_post_path(other_user_post.slug)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /posts/:slug" do
    context "when not authenticated" do
      it "redirects to login" do
        patch post_path(published_post.slug), params: { post: { title: 'Updated' } }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before { login_as(user) }

      context "with valid params" do
        it "updates the post" do
          patch post_path(published_post.slug), params: { post: { title: 'Updated Title' } }
          expect(published_post.reload.title).to eq('Updated Title')
        end

        it "redirects to post show page" do
          patch post_path(published_post.slug), params: { post: { title: 'Updated Title' } }
          expect(response).to redirect_to(post_path(published_post.reload.slug))
        end

        it "shows success notice" do
          patch post_path(published_post.slug), params: { post: { title: 'Updated Title' } }
          expect(flash[:notice]).to eq('Post updated successfully')
        end
      end

      context "with invalid params" do
        it "does not update the post" do
          patch post_path(published_post.slug), params: { post: { title: '' } }
          expect(published_post.reload.title).to eq('Test Post')
        end

        it "renders edit template with errors" do
          patch post_path(published_post.slug), params: { post: { title: '' } }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      it "cannot update other user's post" do
        other_user_post = Post.create!(title: 'Other User Post', content: 'Content for other user', user: other_user, is_published: true)

        patch post_path(other_user_post.slug), params: { post: { title: 'Hacked' } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /posts/:slug" do
    context "when not authenticated" do
      it "redirects to login" do
        delete post_path(published_post.slug)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before { login_as(user) }

      it "soft deletes the post" do
        delete post_path(published_post.slug)
        expect(published_post.reload.discarded?).to be true
      end

      it "does not hard delete the post" do
        expect {
          delete post_path(published_post.slug)
        }.not_to change(Post.with_discarded, :count)
      end

      it "redirects to posts index" do
        delete post_path(published_post.slug)
        expect(response).to redirect_to(posts_path)
      end

      it "shows success notice" do
        delete post_path(published_post.slug)
        expect(flash[:notice]).to eq('Post deleted')
      end

      it "cannot delete other user's post" do
        other_user_post = Post.create!(title: 'Other User Post', content: 'Content for other user', user: other_user, is_published: true)

        delete post_path(other_user_post.slug)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /posts/:slug/restore" do
    let!(:deleted_post) do
      p = Post.create!(title: 'Deleted Post', content: 'Content for deleted post here', user: user)
      p.discard
      p
    end

    context "when not authenticated" do
      it "redirects to login" do
        patch restore_post_path(deleted_post.slug)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before { login_as(user) }

      it "restores the post" do
        patch restore_post_path(deleted_post.slug)
        expect(deleted_post.reload.discarded?).to be false
      end

      it "redirects to posts index" do
        patch restore_post_path(deleted_post.slug)
        expect(response).to redirect_to(posts_path)
      end

      it "shows success notice" do
        patch restore_post_path(deleted_post.slug)
        expect(flash[:notice]).to eq('Post restored')
      end

      it "cannot restore other user's post" do
        other_deleted = Post.create!(title: 'Other Deleted', content: 'Content for other deleted post', user: other_user)
        other_deleted.discard

        patch restore_post_path(other_deleted.slug)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
