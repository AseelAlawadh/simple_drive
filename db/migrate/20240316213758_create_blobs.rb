class CreateBlobs < ActiveRecord::Migration[7.1]
  def change
    # Ensure the pgcrypto extension is enabled for UUID support
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    create_table :blobs, id: :uuid do |t|
      t.text :data

      t.timestamps
    end
  end
end
