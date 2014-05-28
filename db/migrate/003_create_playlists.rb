class CreatePlaylists < ActiveRecord::Migration
  def self.up
    create_table :playlists do |t|
      t.string :id
      t.string :projectName
      t.text :body
      t.string :author
      t.string :author_id
      t.string :author_email
      t.timestamps
    end
  end

  def self.down
    drop_table :playlists
  end
end
