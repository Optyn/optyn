class RemoveEmbedCodeFromShops < ActiveRecord::Migration
  def up
    remove_column(:shops, :embed_code)
  end

  def down
    add_column(:shops, :embed_code, :text)
  end
end
