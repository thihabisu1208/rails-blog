class AddDataIntegrityConstraints < ActiveRecord::Migration[8.0]
  def up
    # ==============================================================
    # USERS TABLE: Add constraints and indexes
    # ==============================================================

    # Add unique index on email (case-insensitive)
    # This prevents race conditions on user registration
    execute "CREATE UNIQUE INDEX index_users_on_lower_email ON users (LOWER(email))"

    # Add NOT NULL constraint on email
    change_column_null :users, :email, false

    # Add NOT NULL constraint on password_digest
    change_column_null :users, :password_digest, false

    # ==============================================================
    # POSTS TABLE: Add defaults, constraints, and indexes
    # ==============================================================

    # Set default for views_count (currently NULL for existing records)
    change_column_default :posts, :views_count, from: nil, to: 0

    # Update existing NULL values to 0
    execute "UPDATE posts SET views_count = 0 WHERE views_count IS NULL"

    # Add NOT NULL constraint
    change_column_null :posts, :views_count, false

    # Set default for is_published
    change_column_default :posts, :is_published, from: nil, to: false

    # Update existing NULL values to false
    execute "UPDATE posts SET is_published = false WHERE is_published IS NULL"

    # Add NOT NULL constraint
    change_column_null :posts, :is_published, false

    # Add NOT NULL constraints on required fields
    change_column_null :posts, :title, false
    change_column_null :posts, :content, false
    change_column_null :posts, :slug, false
    change_column_null :posts, :user_id, false

    # Add index on slug for fast lookups (used in URLs)
    add_index :posts, :slug, unique: true, where: "discarded_at IS NULL"

    # Add index on is_published for filtering published posts
    add_index :posts, :is_published, where: "discarded_at IS NULL"

    # Add composite index on user_id and created_at for user's posts listing
    add_index :posts, [ :user_id, :created_at ]

    # ==============================================================
    # CATEGORIES TABLE: Add constraints and indexes
    # ==============================================================

    # Add NOT NULL constraint on name
    change_column_null :categories, :name, false

    # Add NOT NULL constraint on slug
    change_column_null :categories, :slug, false

    # Add unique index on slug
    add_index :categories, :slug, unique: true

    # ==============================================================
    # POST_CATEGORIES TABLE: Add composite unique constraint
    # ==============================================================

    # Prevent duplicate category assignments to same post
    add_index :post_categories, [ :post_id, :category_id ], unique: true
  end

  def down
    # Remove indexes
    remove_index :users, name: "index_users_on_lower_email" if index_exists?(:users, name: "index_users_on_lower_email")
    remove_index :posts, :slug if index_exists?(:posts, :slug)
    remove_index :posts, :is_published if index_exists?(:posts, :is_published)
    remove_index :posts, [ :user_id, :created_at ] if index_exists?(:posts, [ :user_id, :created_at ])
    remove_index :categories, :slug if index_exists?(:categories, :slug)
    remove_index :post_categories, [ :post_id, :category_id ] if index_exists?(:post_categories, [ :post_id, :category_id ])

    # Revert NOT NULL constraints
    change_column_null :users, :email, true
    change_column_null :users, :password_digest, true
    change_column_null :posts, :views_count, true
    change_column_null :posts, :is_published, true
    change_column_null :posts, :title, true
    change_column_null :posts, :content, true
    change_column_null :posts, :slug, true
    change_column_null :posts, :user_id, true
    change_column_null :categories, :name, true
    change_column_null :categories, :slug, true

    # Revert defaults
    change_column_default :posts, :views_count, from: 0, to: nil
    change_column_default :posts, :is_published, from: false, to: nil
  end
end
