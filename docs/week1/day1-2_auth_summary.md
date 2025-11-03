Detailed Summary: Day 1-2 Session Authentication Setup

What We Built Together

---

1. User Model with Password Authentication

Generated:

- User model with three fields: email, password_digest, admin
- Database migration

Files Created/Modified:

- app/models/user.rb
- db/migrate/20251103091335_create_users.rb

What it does:

- has_secure_password - Rails method that:
  - Creates virtual password attribute (not in DB)
  - Automatically hashes password using bcrypt
  - Stores hashed version in password_digest
  - Adds .authenticate(password) method
- Email validation with uniqueness check

Key Learning:

- Why password_digest? Never store plain passwords - we store one-way hashed versions
- bcrypt - The hashing algorithm that makes passwords unreadable
- ||= pattern - Used for caching to avoid repeated DB queries

---

2. Sessions Controller (Login/Logout Logic)

Generated:

- SessionsController with 3 actions: new, create, destroy
- Views for sessions

Files Created/Modified:

- app/controllers/sessions_controller.rb
- app/views/sessions/new.html.erb (login form)

What each action does:

- new - Shows the login form
- create - Processes login:
  a. Finds user by email
  b. Uses user&.authenticate(password) to verify password
  c. Stores user.id in session[:user_id] (encrypted cookie)
  d. Redirects to admin or shows error
- destroy - Clears session (logout)

Key Learning:

- session[:user_id] - The encrypted cookie that persists who's logged in
- Safe navigation &. - Prevents crashes if user is nil
- Restaurant metaphor - Session ID is like a table number the host gives you

---

3. Authentication Filter (Security Layer)

Files Modified:

- app/controllers/application_controller.rb

What we added:

1. before_action :authenticate_user! - Runs before every controller action
2. unless: :public_page? - Except for public pages
3. authenticate_user! - Redirects to login if no current_user
4. current_user - Looks up user from session (cached with ||=)
5. public_page? - Defines which pages don't need login
6. helper_method :current_user - Makes it available in views

Key Learning:

- This is the "gatekeeper" - everything runs through here
- Public pages: homepage, blog posts, login page itself
- The ||= caching prevents hitting the database multiple times per request

---

4. Pages Controller (Landing Page)

Generated:

- PagesController with landing action
- Landing page view

Files Created:

- app/controllers/pages_controller.rb
- app/views/pages/landing.html.erb

What it does:

- skip_before_action :authenticate_user! - Makes landing page public
- Simple placeholder for now (will build later in Week 1, Day 6-7)

---

5. Routes Configuration

File Modified:

- config/routes.rb

Routes Added:
root "pages#landing" # Homepage
GET /login → sessions#new # Login form
POST /sessions → sessions#create # Process login
DELETE /logout → sessions#destroy # Logout
GET /admin → posts#index # Admin dashboard
resources :posts # Full CRUD for posts
resources :categories # Limited CRUD for categories

---

6. Application Layout (Navbar & Flash Messages)

File Modified:

- app/views/layouts/application.html.erb

What we added:

1. Navigation bar - Shows different links based on login status:

   - If logged in: "Admin" and "Logout" buttons
   - If not logged in: "Login" link

2. Flash messages - Shows success/error feedback:

   - Green banner for notice (success)
   - Red banner for alert (errors)

3. Uses current_user - Available because of helper_method in ApplicationController

---

7. Tailwind CSS Setup & Fix

Problem:

Tailwind wasn't working - asset not found error

What We Fixed:

File Modified:

- config/initializers/assets.rb - Added builds directory to asset paths
- app/views/layouts/application.html.erb - Fixed stylesheet link tag

Key Actions:

1. Ran rails tailwindcss:install - Created Tailwind config
2. Added app/assets/builds to asset paths
3. Created Procfile.dev for running Rails + Tailwind watcher together

Files Created:

- app/assets/tailwind/application.css - Tailwind source
- app/assets/builds/tailwind.css - Compiled CSS
- Procfile.dev - Runs web server + CSS watcher
- bin/dev - Script to start foreman

CRITICAL: Must use bin/dev instead of rails s to:

- Run Rails server
- Run Tailwind watcher (rebuilds on file changes)

---

8. RSpec Testing Setup

What We Installed:

Gems Added to Gemfile:

- rspec-rails - RSpec for Rails
- factory_bot_rails - Test data factories
- faker - Fake data generator
- shoulda-matchers - Cleaner model specs

Files Created:

- .rspec - RSpec configuration
- spec/rails_helper.rb - Rails-specific test config
- spec/spec_helper.rb - General RSpec config
- spec/models/user_spec.rb - Example User model tests

Configuration Added:

1. FactoryBot methods included globally
2. Shoulda matchers configured for Rails
3. Test database setup
4. Removed default test/ directory (using spec/ instead)

Directory Structure:
spec/
├── models/
├── controllers/
├── requests/
├── factories/
├── rails_helper.rb
└── spec_helper.rb

Tests Created:

- 6 tests for User model (all passing ✓)
- Tests for validations, password hashing, authentication

Run tests with:
bundle exec rspec

---

9. Test Data Created

Admin User:

- Email: admin@example.com
- Password: password123
- Admin: true

---

Final File Tree

app/
├── assets/
│ ├── builds/
│ │ └── tailwind.css (compiled)
│ ├── tailwind/
│ │ └── application.css (source)
│ └── stylesheets/
│ └── application.css
├── controllers/
│ ├── application_controller.rb (auth filter)
│ ├── pages_controller.rb
│ └── sessions_controller.rb
├── models/
│ └── user.rb (has_secure_password)
└── views/
├── layouts/
│ └── application.html.erb (navbar + flash)
├── pages/
│ └── landing.html.erb
└── sessions/
└── new.html.erb (login form)

config/
├── initializers/
│ └── assets.rb (builds path added)
└── routes.rb (auth routes)

spec/
├── models/
│ └── user_spec.rb
├── rails_helper.rb
└── spec_helper.rb

Gemfile (added bcrypt, rspec, etc.)
Procfile.dev (web + css processes)

---

Key Concepts You Should Understand

1. Session-based authentication - Cookie with encrypted user ID
2. Password hashing - One-way encryption with bcrypt
3. Controller filters - before_action runs before actions
4. Rails conventions - Models, controllers, views working together
5. Safe navigation (&.) - Prevents nil errors
6. Caching with ||= - Avoids repeated database queries
7. Helper methods - Making controller methods available in views
8. Asset pipeline - How CSS/JS files are served
9. Tailwind CSS v4 - Utility-first CSS framework
10. RSpec - Behavior-driven testing framework

---

How to Test Your Work

Start the Server:

bin/dev # NOT 'rails s' - this runs Tailwind watcher too

Test the Flow:

1. Visit http://localhost:3000 → See landing page
2. Click "Login" → See login form
3. Login with admin@example.com / password123
4. Should redirect to /admin (will error - Posts controller not built yet)
5. Click "Logout" → Returns to homepage

Run Tests:

bundle exec rspec

# Should see: 6 examples, 0 failures

---

## What You Learned

✅ Session-based authentication from scratch
✅ Password hashing with bcrypt
✅ Controller filters and callbacks
✅ Rails routing conventions
✅ Flash messages for user feedback
✅ Helper methods in views
✅ Asset pipeline configuration
✅ RSpec testing setup
✅ Tailwind CSS integration
✅ Rails project structure

---

## Rails Magic Explained

### 1. has_secure_password

- Automatically creates `password` and `password_confirmation` virtual attributes
- Hashes password with bcrypt and stores in `password_digest`
- Adds `.authenticate(password)` method for login
- Adds password validations

### 2. session[:user_id]

- Encrypted cookie stored in browser
- Rails automatically encrypts/decrypts it
- Persists across requests
- Cleared when browser closes (unless remember_me)

### 3. before_action

- Runs before controller actions
- Can be skipped with `skip_before_action`
- Perfect for authentication checks
- DRY principle - write once, applies everywhere

### 4. Helper methods

- `helper_method :current_user` makes controller methods available in views
- Views can now use `<% if current_user %>`
- Keeps logic in controllers, accessible in views

### 5. Safe navigation operator (&.)

- `user&.authenticate` - only calls if user exists
- Prevents `NoMethodError` on nil
- Cleaner than `user && user.authenticate`

### 6. Caching with ||=

```ruby
@current_user ||= User.find_by(id: session[:user_id])
```

- First request: queries database, caches result
- Subsequent requests: returns cached value
- Avoids hitting database multiple times per request

### 7. Rails routing shortcuts

- `root "pages#landing"` - sets homepage
- `resources :posts` - creates 7 RESTful routes automatically
- Named routes: `login_path`, `logout_path`, `posts_path`

### 8. Flash messages

- `notice` - success messages (green)
- `alert` - error messages (red)
- Automatically cleared after one request
- Available in views via `flash[:notice]`

---

Next Steps (Day 3-4)

When you're ready:

- Build Post and Category models
- Create admin dashboard
- Build CRUD operations for posts
