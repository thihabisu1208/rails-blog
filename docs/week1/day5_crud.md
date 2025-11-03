# Week 1, Day 5: Post CRUD Operations

**What you're learning:** Rails controllers (CRUD actions), strong parameters, view forms, RESTful conventions

**Why this matters:** This is where you build the admin interface. CRUD (Create, Read, Update, Delete) is 90% of web development.

---

## Core Concept: REST & Rails Conventions

REST = Representational State Transfer. It's a pattern for designing APIs and web apps.

**Rails maps HTTP methods + paths to controller actions:**

| HTTP Method | Path            | Action  | Purpose                  |
| ----------- | --------------- | ------- | ------------------------ |
| GET         | /posts          | index   | List all posts           |
| GET         | /posts/:id      | show    | View one post            |
| GET         | /posts/new      | new     | Show form to create post |
| POST        | /posts          | create  | Save new post            |
| GET         | /posts/:id/edit | edit    | Show form to edit post   |
| PATCH       | /posts/:id      | update  | Save edited post         |
| DELETE      | /posts/:id      | destroy | Delete post              |

Rails handles routing automatically with `resources :posts`.

---

## Step 1: Create Posts Controller

```bash
rails generate controller Posts index show new create edit update destroy
```

This scaffolds the controller with all 7 actions (we'll fill them in).

---

## Step 2: Build the Controller

Edit `app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  # Skip auth for public pages
  skip_before_action :authenticate_user!, only: [:index, :show]

  # Before most actions, load the post
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts (admin page - list all posts)
  def index
    @posts = current_user.posts.order(created_at: :desc)
  end

  # GET /posts/:id (public page - view one post)
  def show
    @post = Post.find_by!(slug: params[:id])
    # Find by slug instead of ID (pretty URLs!)

    @post.increment!(:views_count)
    # Increment view counter
  end

  # GET /posts/new (admin - show form)
  def new
    @post = current_user.posts.build
    @categories = Category.all
  end

  # POST /posts (admin - create post)
  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to @post, notice: "Post created successfully"
    else
      @categories = Category.all
      render :new, status: :unprocessable_entity
    end
  end

  # GET /posts/:id/edit (admin - show edit form)
  def edit
    @categories = Category.all
  end

  # PATCH /posts/:id (admin - update post)
  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated successfully"
    else
      @categories = Category.all
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id (admin - delete post)
  def destroy
    @post.destroy
    redirect_to posts_url, notice: "Post deleted"
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id])
    # Only load posts owned by current_user (security!)
  end

  def post_params
    # Strong parameters - only allow these fields
    params.require(:post).permit(
      :title,
      :content,
      :excerpt,
      :featured_image_url,
      :is_published,
      category_ids: []  # Allow array of category IDs
    )
  end
end
```

**Key concepts:**

```ruby
skip_before_action :authenticate_user!, only: [:index, :show]
```

- Public can view posts, but only you can edit
- Other actions (edit, create, delete) require login

```ruby
@post = Post.find_by!(slug: params[:id])
```

- `find_by!` raises error if not found (vs. `find_by` which returns nil)
- `params[:id]` is the URL parameter (in `/posts/my-first-post`, it's `my-first-post`)

```ruby
@post.increment!(:views_count)
```

- Increment by 1 and save to database
- `!` means "save immediately"

```ruby
current_user.posts.build(post_params)
```

- Associates the post with current_user automatically
- `build` creates an object without saving
- `save` happens when you call `.save`

```ruby
params.require(:post).permit(:title, :content, ...)
```

- Strong parameters - security feature
- Only allows specified fields
- If someone tries to send other fields (like `admin: true`), they're ignored

```ruby
category_ids: []
```

- Allows an array of category IDs
- When form is submitted, Rails converts checkboxes to array

---

## Step 3: Create Views - Index (Admin Dashboard)

Create `app/views/posts/index.html.erb`:

```erb
<div class="container mx-auto py-8">
  <div class="flex justify-between items-center mb-8">
    <h1 class="text-3xl font-bold">My Posts</h1>
    <%= link_to "New Post", new_post_path, class: "bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700" %>
  </div>

  <% if @posts.any? %>
    <div class="overflow-x-auto">
      <table class="w-full border-collapse">
        <thead>
          <tr class="bg-gray-100 border-b">
            <th class="p-3 text-left">Title</th>
            <th class="p-3 text-left">Status</th>
            <th class="p-3 text-left">Views</th>
            <th class="p-3 text-left">Created</th>
            <th class="p-3 text-left">Actions</th>
          </tr>
        </thead>
        <tbody>
          <% @posts.each do |post| %>
            <tr class="border-b hover:bg-gray-50">
              <td class="p-3 font-medium"><%= post.title %></td>
              <td class="p-3">
                <span class="<%= post.is_published ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800' %> px-3 py-1 rounded text-sm">
                  <%= post.is_published ? "Published" : "Draft" %>
                </span>
              </td>
              <td class="p-3"><%= post.views_count %></td>
              <td class="p-3 text-sm text-gray-600"><%= post.created_at.strftime("%b %d, %Y") %></td>
              <td class="p-3 space-x-2">
                <%= link_to "Edit", edit_post_path(post), class: "text-blue-600 hover:underline" %>
                <%= link_to "Delete", post_path(post), method: :delete, data: { confirm: "Sure?" }, class: "text-red-600 hover:underline" %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
  <% else %>
    <div class="text-center py-12 text-gray-500">
      <p class="mb-4">No posts yet.</p>
      <%= link_to "Create your first post!", new_post_path, class: "text-blue-600 hover:underline" %>
    </div>
  <% end %>
</div>
```

**What's happening:**

- `link_to` helper creates links
- `new_post_path` generates `/posts/new`
- `edit_post_path(post)` generates `/posts/1/edit`
- `delete` method uses DELETE HTTP verb
- `data: { confirm: "Sure?" }` shows confirmation dialog

---

## Step 4: Create Views - New & Edit Forms

These use the same form, so let's create a partial.

Create `app/views/posts/_form.html.erb`:

```erb
<% if @post.errors.any? %>
  <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
    <p class="font-bold"><%= pluralize(@post.errors.count, "error") %> prohibited this post:</p>
    <ul class="list-disc list-inside">
      <% @post.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  </div>
<% end %>

<%= form_with(model: @post, local: true) do |form| %>
  <!-- Title -->
  <div class="mb-4">
    <%= form.label :title %>
    <%= form.text_field :title, class: "w-full border px-4 py-2 rounded", placeholder: "Your post title" %>
  </div>

  <!-- Excerpt -->
  <div class="mb-4">
    <%= form.label :excerpt %>
    <%= form.text_area :excerpt, rows: 3, class: "w-full border px-4 py-2 rounded", placeholder: "Summary for social sharing" %>
  </div>

  <!-- Featured Image URL -->
  <div class="mb-4">
    <%= form.label :featured_image_url, "Featured Image URL" %>
    <%= form.text_field :featured_image_url, class: "w-full border px-4 py-2 rounded", placeholder: "https://images.unsplash.com/..." %>
  </div>

  <!-- Content -->
  <div class="mb-4">
    <%= form.label :content %>
    <%= form.text_area :content, rows: 12, class: "w-full border px-4 py-2 rounded font-mono text-sm", placeholder: "Write your post (markdown supported)" %>
  </div>

  <!-- Categories -->
  <div class="mb-4">
    <%= form.label :category_ids, "Categories" %>
    <div class="space-y-2 mt-2">
      <% @categories.each do |category| %>
        <label class="flex items-center cursor-pointer">
          <%= form.check_box :category_ids, { multiple: true }, category.id, nil %>
          <span class="ml-2"><%= category.name %></span>
        </label>
      <% end %>
    </div>
  </div>

  <!-- Published Status -->
  <div class="mb-6">
    <label class="flex items-center cursor-pointer">
      <%= form.check_box :is_published %>
      <span class="ml-2 font-medium">Publish this post</span>
    </label>
  </div>

  <!-- Submit Button -->
  <div class="flex gap-2">
    <%= form.submit @post.persisted? ? "Update Post" : "Create Post", class: "bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700" %>
    <%= link_to "Cancel", admin_path, class: "px-6 py-2 border rounded hover:bg-gray-100" %>
  </div>
<% end %>
```

**Key concepts:**

```ruby
form.check_box :category_ids, { multiple: true }, category.id, nil
```

- `{ multiple: true }` — Creates checkboxes instead of radio buttons
- `category.id` — Value if checked
- `nil` — Value if unchecked

```ruby
@post.persisted?
```

- Returns true if post is saved in DB (not a new unsaved object)
- Used to show "Create" or "Update" button text

Now create `app/views/posts/new.html.erb`:

```erb
<div class="container mx-auto py-8 max-w-2xl">
  <h1 class="text-3xl font-bold mb-6">New Post</h1>
  <%= render "form" %>
</div>
```

And `app/views/posts/edit.html.erb`:

```erb
<div class="container mx-auto py-8 max-w-2xl">
  <h1 class="text-3xl font-bold mb-6">Edit Post</h1>
  <%= render "form" %>
</div>
```

---

## Step 5: Create Show View (Public)

Create `app/views/posts/show.html.erb`:

```erb
<article class="container mx-auto py-12 max-w-2xl">
  <header class="mb-8">
    <h1 class="text-4xl font-bold mb-4"><%= @post.title %></h1>

    <div class="flex items-center justify-between text-gray-600 text-sm mb-4">
      <span><%= @post.created_at.strftime("%B %d, %Y") %></span>
      <span><%= @post.views_count %> views</span>
    </div>

    <% if @post.categories.any? %>
      <div class="flex gap-2 flex-wrap">
        <% @post.categories.each do |category| %>
          <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded text-sm">
            <%= category.name %>
          </span>
        <% end %>
      </div>
    <% end %>
  </header>

  <% if @post.featured_image_url.present? %>
    <img src="<%= @post.featured_image_url %>" alt="<%= @post.title %>" class="w-full rounded-lg mb-8 max-h-96 object-cover">
  <% end %>

  <div class="prose prose-lg max-w-none">
    <%= simple_format(@post.content) %>
  </div>

  <div class="mt-8 text-center">
    <%= link_to "← Back to posts", root_path, class: "text-blue-600 hover:underline" %>
  </div>
</article>
```

**Note:** We're using `simple_format` for now (converts line breaks to `<br>`). We'll add markdown rendering in Week 2.

---

## Step 6: Test Everything

Start the server:

```bash
rails s
```

### Test the Flow

1. **Visit `http://localhost:3000/admin`** → Should see the admin dashboard (empty)
2. **Click "New Post"** → See the form
3. **Fill in the form:**
   - Title: "My First Post"
   - Excerpt: "This is my first post"
   - Content: "Hello world!"
   - Check some categories
   - Check "Publish this post"
4. **Click "Create Post"** → Should redirect to the post view
5. **Visit the post again** → View count should go from 1 to 2
6. **Click "Edit"** → Should show form with pre-filled values
7. **Go back to admin** → See the post in the table

---

## Recap: What You Learned

- ✅ RESTful routing (7 standard actions)
- ✅ Strong parameters for security
- ✅ Form helpers and view partials
- ✅ `find_by` vs `find_by!`
- ✅ Increment operations
- ✅ Associations in views

---

## Common Pitfalls

1. **"Post not saved"** — Check error messages in the form
2. **"Can't see categories"** — Did you run `rails db:seed`?
3. **"404 on `/admin`"** — Check routes - should be `get "/admin", to: "posts#index"`
4. **"Views not incrementing"** — Make sure you call `.increment!` (with exclamation mark)
5. **"Categories not saving"** — Verify `category_ids: []` is in strong parameters

---

## Ready for Day 6-7?

Once this is working, you'll create the public landing page.

Quick reflection:

1. Why do we need strong parameters?
2. How does finding by slug instead of ID change the URLs?
3. Why use a partial for the form?

If these make sense, move on! 🎉
