class AddRegulationIdToRegulations < ActiveRecord::Migration[8.0]
  def change
    add_column :regulations, :regulation_id, :string
  end
end
