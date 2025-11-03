# Day 5: Post CRUD Operations Summary

## What We Built

A complete CRUD interface for managing blog posts with soft delete functionality, Turbo confirmations, and a clean admin dashboard.

---

## 1. Routes Configuration

### File Modified:
- `config/routes.rb`

### What we added:

```ruby
resources :posts do
  member do
    patch :restore
  end
end
```

**What it does:**
- Creates 7 RESTful routes (index, show, new, create, edit, update, destroy)
- Adds custom `restore` route for soft delete restoration

**Generated routes:**
```
GET    /posts          → posts#index
GET    /posts/:id      → posts#show
GET    /posts/new      → posts#new
POST   /posts          → posts#create
GET    /posts/:id/edit → posts#edit
PATCH  /posts/:id      → posts#update
DELETE /posts/:id      → posts#destroy
PATCH  /posts/:id/restore → posts#restore
```

---

## 2. PostsController

### Generated:
```bash
rails generate controller Posts
```

### File Created:
- `app/controllers/posts_controller.rb`

### What it does:

**Key methods:**

1. **index** - Admin dashboard listing all posts (including soft deleted)
2. **show** - Public post view, finds by slug, increments view count
3. **new** - Shows form for new post, loads categories
4. **create** - Saves new post with associations
5. **edit** - Shows edit form
6. **update** - Updates existing post
7. **destroy** - Soft deletes post (uses discard)
8. **restore** - Restores soft deleted post

**Security features:**
- `skip_before_action :authenticate_user!, only: [:show]` - Only show is public
- `set_post` finds posts by slug (SEO-friendly URLs)
- Strong parameters prevent mass assignment attacks

### Strong Parameters:

```ruby
def post_params
  params.require(:post).permit(:title, :content, :excerpt, :featured_image_url, :is_published, category_ids: [])
end
```

**Why `category_ids: []`:**
- Allows array of category IDs from checkboxes
- Rails automatically creates/destroys PostCategory join records

---

## 3. Views

### Files Created:
- `app/views/posts/index.html.erb` - Admin dashboard
- `app/views/posts/_form.html.erb` - Reusable form partial
- `app/views/posts/new.html.erb` - New post page
- `app/views/posts/edit.html.erb` - Edit post page
- `app/views/posts/show.html.erb` - Public post view

### Admin Index Features:
- Table showing all posts (active + deleted)
- Status badges (Published/Draft)
- State badges (Active/Deleted)
- View count tracking
- Conditional actions:
  - Active posts: Edit + Delete buttons
  - Deleted posts: Restore button
- Grayed-out styling for deleted posts
- Deletion timestamp display

### Form Features:
- Error display with validation messages
- Title, excerpt, content fields
- Featured image URL input
- Category checkboxes (many-to-many)
- Publish checkbox
- Dynamic submit button ("Create" vs "Update")
- `form_with(model: @post)` automatically handles new vs edit

### Show Page Features:
- Full post display
- Featured image
- Category tags
- View counter
- Publication date
- Content formatting with `simple_format`

---

## 4. Soft Delete Implementation

### Gem Added:

**Gemfile:**
```ruby
gem "discard", "~> 1.3"
```

### Migration:
```bash
rails generate migration AddDiscardedAtToPosts discarded_at:datetime:index
rails db:migrate
```

### Model Update:

**app/models/post.rb:**
```ruby
include Discard::Model
```

### Controller Changes:
```ruby
# Show all posts including discarded
@posts = current_user.posts.with_discarded.order(created_at: :desc)

# Soft delete
@post.discard

# Restore
@post.undiscard
```

**Why soft delete?**
- Data not permanently lost
- Can restore accidentally deleted posts
- Audit trail (knows when deleted)
- Safer than hard delete

---

## 5. RuboCop Pre-Commit Hook

### File Created:
- `.git/hooks/pre-commit`

### What it does:
Automatically enforces code style on every commit:
1. Finds staged Ruby files (`.rb`, `.rake`)
2. Runs `bundle exec rubocop -A` (auto-fixes violations)
3. Re-stages auto-fixed files
4. Blocks commit if unfixable violations exist

### Usage:

**Normal commit (hook runs automatically):**
```bash
git add .
git commit -m "Your message"
```

**Skip hook if needed:**
```bash
git commit --no-verify -m "Your message"
```

**Why pre-commit hooks?**
- Maintains consistent code style across the project
- Catches style issues before they enter git history
- Auto-fixes most violations automatically
- No manual RuboCop runs needed

**RuboCop style guide:**
Rails 8 uses `rubocop-rails-omakase` (Basecamp's Ruby style guide)

---

## 6. Turbo & JavaScript Setup

### Problem Discovered:
Turbo confirmations not working, JavaScript not loaded at all.

### Files Modified:
- `app/views/layouts/application.html.erb`
- `config/importmap.rb` (created)

### Setup Commands:
```bash
bin/rails importmap:install
bin/rails turbo:install
```

### Layout Update:

Added to `<head>`:
```erb
<%= javascript_importmap_tags %>
```

**What this does:**
- Loads JavaScript via importmap
- Imports Turbo for SPA-like behavior
- Enables Turbo confirmations

### Correct Delete Link Syntax:

```erb
<%= link_to "Delete", post_path(post), data: { turbo_method: :delete, turbo_confirm: "Are you sure?" }, class: "text-red-600 hover:underline" %>
```

**Key attributes:**
- `turbo_method: :delete` - Uses DELETE HTTP method
- `turbo_confirm: "..."` - Shows native browser confirm dialog

---

## 6. Slug-Based URLs

### Model Update:

**app/models/post.rb:**
```ruby
def to_param
  slug
end
```

**What it does:**
- Overrides Rails default (ID-based URLs)
- `/posts/my-first-post` instead of `/posts/1`
- Better for SEO
- More readable

### Controller Adjustments:

```ruby
# Find by slug instead of ID
@post = Post.find_by!(slug: params[:id])
@post = current_user.posts.find_by!(slug: params[:id])
```

**Why `find_by!` with `!`:**
- Raises `ActiveRecord::RecordNotFound` if not found
- Rails automatically renders 404 page
- Without `!`, returns `nil` (causes errors later)

---

## Database Schema Updates

### New Column Added:
```
discarded_at  datetime (indexed)
```

**Used by discard gem for soft delete tracking.**

---

## File Tree After Day 5

```
app/
├── controllers/
│   └── posts_controller.rb (new - 8 actions)
├── models/
│   └── post.rb (updated - added Discard::Model, to_param)
├── views/
│   └── posts/
│       ├── index.html.erb (new - admin dashboard)
│       ├── _form.html.erb (new - shared form)
│       ├── new.html.erb (new - create page)
│       ├── edit.html.erb (new - edit page)
│       └── show.html.erb (new - public view)
└── views/layouts/
    └── application.html.erb (updated - added JS imports)

config/
├── routes.rb (updated - added posts resources)
└── importmap.rb (new - JS module mapping)

db/
└── migrate/
    └── [timestamp]_add_discarded_at_to_posts.rb (new)

.git/
└── hooks/
    └── pre-commit (new - RuboCop enforcement)

Gemfile (updated - added discard gem)
```

---

## Mistakes Made & How We Fixed Them

### Mistake 1: Authentication on Index
**Problem:** `undefined method 'posts' for nil` - current_user was nil

**Why it happened:**
- Index action had `skip_before_action :authenticate_user!`
- But index is the admin dashboard, needs login

**Fix:**
```ruby
# Before:
skip_before_action :authenticate_user!, only: [:index, :show]

# After:
skip_before_action :authenticate_user!, only: [:show]
```

---

### Mistake 2: to_param Method Visibility
**Problem:** `private method 'to_param' called`

**Why it happened:**
- Placed `to_param` after `private` keyword
- `to_param` must be public for Rails to call it

**Fix:**
Moved `to_param` method **before** the `private` keyword.

---

### Mistake 3: Finding by ID Instead of Slug
**Problem:** `Couldn't find Post with 'id'="my-first-post"`

**Why it happened:**
- `to_param` returns slug
- But `find(params[:id])` expects numeric ID

**Fix:**
```ruby
# Before:
@post = current_user.posts.find(params[:id])

# After:
@post = current_user.posts.find_by!(slug: params[:id])
```

---

### Mistake 4: Turbo Confirmations Not Working
**Problem:** Delete button went directly to page without confirmation modal

**Root cause:**
- JavaScript/Turbo not loaded at all
- Missing `config/importmap.rb`
- Missing `javascript_importmap_tags` in layout

**Debugging steps:**
1. Tried different `turbo_confirm` syntax (didn't work)
2. Checked if Turbo gem was installed (yes)
3. Looked for `config/importmap.rb` (missing!)
4. Realized JS wasn't loading at all

**Fix:**
```bash
bin/rails importmap:install  # Creates importmap config
bin/rails turbo:install      # Sets up Turbo
```

Then added to layout:
```erb
<%= javascript_importmap_tags %>
```

**Final working syntax:**
```erb
<%= link_to "Delete", post_path(post),
    data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %>
```

---

## Key Concepts You Should Understand

### 1. RESTful Routing
Rails convention for CRUD operations:
- **GET** /posts → list all (index)
- **GET** /posts/:id → view one (show)
- **GET** /posts/new → form for new (new)
- **POST** /posts → create (create)
- **GET** /posts/:id/edit → form to edit (edit)
- **PATCH** /posts/:id → update (update)
- **DELETE** /posts/:id → delete (destroy)

### 2. Strong Parameters
Security feature preventing mass assignment:

```ruby
params.require(:post).permit(:title, :content, category_ids: [])
```

**Without this:** Users could set any attribute (like `admin: true`)
**With this:** Only specified fields are allowed

### 3. Form Partials
Reusable forms shared between new and edit:

```erb
<%= render "form" %>
```

**Why?** DRY principle - don't repeat form HTML

### 4. View Count Increment

```ruby
@post.increment!(:views_count)
```

**What it does:**
- Adds 1 to views_count
- Saves immediately to database
- `!` means "save now" (without it, just changes in memory)

### 5. Soft Delete Pattern

**Hard delete:** `post.destroy` - Gone forever
**Soft delete:** `post.discard` - Sets `discarded_at` timestamp

**Queries:**
- `Post.all` - Only active posts
- `Post.with_discarded` - All posts (active + deleted)
- `Post.discarded` - Only deleted posts

### 6. Turbo Confirmations

Native browser dialog using `data-turbo-confirm`:

```erb
data: { turbo_confirm: "Are you sure?" }
```

**Requires:**
- Turbo installed and loaded
- `javascript_importmap_tags` in layout
- Proper importmap configuration

---

## Rails Magic Explained

### 1. form_with Auto-Detection

```ruby
<%= form_with(model: @post) do |form| %>
```

**How it knows new vs edit:**
- If `@post.persisted?` is false → POST to `/posts` (create)
- If `@post.persisted?` is true → PATCH to `/posts/:id` (update)

### 2. resources :posts

One line creates 7 routes + helper methods:
- `posts_path` → `/posts`
- `new_post_path` → `/posts/new`
- `edit_post_path(post)` → `/posts/:id/edit`
- `post_path(post)` → `/posts/:id`

### 3. redirect_to @post

Rails automatically converts to:
```ruby
redirect_to post_path(@post)  # Uses to_param for slug
```

### 4. Category Checkboxes

```ruby
form.check_box :category_ids, { multiple: true }, category.id, nil
```

Rails automatically:
- Creates array of selected IDs
- Creates/destroys PostCategory join records
- No manual association management needed

### 5. Validation Error Display

```ruby
@post.errors.any?  # Returns true if validations failed
@post.errors.full_messages  # Array of error messages
```

Rails collects all validation failures and makes them available.

### 6. Turbo Method Override

```ruby
data: { turbo_method: :delete }
```

**Behind the scenes:**
- Link looks like GET request
- Turbo intercepts click
- Sends DELETE request via JavaScript
- No page refresh (SPA behavior)

---

## Common Pitfalls & Fixes

### Issue: Turbo confirmations not showing

**Symptoms:** Button goes directly to action without confirmation

**Fixes:**
1. Ensure importmap is installed: `bin/rails importmap:install`
2. Ensure Turbo is installed: `bin/rails turbo:install`
3. Add `<%= javascript_importmap_tags %>` to layout
4. Restart server after setup
5. Use correct syntax: `data: { turbo_method: :delete, turbo_confirm: "..." }`

### Issue: Can't find post by slug

**Symptom:** `Couldn't find Post with 'id'="my-first-post"`

**Fix:** Use `find_by!(slug: params[:id])` instead of `find(params[:id])`

### Issue: to_param private method error

**Symptom:** `private method 'to_param' called`

**Fix:** Move `to_param` before the `private` keyword (must be public)

### Issue: Categories not saving

**Symptom:** Checkboxes selected but associations not created

**Fix:** Ensure `category_ids: []` is in strong parameters

### Issue: Deleted posts hidden from admin

**Symptom:** Deleted posts disappear completely

**Fix:** Use `.with_discarded` in index action: `@posts = current_user.posts.with_discarded`

---

## How to Verify Your Work

### 1. Test CRUD Flow

**Create:**
1. Visit `/admin`
2. Click "New Post"
3. Fill form, select categories, check "Publish"
4. Click "Create Post"
5. Should redirect to post view

**Read:**
1. Visit post URL (uses slug)
2. View count increments each visit
3. Categories display as tags

**Update:**
1. Click "Edit" from admin dashboard
2. Change title or content
3. Click "Update Post"
4. Changes should be saved

**Delete & Restore:**
1. Click "Delete" → confirmation dialog appears
2. Confirm → post grayed out with "Deleted" badge
3. Click "Restore" → post becomes active again

### 2. Check Routes

```bash
rails routes | grep posts
```

Should see 8 routes (7 RESTful + restore)

### 3. Test Slug URLs

Create a post "My Test Post"
- URL should be `/posts/my-test-post`
- NOT `/posts/1`

### 4. Verify Soft Delete

```bash
rails console
```

```ruby
post = Post.first
post.discard  # Soft delete
Post.count  # Doesn't include discarded
Post.with_discarded.count  # Includes discarded
post.undiscard  # Restore
Post.count  # Now includes it again
```

---

## What You Learned

✅ RESTful routing conventions (7 standard actions)
✅ Strong parameters for security
✅ Form partials for DRY code
✅ Soft delete pattern with discard gem
✅ Slug-based URLs with to_param
✅ Turbo setup and confirmations
✅ View counter implementation
✅ Conditional UI rendering (deleted vs active)
✅ Many-to-many form handling (category checkboxes)
✅ Error handling and display
✅ Import maps for JavaScript modules
✅ Git pre-commit hooks for code quality
✅ RuboCop for consistent code style

---

## Next Steps (Day 6-7)

Ready to build the public landing page:
- Display published posts
- Category filtering
- Post previews with excerpts
- Featured images
- Pagination

---

## Lessons Learned

### Development Process
1. **Test as you build** - We caught issues early by testing each feature
2. **Check dependencies** - Missing JS setup caused Turbo issues
3. **Read error messages carefully** - They tell you exactly what's wrong
4. **Method visibility matters** - Public vs private affects what Rails can call
5. **Restart server after gem installs** - New gems need to load

### Rails Conventions
1. **Resources over manual routes** - Let Rails generate standard routes
2. **Strong params always** - Never skip this security feature
3. **Partials for reuse** - Form used by both new and edit
4. **Soft delete over hard delete** - Safer for production
5. **Slug-based URLs** - Better SEO and readability

### Debugging Tips
1. Check if JavaScript is loading (view page source)
2. Look for `importmap.rb` file existence
3. Verify gem installation with `bundle list`
4. Test Turbo with browser console (check for errors)
5. Use `rails routes` to verify route configuration
