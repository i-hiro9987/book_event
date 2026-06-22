class ChangeStockDefaultInBooks < ActiveRecord::Migration[7.2]
  def up
    change_column_default :books, :stock, from: nil, to: 0
  end

  def down
    change_column_default :books, :stock, from: nil, to: 0
  end
end
