class AddFileSizeBytesToBlob < ActiveRecord::Migration[7.1]
  def change
    add_column :blobs, :size, :integer
  end
end
