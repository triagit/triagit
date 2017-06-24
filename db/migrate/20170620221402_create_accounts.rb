class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :token, null: false
      t.string :name, null: false
      t.string :service, limit: 2, null: false
      t.string :plan, null: false
      t.string :ref, null: false
      t.text :payload, null: false
      t.text :rules

      t.timestamps
    end
    add_index :accounts, :service
    add_index :accounts, [:service, :ref], unique: true
  end
end
