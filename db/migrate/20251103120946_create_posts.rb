class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.string :excerpt
      t.string :featured_image_url
      t.integer :views_count

      t.timestamps
    end
  end
end
