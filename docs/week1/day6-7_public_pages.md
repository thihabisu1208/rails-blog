# Week 1, Day 6-7: Public Pages & Landing Page

**What you're learning:** Public vs. admin pages, query optimization, Rails conventions, basic HTML/ERB templating

**Why this matters:** This is where users actually experience your blog. A good landing page draws people in.

---

## Core Concept: Public vs. Admin

Your app has two distinct areas:

**Admin:**

- `/admin` — Dashboard (list all posts, including drafts)
- `/posts/new`, `/posts/1/edit` — Forms for you
- Users: Just you
- Auth: Required

**Public:**

- `/` — Landing page (featured posts)
- `/posts/my-first-post` — Individual posts (published only)
- Users: Everyone
- Auth: Not required

We've already built the admin area. Now we're building the public experience.

---

## Step 1: Update Pages Controller

Edit `app/controllers/pages_controller.rb`:

```ruby
class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  # Landing page is public

  def landing
    @featured_posts = Post.published.by_views.limit(6)
    # Get 6 most-viewed published posts

    @categories = Category.all
    # Get all categories for a sidebar or filter
  end
end
```

**Key concepts:**

```ruby
Post.published.by_views.limit(6)
```

- This chains scopes we defined in the Post model
- `published` → where is_published = true
- `by_views` → order by views_count descending
- `limit(6)` → only get 6 results
- This is called "scope chaining" and it's very Rails-like

---

## Step 2: Create Beautiful Landing Page View

Edit `app/views/pages/landing.html.erb`:

```erb
<div class="min-h-screen">
  <!-- Hero Section -->
  <section class="bg-gradient-to-b from-gray-900 to-gray-800 text-white py-20">
    <div class="container mx-auto px-4 text-center">
      <h1 class="text-5xl md:text-6xl font-bold mb-4">DevLog</h1>
      <p class="text-xl md:text-2xl text-gray-300 mb-8">
        Thoughts on tech, design, and creative engineering
      </p>
      <a href="#posts" class="inline-block bg-blue-600 hover:bg-blue-700 transition px-8 py-3 rounded-lg font-medium">
        Read Articles
      </a>
    </div>
  </section>

  <!-- Featured Posts -->
  <section id="posts" class="bg-white py-16">
    <div class="container mx-auto px-4">
      <h2 class="text-3xl md:text-4xl font-bold mb-12">Latest Articles</h2>

      <% if @featured_posts.any? %>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <% @featured_posts.each do |post| %>
            <%= render "post_card", post: post %>
          <% end %>
        </div>
      <% else %>
        <div class="text-center py-12 text-gray-500">
          <p class="text-lg">No posts yet. Check back soon!</p>
        </div>
      <% end %>
    </div>
  </section>
</div>
```

---

## Step 3: Create Post Card Partial

Create `app/views/pages/_post_card.html.erb`:

```erb
<article class="rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-shadow duration-300">
  <!-- Featured Image -->
  <% if post.featured_image_url.present? %>
    <div class="relative h-48 overflow-hidden bg-gray-100">
      <img
        src="<%= post.featured_image_url %>"
        alt="<%= post.title %>"
        class="w-full h-full object-cover hover:scale-105 transition-transform duration-300"
      >
    </div>
  <% end %>

  <!-- Card Content -->
  <div class="p-6">
    <!-- Categories -->
    <% if post.categories.any? %>
      <div class="flex gap-2 flex-wrap mb-3">
        <% post.categories.limit(2).each do |category| %>
          <span class="bg-blue-100 text-blue-800 text-xs font-semibold px-2 py-1 rounded">
            <%= category.name %>
          </span>
        <% end %>
      </div>
    <% end %>

    <!-- Title -->
    <h3 class="text-xl font-bold mb-2 line-clamp-2">
      <%= link_to post.title, post_path(post.slug), class: "text-gray-900 hover:text-blue-600 transition" %>
    </h3>

    <!-- Excerpt -->
    <p class="text-gray-600 mb-4 line-clamp-3">
      <%= post.excerpt.present? ? post.excerpt : truncate(post.content, length: 150) %>
    </p>

    <!-- Meta Info -->
    <div class="flex justify-between items-center text-sm text-gray-500 pt-4 border-t">
      <span><%= post.created_at.strftime("%b %d, %Y") %></span>
      <span><%= post.views_count %> views</span>
    </div>
  </div>
</article>
```

**CSS Classes Explained:**

```erb
line-clamp-2
```

- Tailwind utility: Truncate text to 2 lines with ellipsis
- `line-clamp-3` = 3 lines max

```erb
hover:scale-105 transition-transform duration-300
```

- `hover:scale-105` — When hovering, scale to 105% (1.05x)
- `transition-transform` — Animate the scale change
- `duration-300` — Animation takes 300ms

```erb
truncate(post.content, length: 150)
```

- Rails helper: If no excerpt, use first 150 chars of content

---

## Step 4: Create Routes

Update `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  root "pages#landing"
  # Homepage is the landing page

  # Session routes
  get "/login", to: "sessions#new"
  post "/sessions", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # Admin dashboard
  get "/admin", to: "posts#index"

  # Posts
  resources :posts

  # Categories
  resources :categories, only: [:index, :create, :destroy]
end
```

---

## Step 5: Update Layout Navigation

Edit `app/views/layouts/application.html.erb`:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>DevLog</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="description" content="Thoughts on tech, design, and creative engineering">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= importmap_tags %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  </head>

  <body class="bg-white">
    <!-- Navigation -->
    <nav class="bg-gray-900 text-white sticky top-0 z-50 shadow">
      <div class="container mx-auto px-4 py-4 flex justify-between items-center">
        <!-- Logo -->
        <%= link_to "DevLog", root_path, class: "text-2xl font-bold" %>

        <!-- Navigation Links -->
        <div class="flex items-center space-x-6">
          <% if current_user %>
            <%= link_to "Admin", admin_path, class: "hover:text-gray-300 transition" %>
            <%= link_to "Logout", logout_path, method: :delete, class: "text-red-400 hover:text-red-300 transition" %>
          <% else %>
            <%= link_to "Login", login_path, class: "hover:text-gray-300 transition" %>
          <% end %>
        </div>
      </div>
    </nav>

    <!-- Flash Messages -->
    <% if notice || alert %>
      <div class="container mx-auto px-4 mt-4">
        <% if notice %>
          <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
            <%= notice %>
          </div>
        <% end %>
        <% if alert %>
          <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            <%= alert %>
          </div>
        <% end %>
      </div>
    <% end %>

    <!-- Main Content -->
    <main>
      <%= yield %>
    </main>

    <!-- Footer -->
    <footer class="bg-gray-900 text-gray-400 py-8 mt-16">
      <div class="container mx-auto px-4 text-center">
        <p>&copy; 2024 DevLog. All rights reserved.</p>
      </div>
    </footer>
  </body>
</html>
```

---

## Step 6: Security - Fix Posts Controller

Remember in the `show` action, we're finding by slug and incrementing views. But we should also make sure we only show _published_ posts to the public.

Edit `app/controllers/posts_controller.rb` - Update the `show` action:

```ruby
def show
  @post = Post.published.find_by!(slug: params[:id])
  # Changed: Add .published scope so unpublished posts aren't visible

  @post.increment!(:views_count)
end
```

This way, if you have draft posts, they won't be visible publicly.

---

## Step 7: Test the Complete Flow

Start server:

```bash
rails s
```

### Test Checklist

- [ ] Visit `http://localhost:3000` → See landing page
- [ ] Posts show featured images
- [ ] Posts show categories
- [ ] Click a post → See individual post view
- [ ] View count increments each time you visit
- [ ] Unpublished posts don't show on landing page
- [ ] Click "Admin" → See dashboard
- [ ] Create a new published post → Shows on landing page
- [ ] Create a draft post → Doesn't show on landing page
- [ ] Click "Logout" → Returns to public landing page

---

## Performance Consideration: N+1 Queries

Later, when you have many posts, Rails will run a separate query for each post's categories. This is called an "N+1 query problem."

To fix it, add to the Pages controller:

```ruby
def landing
  @featured_posts = Post.published
    .includes(:categories, :user)  # ← Load categories in one query
    .by_views
    .limit(6)

  @categories = Category.all
end
```

This is a hint for later—Rails will automatically fetch all categories for all posts in one query instead of multiple. You don't need to worry about this now, but it's good to know.

---

## Recap: What You Learned

- ✅ Scope chaining
- ✅ Query optimization mindset
- ✅ Partial views for reusability
- ✅ Tailwind CSS for styling
- ✅ Public vs. admin separation
- ✅ Security (publishing status)
- ✅ Responsive design

---

## Common Pitfalls

1. **"Posts not showing"** — Are they published? Check `is_published = true`
2. **"Images not loading"** — Make sure Unsplash URLs are valid
3. **"Can't see admin link"** — Are you logged in?
4. **"404 on landing page"** — Check routes - `root "pages#landing"`
5. **"Categories aren't showing"** — Did you add categories to the post?

---

## Reflection

Think about these:

1. Why do we scope queries (`Post.published`) instead of filtering in the view?
2. What would happen if someone tried to access `/posts/draft-post-slug` when it's unpublished?
3. How would you add a "featured" flag to show certain posts first?

---

## You've Completed Week 1! 🎉

Your blog now has:

- ✅ Secure authentication
- ✅ Admin dashboard
- ✅ Post management with multiple categories
- ✅ View tracking
- ✅ Beautiful landing page
- ✅ Public post viewing

**Week 2** adds:

- Social sharing meta tags
- Three.js 3D landing hero
- Markdown support
- Syntax highlighting
- Testing & deployment

Take a break, then move on to `docs/week2/day1-2_social_sharing.md`!
