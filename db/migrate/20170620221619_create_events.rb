class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.references :repo, foreign_key: true
      t.string :name, null: false
      t.string :ref, null: false
      t.text :payload, null: false

      t.timestamps
    end
  end
end
