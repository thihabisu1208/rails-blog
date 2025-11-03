# Week 1, Day 1-2: Session Authentication Setup

**What you're learning:** Sessions, password hashing, Rails authentication patterns, controller filters

**Why this matters:** You need a secure way to log in. Session auth is the foundation of most web apps. Understanding how it works will help you later when you learn OAuth and JWT.

---

## Core Concept: How Session Auth Works

Think of it like a restaurant's reservation system:

1. You arrive and say "I'm John, I have a reservation"
2. The host checks their reservation list and finds you
3. The host gives you a table number to remember
4. Next time you come back, you show the table number—they don't need to verify your identity again
5. The reservation list (on the host's computer) never leaves the restaurant

**In Rails terms:**

- You = user
- Reservation list = database
- Table number = cookie (stored on your browser)
- Host checking = Rails session filter

The session cookie is encrypted by Rails automatically. The user can see it, but can't modify it without the server knowing.

---

## Step 1: Create User Model with Password Hashing

### What We're Doing

You need to store user information securely. Rails has a built-in method called `has_secure_password` that:

- Hashes passwords using bcrypt (one-way encryption)
- Adds validation methods
- Never stores plain passwords

### Generate the Model

```bash
rails generate model User email:string password_digest:string admin:boolean
```

**What this creates:**

- `app/models/user.rb` — The User model
- `db/migrate/[timestamp]_create_users.rb` — The migration file

### Run the Migration

```bash
rails db:migrate
```

This creates the `users` table in PostgreSQL with three columns:

- `email` — String
- `password_digest` — String (stores the _hashed_ password, never the plain password)
- `admin` — Boolean (to distinguish you from future guest users)

**Why `password_digest` instead of `password`?**
Because we never store the actual password. We store a hashed version that Rails generates from the plain password. When someone logs in, Rails hashes what they typed and compares it to what's stored. If they match, the password was correct.

---

## Step 2: Add Password Hashing to User Model

Edit `app/models/user.rb`:

```ruby
class User < ApplicationRecord
  has_secure_password  # Rails magic for password hashing
  validates :email, presence: true, uniqueness: true
end
```

**What `has_secure_password` does:**

- Adds a virtual `password` attribute (not stored in DB, just in memory)
- Automatically hashes it to `password_digest` before saving
- Adds an `.authenticate(password)` method you can use to check passwords
- Adds validation that passwords are present

**The `validates` line:**

- Ensures email is always provided
- Ensures email is unique (no two users with same email)

### Test This Locally

Open Rails console to verify it works:

```bash
rails console
```

Then type:

```ruby
user = User.create(email: "you@example.com", password: "password123")
# This should succeed and hash the password automatically

user.password_digest
# Shows the hashed password (looks like gibberish - that's correct!)

user.authenticate("password123")
# Returns the user object if password is correct

user.authenticate("wrongpassword")
# Returns false if password is wrong
```

Exit console:

```ruby
exit
```

---

## Step 3: Create Sessions Controller

Sessions aren't models—they're a pattern for managing login/logout. Create the controller:

```bash
rails generate controller Sessions new create destroy
```

This creates:

- `app/controllers/sessions_controller.rb`
- `app/views/sessions/new.html.erb` (login form)
- Routes (we'll add these manually)

### Build the Sessions Controller

Edit `app/controllers/sessions_controller.rb`:

```ruby
class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  # ↑ We'll create authenticate_user! next, but for now, this tells Rails:
  # "Anyone can visit the login page, even if they're not logged in"

  # GET /login
  # Shows the login form
  def new
    # The view will have the form
  end

  # POST /sessions
  # Processes the login form submission
  def create
    user = User.find_by(email: params[:email])
    # Find the user by email they typed in the form

    if user&.authenticate(params[:password])
      # &. is "safe navigation" - if user is nil, this returns nil instead of crashing
      # .authenticate() checks if the password matches

      session[:user_id] = user.id
      # Store the user's ID in a cookie (Rails encrypts this automatically)

      redirect_to admin_path, notice: "Logged in successfully"
      # Redirect to admin dashboard
    else
      flash.now[:alert] = "Invalid email or password"
      # Show error message
      render :new, status: :unprocessable_entity
      # Show the form again so they can retry
    end
  end

  # DELETE /logout
  # Logs the user out
  def destroy
    session[:user_id] = nil
    # Clear the user ID from the cookie

    redirect_to root_path, notice: "Logged out"
  end
end
```

**Key concepts:**

- `session[:user_id] = user.id` — This is the "table number" metaphor. Rails stores it in an encrypted cookie.
- `user&.authenticate(password)` — This compares the typed password with the hashed one in the database
- `skip_before_action` — We haven't created the auth filter yet, but this line says "anyone can access login without being authenticated"

---

## Step 4: Create Authentication Filter in Application Controller

This is where we define who can access what.

Edit `app/controllers/application_controller.rb`:

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :public_page?
  # ↑ Before any action runs, check if the user is logged in
  # UNLESS the page is public (like the homepage or blog posts)

  private

  def authenticate_user!
    # This method checks if the user is logged in
    redirect_to login_path unless current_user
    # If current_user is nil (no one logged in), redirect to login page
  end

  def current_user
    # This method returns the currently logged-in user
    @current_user ||= User.find_by(id: session[:user_id])
    # ||= means: "If @current_user is already set, use it. Otherwise, look up the user."
    # This prevents multiple database queries
  end

  def public_page?
    # Pages that don't require login
    request.path == "/" ||
    request.path.start_with?("/posts/") ||
    request.path.start_with?("/sessions")
  end

  helper_method :current_user
  # Makes current_user available in views (so you can do <%= current_user.email %> in HTML)
end
```

**Breaking this down:**

1. `before_action :authenticate_user!` — Runs before every action
2. `unless: :public_page?` — Except for public pages
3. `current_user` — Looks up the user from the session cookie
4. `public_page?` — Defines which pages don't need login
5. `helper_method` — Makes the method available in views

**Why the `||=` pattern?**

```ruby
@current_user ||= User.find_by(id: session[:user_id])
```

This means: "If @current_user is already set, use it. Otherwise, do the database lookup."

Why? Because if you call `current_user` multiple times in one request, you don't want multiple database queries. Set it once, reuse it.

---

## Step 5: Create Login View

Create `app/views/sessions/new.html.erb`:

```erb
<div class="min-h-screen flex items-center justify-center bg-gray-50">
  <div class="max-w-md w-full space-y-8">
    <h2 class="text-center text-3xl font-bold">DevLog Admin</h2>

    <%= form_with url: sessions_path, local: true do |form| %>
      <!-- Email field -->
      <div class="mb-4">
        <%= form.label :email %>
        <%= form.email_field :email, class: "w-full px-4 py-2 border rounded-lg", placeholder: "your@email.com" %>
      </div>

      <!-- Password field -->
      <div class="mb-6">
        <%= form.label :password %>
        <%= form.password_field :password, class: "w-full px-4 py-2 border rounded-lg", placeholder: "••••••••" %>
      </div>

      <!-- Submit button -->
      <%= form.submit "Sign In", class: "w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700" %>
    <% end %>
  </div>
</div>
```

**What this does:**

- `form_with url: sessions_path` — Submits to the `create` action (POST /sessions)
- `form.email_field` — Creates an email input
- `form.password_field` — Creates a password input (content is masked)
- `form.submit` — Creates the login button

---

## Step 6: Add Routes

Edit `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  root "pages#landing"
  # The homepage (we'll create this later)

  # Session routes (login/logout)
  get "/login", to: "sessions#new"
  post "/sessions", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # Admin dashboard (we'll create this later)
  get "/admin", to: "posts#index"

  # Posts routes (standard CRUD)
  resources :posts

  # Categories routes (for managing categories)
  resources :categories, only: [:index, :create, :destroy]
end
```

**Route breakdown:**

- `GET /login` → Shows login form (new action)
- `POST /sessions` → Processes login (create action)
- `DELETE /logout` → Logs you out (destroy action)
- `GET /admin` → Admin dashboard
- `resources :posts` → Standard Rails REST routes (index, show, new, create, edit, update, destroy)

---

## Step 7: Create the Pages Controller (Stub)

We'll build the landing page later, but for now, create a stub:

```bash
rails generate controller Pages landing
```

Edit `app/controllers/pages_controller.rb`:

```ruby
class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  # Landing page should be public

  def landing
    # We'll add content here in Week 1, Day 6-7
  end
end
```

Create `app/views/pages/landing.html.erb` (empty for now):

```erb
<h1>DevLog</h1>
<p>Coming soon...</p>
```

---

## Step 8: Update Application Layout

Edit `app/views/layouts/application.html.erb` to add a navbar:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>DevLog</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= importmap_tags %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  </head>

  <body>
    <!-- Navigation Bar -->
    <nav class="bg-gray-800 text-white p-4">
      <div class="container mx-auto flex justify-between items-center">
        <%= link_to "DevLog", root_path, class: "text-xl font-bold" %>

        <div class="space-x-4">
          <% if current_user %>
            <%= link_to "Admin", admin_path, class: "hover:text-gray-300" %>
            <%= link_to "Logout", logout_path, method: :delete, class: "text-red-400 hover:text-red-300" %>
          <% else %>
            <%= link_to "Login", login_path, class: "hover:text-gray-300" %>
          <% end %>
        </div>
      </div>
    </nav>

    <!-- Flash Messages -->
    <% if notice %>
      <div class="bg-green-100 text-green-800 p-4">
        <%= notice %>
      </div>
    <% end %>

    <% if alert %>
      <div class="bg-red-100 text-red-800 p-4">
        <%= alert %>
      </div>
    <% end %>

    <!-- Main Content -->
    <main>
      <%= yield %>
    </main>
  </body>
</html>
```

---

## Test Your Work

### Start the Server

```bash
rails s
```

Then visit `http://localhost:3000`

### Test the Flow

1. **Visit the homepage** — Should see "Coming soon..."
2. **Click Login** — Should see the login form
3. **Try logging in** — Will fail (no users yet)
4. **Create a user in console:**

```bash
rails console
```

```ruby
User.create!(email: "you@example.com", password: "password123", admin: true)
exit
```

5. **Try logging in again** — Should work! Redirects to `/admin`
6. **Click Logout** — Returns to homepage, session cleared

---

## Recap: What You Learned

- ✅ `has_secure_password` — Rails' password hashing
- ✅ Sessions — Storing user ID in encrypted cookies
- ✅ Controller filters — `before_action`, `skip_before_action`
- ✅ Safe navigation — `user&.authenticate()`
- ✅ `current_user` caching — Using `||=` to avoid repeated DB queries
- ✅ Rails conventions — Routes, controllers, views working together

---

## Common Pitfalls

1. **"Login not working"** — Make sure you created a user with `rails console`
2. **"Routes not found"** — Did you run `rails db:migrate` after creating the User model?
3. **"Can't access admin page"** — Check that you have `skip_before_action :authenticate_user!` in PagesController
4. **"Session not persisting"** — This should work automatically; if not, check browser cookies (might be disabled)

---

## Ready for the Next Day?

Once this is working, move on to `day3-4_models.md` to build the Post and Category models.

But first, take a moment to answer these questions (in your head):

1. Why do we hash passwords instead of storing them plain?
2. What would happen if we didn't have `skip_before_action` in PagesController?
3. Why use `||=` instead of just looking up `current_user` every time?

If you can answer these, you're ready to continue! 🎉
