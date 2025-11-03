# Day 3-4: Post & Category Models Summary

## What We Built

A complete many-to-many relationship system for blog posts and categories with automatic slug generation and validations.

---

## 1. Post Model

### Generated:

```bash
rails generate model Post title:string slug:string content:text excerpt:string featured_image_url:string views_count:integer is_published:boolean user:references
```

### Files Created:

- `app/models/post.rb`
- `db/migrate/[timestamp]_create_posts.rb`
- `db/migrate/[timestamp]_add_missing_columns_to_post.rb` (added is_published, user_id)

### What it does:

- **Associations**: Belongs to User, has many Categories through PostCategories
- **Validations**: Title and content required
- **Callbacks**: Auto-generates slug from title before saving
- **Scopes**:
  - `Post.published` - only published posts
  - `Post.by_views` - ordered by view count

### Key Code:

```ruby
belongs_to :user
has_many :post_categories, dependent: :destroy
has_many :categories, through: :post_categories

before_save :generate_slug

def generate_slug
  self.slug = title.parameterize if title.present?
end
```

---

## 2. Category Model

### Generated:

```bash
rails generate model Category name:string slug:string
```

### Files Created:

- `app/models/category.rb`
- `db/migrate/[timestamp]_create_categories.rb`

### What it does:

- **Associations**: Has many Posts through PostCategories
- **Validations**: Name required and unique
- **Callbacks**: Auto-generates slug from name

### Key Code:

```ruby
has_many :post_categories, dependent: :destroy
has_many :posts, through: :post_categories

validates :name, presence: true, uniqueness: true
```

---

## 3. PostCategory Model (Join Table)

### Generated:

```bash
rails generate model PostCategory post:references category:references
```

### Files Created:

- `app/models/post_category.rb`
- `db/migrate/[timestamp]_create_post_categories.rb`

### What it does:

- Connects Posts and Categories
- Simple join table with two foreign keys

### Key Code:

```ruby
belongs_to :post
belongs_to :category
```

---

## 4. User Model Update

### File Modified:

- `app/models/user.rb`

### What we added:

```ruby
has_many :posts, dependent: :destroy
```

**Why**: Allows `current_user.posts` to get all posts by a user.

---

## 5. Database Seeds

### File Modified:

- `db/seeds.rb`

### What we added:

```ruby
Category.find_or_create_by!(name: "General")
Category.find_or_create_by!(name: "JavaScript")
Category.find_or_create_by!(name: "Rails")
Category.find_or_create_by!(name: "Language Learning")
Category.find_or_create_by!(name: "3D & Graphics")
```

**Run with**: `rails db:seed`

**Why `find_or_create_by!`**: Safe to run multiple times (idempotent).

---

## 6. Testing in Rails Console

### What we tested:

```ruby
# Create post
user = User.first
post = user.posts.create!(title: "My First Post", content: "Content", is_published: true)

# Verify slug generation
post.slug # => "my-first-post"

# Create categories
rails_cat = Category.create!(name: "Rails")
js_cat = Category.create!(name: "JavaScript")

# Add categories to post
post.categories << rails_cat
post.categories << js_cat

# Query both directions
post.categories.map(&:name) # => ["Rails", "JavaScript"]
rails_cat.posts.first.title # => "My First Post"

# Test scopes
Post.published # => [post]
```

---

## Database Schema

### Posts Table:

```
id                  (primary key)
title               string
slug                string
content             text
excerpt             string
featured_image_url  string
views_count         integer
is_published        boolean
user_id             bigint (foreign key)
created_at          datetime
updated_at          datetime
```

### Categories Table:

```
id          (primary key)
name        string
slug        string
created_at  datetime
updated_at  datetime
```

### PostCategories Table (Join Table):

```
id           (primary key)
post_id      bigint (foreign key)
category_id  bigint (foreign key)
created_at   datetime
updated_at   datetime
```

---

## File Tree After Day 3-4

```
app/
├── models/
│   ├── user.rb (updated with has_many :posts)
│   ├── post.rb (new)
│   ├── category.rb (new)
│   └── post_category.rb (new)

db/
├── migrate/
│   ├── [timestamp]_create_posts.rb
│   ├── [timestamp]_create_categories.rb
│   ├── [timestamp]_create_post_categories.rb
│   └── [timestamp]_add_missing_columns_to_post.rb
├── seeds.rb (updated)
└── schema.rb (auto-updated)
```

---

## Key Concepts You Should Understand

### 1. Many-to-Many Relationships

**Why join tables?**

- Arrays can't be queried efficiently both ways
- Join table allows: `post.categories` AND `category.posts`
- Scalable and follows relational database best practices

### 2. Model Associations

```ruby
belongs_to :user           # Post belongs to ONE user
has_many :posts            # User has MANY posts
has_many :categories, through: :post_categories  # Many-to-many
```

### 3. Callbacks

```ruby
before_save :generate_slug
```

- Runs automatically before saving
- Like React lifecycle methods (componentWillMount)
- Used for auto-generating data

### 4. Scopes

```ruby
scope :published, -> { where(is_published: true) }
```

- Reusable query methods
- Chainable: `Post.published.by_views`
- Like selector functions in Redux/Zustand

### 5. Slug Generation

```ruby
title.parameterize
```

- "My First Post" → "my-first-post"
- SEO-friendly URLs
- Rails helper method

### 6. Dependent Destroy

```ruby
has_many :posts, dependent: :destroy
```

- If user is deleted, their posts are deleted
- If post is deleted, its category associations are deleted
- Maintains referential integrity

---

## Common Pitfalls & Fixes

### Issue: Migration missing is_published and user_id

**Fix**: Create additional migration

```bash
rails generate migration AddMissingColumnsToPost is_published:boolean user:references
rails db:migrate
```

### Issue: Typos in model code

**Common typos**:

- `dependant` → `dependent`
- `parametarize` → `parameterize`
- Wrong column name in scopes

**Fix**: Rails will error immediately - check spelling carefully

---

## How to Verify Your Work

### 1. Check migrations ran:

```bash
rails db:migrate:status
```

All should show "up"

### 2. Verify in console:

```bash
rails console
Post.column_names  # Should include is_published, user_id
Category.count     # Should show seeded categories
exit
```

### 3. Test associations:

```ruby
user = User.first
post = user.posts.create!(title: "Test", content: "Content", is_published: true)
post.slug  # Should be "test"
post.categories << Category.first
post.categories.count  # Should be 1
```

---

## What You Learned

✅ Database design with join tables
✅ Model associations (belongs_to, has_many, through)
✅ Validations for data integrity
✅ Callbacks for auto-generated data
✅ Scopes for reusable queries
✅ Rails naming conventions
✅ Seed data for development
✅ Testing models in Rails console

**Rails Magic Explained:**

- Auto slug generation with `parameterize`
- Foreign key naming (`user_id`, `post_id`)
- Association methods (`post.categories`, `category.posts`)
- `dependent: :destroy` cascade deletes

---

## Next Steps (Day 5)

Ready to build the CRUD interface:

- Routes configuration
- PostsController with 7 RESTful actions
- Admin views (index, new, edit)
- Public view (show)
- Form with category checkboxes
