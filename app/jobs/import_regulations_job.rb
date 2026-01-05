class ImportRegulationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # On logge chaque démarrage automatisé de l'import
    Rails.logger.info "🤖 JOB: Démarrage de l'import automatique..."
    
    # Le job utilise le service RegulationsImporter
    importer = RegulationsImporter.new
    importer.perform

    # On logge la fin de l'import
    Rails.logger.info "🤖 JOB: Terminé avec succès."
  end
end
