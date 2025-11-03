class AddMissingColumnsToPost < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :is_published, :boolean
    add_reference :posts, :user, null: false, foreign_key: true
  end
end
