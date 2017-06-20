class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :token
      t.string :name
      t.string :service
      t.string :plan
      t.string :ref
      t.text :payload
      t.text :rules

      t.timestamps
    end
  end
end
