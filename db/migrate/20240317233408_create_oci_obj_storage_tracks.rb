class CreateOciObjStorageTracks < ActiveRecord::Migration[7.1]
  def change
    create_table :oci_obj_storage_tracks do |t|
      t.string :operation_type
      t.string :object_name
      t.string :status
      t.timestamps
    end
  end
end
