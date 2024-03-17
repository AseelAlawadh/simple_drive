class AddFileToBlob < ActiveRecord::Migration[7.1]
  def change
    add_column :blobs, :file, :text
  end
end
