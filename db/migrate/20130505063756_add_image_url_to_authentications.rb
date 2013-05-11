class AddImageUrlToAuthentications < ActiveRecord::Migration
  def change
    add_column(:authentications, :image_url, :string, limit: '1000')
  end
end
