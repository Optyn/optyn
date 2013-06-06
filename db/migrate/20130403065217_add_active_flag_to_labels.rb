class AddActiveFlagToLabels < ActiveRecord::Migration
  def change
    add_column(:labels, :active, :boolean, default: true)
  end
end
