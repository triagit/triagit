class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events, id: :uuid do |t|
      t.references :repo, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :ref, null: false
      t.text :payload, null: false

      t.timestamps
    end
  end
end
