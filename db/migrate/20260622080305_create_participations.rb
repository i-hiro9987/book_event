class CreateParticipations < ActiveRecord::Migration[7.2]
  def change
    create_table :participations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :comment

      t.timestamps
    end
  end
end
