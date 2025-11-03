# Week 2, Day 1-2: Social Sharing Meta Tags

**What you're learning:** SEO, Open Graph protocol, meta tags, Rails view helpers

**Why this matters:** When someone shares your blog post on Twitter/Facebook, the preview shows your title, image, and description. This requires proper meta tags.

---

## Core Concept: How Social Sharing Works

When you paste a link on Twitter:

1. Twitter fetches the URL
2. Reads the `<meta property="og:*">` tags in the HTML
3. Shows a preview card with title, description, image
4. User sees it, clicks it, visits your blog

Without these tags, you get a blank card. With them, it looks professional.

---

## Step 1: Add Meta Tags to Layout

Edit `app/views/layouts/application.html.erb`:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title><%= page_title %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="description" content="<%= page_description %>">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= importmap_tags %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>

    <!-- Open Graph Tags (for Facebook, LinkedIn, etc.) -->
    <meta property="og:type" content="<%= og_type %>">
    <meta property="og:title" content="<%= og_title %>">
    <meta property="og:description" content="<%= og_description %>">
    <meta property="og:url" content="<%= request.url %>">
    <% if og_image.present? %>
      <meta property="og:image" content="<%= og_image %>">
      <meta property="og:image:alt" content="<%= og_image_alt %>">
    <% end %>

    <!-- Twitter Card Tags -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="<%= og_title %>">
    <meta name="twitter:description" content="<%= og_description %>">
    <% if og_image.present? %>
      <meta name="twitter:image" content="<%= og_image %>">
    <% end %>
  </head>

  <body class="bg-white">
    <!-- Rest of layout stays the same -->
    ...
  </body>
</html>
```

---

## Step 2: Create Helper Methods

Edit `app/helpers/application_helper.rb`:

```ruby
module ApplicationHelper
  def page_title
    if @post.present?
      "#{@post.title} - DevLog"
    else
      "DevLog - Tech, Design & Creative Engineering"
    end
  end

  def page_description
    if @post.present?
      @post.excerpt
    else
      "Thoughts on tech, design, and creative engineering"
    end
  end

  # Open Graph Tags
  def og_type
    @post.present? ? "article" : "website"
  end

  def og_title
    @post&.title || "DevLog"
  end

  def og_description
    @post&.excerpt || "Thoughts on tech, design, and creative engineering"
  end

  def og_image
    @post&.featured_image_url
  end

  def og_image_alt
    @post&.title || "DevLog"
  end
end
```

**What's happening:**

```ruby
def og_title
  @post&.title || "DevLog"
end
```

- If `@post` exists and has a title, use it
- Otherwise, use "DevLog"
- The `&.` is safe navigation (returns nil if @post is nil)

---

## Step 3: Test Social Sharing

### Option 1: Facebook Sharing Debugger

1. Go to https://developers.facebook.com/tools/debug/
2. Enter your localhost URL (won't work - Facebook can't reach localhost)
3. Later, after deployment, test with your real domain

### Option 2: Check HTML Source

Visit your post page and view the HTML source:

- Right-click → "View Page Source"
- Search for `og:title`
- Should see your post title

### Option 3: Twitter Card Validator

1. Go to https://cards-dev.twitter.com/validator
2. After deployment, enter your post URL
3. See preview

---

## Step 4: Add Share Buttons (Optional)

If you want to add social share buttons to posts, edit `app/views/posts/show.html.erb`:

```erb
<article class="container mx-auto py-12 max-w-2xl">
  <!-- Existing content -->
  ...

  <!-- Share Buttons -->
  <div class="mt-8 pt-8 border-t">
    <p class="text-sm text-gray-600 mb-4">Share this post:</p>

    <div class="flex gap-4">
      <!-- Twitter Share -->
      <a
        href="https://twitter.com/intent/tweet?url=<%= request.url %>&text=<%= @post.title %>"
        target="_blank"
        rel="noopener noreferrer"
        class="text-blue-400 hover:text-blue-600"
      >
        Twitter
      </a>

      <!-- Facebook Share -->
      <a
        href="https://www.facebook.com/sharer/sharer.php?u=<%= request.url %>"
        target="_blank"
        rel="noopener noreferrer"
        class="text-blue-600 hover:text-blue-800"
      >
        Facebook
      </a>

      <!-- LinkedIn Share -->
      <a
        href="https://www.linkedin.com/sharing/share-offsite/?url=<%= request.url %>"
        target="_blank"
        rel="noopener noreferrer"
        class="text-blue-700 hover:text-blue-900"
      >
        LinkedIn
      </a>
    </div>
  </div>
</article>
```

**Note:** These are simple link shares. When clicked, they open share dialogs on the respective platforms.

---

## Step 5: Verify It Works

1. Create a new post with:

   - Title: "Testing Social Sharing"
   - Excerpt: "This is a test"
   - Featured Image: A valid Unsplash URL
   - Published: yes

2. Visit the post

3. View source (Cmd+U on Mac, Ctrl+U on Windows)

4. Search for `og:title` - should see your post title

5. After deployment, share the URL on Twitter - should show a nice preview

---

## Recap: What You Learned

- ✅ Open Graph protocol
- ✅ Meta tags for social sharing
- ✅ Helper methods for DRY view code
- ✅ Safe navigation operator `&.`
- ✅ Social share links

---

## Common Pitfalls

1. **"Meta tags not showing"** — Check view source, not the rendered page
2. **"Excerpt empty"** — Make sure you filled in the excerpt field
3. **"Image not showing in preview"** — Verify the Unsplash URL is valid and public

---

## Next: Day 3-4 - Three.js Landing Hero

Ready to add some creative 3D? Move on to `day3-4_threejs.md`!
