class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.string :title
      t.string :isbn
      t.string :author_name
      t.string :publisher
      t.decimal :price
      t.integer :stock
      t.integer :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
