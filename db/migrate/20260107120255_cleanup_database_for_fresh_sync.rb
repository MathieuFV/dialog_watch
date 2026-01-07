class CleanupDatabaseForFreshSync < ActiveRecord::Migration[8.0]
  def up
    # On désactive temporairement les contraintes pour éviter les erreurs de clés étrangères
    # (Syntaxe spécifique à PostgreSQL utilisé sur Render)
    execute "TRUNCATE TABLE snapshot_events, daily_snapshots, restrictions, regulations RESTART IDENTITY CASCADE;"
    
    # Note : On garde généralement la table organizations pour éviter de tout recréer,
    # mais si tu veux un "Full Reset", ajoute-la dans la liste ci-dessus.
  end

  def down
    # Cette opération est irréversible
    raise ActiveRecord::IrreversibleMigration
  end
end
