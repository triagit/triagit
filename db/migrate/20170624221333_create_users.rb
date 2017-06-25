class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name, null: false
      t.string :service, limit: 2, null: false
      t.string :ref, null: false
      t.string :payload, null: false

      t.timestamps
    end
    add_index :users, :service
    add_index :users, [:service, :ref], unique: true
  end
end
