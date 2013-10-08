class AddHeaderBackgroundColorAndFooterBackgroundColorToPartners < ActiveRecord::Migration
  def change
    add_column(:partners, :header_background_color, :string)
    add_column(:partners, :footer_background_color, :string)
  end
end
