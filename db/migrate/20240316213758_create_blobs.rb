class CreateBlobs < ActiveRecord::Migration[7.1]
  def change
    create_table :blobs, id: :uuid do |t|
      t.text :data

      t.timestamps
    end
  end
end
