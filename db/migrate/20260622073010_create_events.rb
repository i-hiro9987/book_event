class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.string :location
      t.integer :capacity
      t.datetime :start_at
      t.datetime :end_at
      t.string :image_url
      t.references :book, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
