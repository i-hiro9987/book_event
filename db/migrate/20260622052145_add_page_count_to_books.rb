class AddPageCountToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :page_count, :integer
  end
end
