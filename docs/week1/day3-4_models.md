# Week 1, Day 3-4: Post & Category Models with Relationships

**What you're learning:** Database relationships, migrations, model associations, scopes, Rails conventions

**Why this matters:** Understanding how to structure data and relationships is fundamental to Rails. This is where you actually think about your database design.

---

## Core Concept: Many-to-Many Relationships Revisited

You already understand this conceptually, but now you're implementing it.

**Real-world example:**
A student can take multiple classes. A class has multiple students. You need a way to track this.

**Bad approach:** Store all class IDs in a `class_ids` array on the Student.

- Querying becomes hard: "Find all students in Math 101"
- Updating is dangerous: What if you accidentally delete a class ID?
- Scaling breaks down

**Right approach:** Create a join table `StudentEnrollments`

- StudentEnrollments has `student_id` and `class_id`
- Super easy to query: "Find all students where StudentEnrollments.class_id = 101"
- Updating is safe: Foreign keys keep data consistent
- Scales infinitely

For your blog:

- Posts ← Many-to-Many → Categories
- Join table: PostCategories

---

## Step 1: Generate the Models

Run these commands:

```bash
rails generate model Post title:string slug:string content:text excerpt:string featured_image_url:string views_count:integer is_published:boolean user:references
rails generate model Category name:string slug:string
rails generate model PostCategory post:references category:references

rails db:migrate
```

**What each generates:**

### Posts Table

```
id                 (auto-generated primary key)
title              string
slug               string (for URLs: "my-first-post" instead of "1")
content            text (long content, supports markdown)
excerpt            string (summary for social cards)
featured_image_url string (Unsplash URL)
views_count        integer (tracks how many times it's been viewed)
is_published       boolean (draft vs. published)
user_id            integer (foreign key - which user wrote this post)
```

### Categories Table

```
id        (primary key)
name      string (e.g., "JavaScript", "Rails")
slug      string (for URLs)
```

### PostCategories Table (Join Table)

```
id           (primary key, not actually needed but Rails creates it)
post_id      integer (foreign key to posts)
category_id  integer (foreign key to categories)
```

---

## Step 2: Define Model Relationships

### Post Model

Edit `app/models/post.rb`:

```ruby
class Post < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :post_categories, dependent: :destroy
  has_many :categories, through: :post_categories

  # Validations
  validates :title, :content, presence: true

  # Callbacks
  before_save :generate_slug

  # Scopes (reusable queries)
  scope :published, -> { where(is_published: true) }
  scope :by_views, -> { order(views_count: :desc) }

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end
end
```

**Breaking this down:**

```ruby
belongs_to :user
```

- This post belongs to one user (you)
- Rails automatically looks for `user_id` in the posts table
- You can access it: `post.user.email`

```ruby
has_many :post_categories, dependent: :destroy
has_many :categories, through: :post_categories
```

- A post has many PostCategory records (join table entries)
- Through those, it has many Categories
- `dependent: :destroy` means: if a post is deleted, also delete its category associations
- You can access it: `post.categories` → returns array of Category objects

```ruby
scope :published, -> { where(is_published: true) }
```

- This creates a reusable query method
- Later you'll use: `Post.published` instead of `Post.where(is_published: true)`
- Scopes make your code more readable

```ruby
before_save :generate_slug
```

- Before saving, run the `generate_slug` method
- Converts "My First Post" to "my-first-post" automatically
- Rails uses `parameterize` to do this (part of Rails string helpers)

---

### Category Model

Edit `app/models/category.rb`:

```ruby
class Category < ApplicationRecord
  # Associations
  has_many :post_categories, dependent: :destroy
  has_many :posts, through: :post_categories

  # Validations
  validates :name, presence: true, uniqueness: true

  # Callbacks
  before_save :generate_slug

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
```

**The reverse relationship:**

- A category has many posts
- Through PostCategory join table
- If a category is deleted, its associations are destroyed (but not the posts)

---

### PostCategory Model

Edit `app/models/post_category.rb`:

```ruby
class PostCategory < ApplicationRecord
  belongs_to :post
  belongs_to :category
end
```

This is the join table model. It's simple—it just connects the two.

---

### User Model (Update)

Edit `app/models/user.rb` to add the posts association:

```ruby
class User < ApplicationRecord
  # Associations
  has_many :posts, dependent: :destroy

  # Password hashing
  has_secure_password

  # Validations
  validates :email, presence: true, uniqueness: true
end
```

Now you can access: `current_user.posts` → all posts by this user

---

## Step 3: Test the Relationships

Open Rails console:

```bash
rails console
```

Then test:

```ruby
# Find your user
user = User.first

# Create a post
post = user.posts.create!(
  title: "My First Post",
  content: "This is a test post",
  excerpt: "Test excerpt",
  is_published: true
)

# Check the slug was generated
post.slug
# → "my-first-post"

# Find a category (we haven't created any yet, so this will be empty)
Category.all
# → []

# Create categories
rails_cat = Category.create!(name: "Rails")
js_cat = Category.create!(name: "JavaScript")

# Check slugs were generated
rails_cat.slug
# → "rails"

# Add categories to the post
post.categories << rails_cat
post.categories << js_cat

# Verify they were added
post.categories.count
# → 2

post.categories.map(&:name)
# → ["Rails", "JavaScript"]

# Query: find all posts in the Rails category
Category.find_by(name: "Rails").posts
# → [post]

# Test the scope
Post.published
# → [post]

Post.published.by_views
# → [post] (ordered by view count)

exit
```

**What just happened:**
You created a post, added multiple categories to it, and verified you could query from both directions. This is the many-to-many relationship working.

---

## Step 4: Seed Your Categories

Create `db/seeds.rb`:

```ruby
# Create default categories
Category.find_or_create_by!(name: "General") { |c| c.slug = "general" }
Category.find_or_create_by!(name: "JavaScript") { |c| c.slug = "javascript" }
Category.find_or_create_by!(name: "Rails") { |c| c.slug = "rails" }
Category.find_or_create_by!(name: "Language Learning") { |c| c.slug = "language-learning" }
Category.find_or_create_by!(name: "3D & Graphics") { |c| c.slug = "3d-graphics" }

puts "✅ Categories created!"
```

**What `find_or_create_by!` does:**

- Looks for a category with that name
- If it exists, uses it
- If it doesn't, creates it
- The `!` means "raise an error if it fails"

Run the seeds:

```bash
rails db:seed
```

Verify in console:

```bash
rails console
Category.all.map(&:name)
# → ["General", "JavaScript", "Rails", "Language Learning", "3D & Graphics"]
```

---

## Step 5: Understanding Slug-Based URLs

Later, you'll be able to visit `/posts/my-first-post` instead of `/posts/1`.

**Here's how:**

In the URL, `my-first-post` is the slug. Rails will do:

```ruby
Post.find_by(slug: "my-first-post")
```

Instead of:

```ruby
Post.find(1)
```

This is better for SEO and looks nicer.

We'll implement this in the PostsController later.

---

## Recap: What You Learned

- ✅ Model associations: `belongs_to`, `has_many`, `through:`
- ✅ Join tables for many-to-many relationships
- ✅ Validations to ensure data integrity
- ✅ Callbacks (`before_save`) to auto-generate data
- ✅ Scopes for reusable queries
- ✅ Rails conventions: Foreign keys, naming, migrations

---

## Common Pitfalls

1. **"Slug not generating"** — Make sure the `before_save :generate_slug` is in the model
2. **"Can't add categories to posts"** — Verify the PostCategory model exists and has the associations
3. **"Migration errors"** — Did you run `rails db:migrate`?
4. **"Can't find categories in console"** — Did you run `rails db:seed`?

---

## Think About This

Before moving to the next day:

1. Why is the join table needed instead of just an array?
2. What would happen if you deleted a category? (Hint: `dependent: :destroy`)
3. How would you query "all posts in the Rails category"?

If you can answer these, you're ready for Day 5! 🎉
