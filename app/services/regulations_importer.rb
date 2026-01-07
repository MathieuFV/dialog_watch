require 'open-uri'

class RegulationsImporter
  URL = "https://dialog.beta.gouv.fr/api/regulations.xml"

  def initialize
    @stats = { created: 0, updated: 0, errors: 0, restrictions: 0 }
  end

  def perform
    puts "📡 Démarrage de l'import depuis #{URL}..."

    # L'heure de démarrage permet de donner à chaque arrêté un statut active true ou false pour ne 
    # garder que les arrêtés encore en vigueur au moment de l'import.
    import_start_time = Time.current
    
    xml_data = URI.open(URL)
    doc = Nokogiri::XML(xml_data)

    # On enlève les namespaces DATEX pour simplifier la recherche des noeuds
    doc.remove_namespaces!

    # On importe tous les arrêtés
    nodes = doc.xpath('//trafficRegulationOrder')
    puts "🔍 #{nodes.count} arrêtés trouvés dans le XML."

    nodes.each { |node| process_node(node) }

    # Tous les arrêtés plus anciens que l'heure de l'import sont marqués en active : false
    orphans = Regulation.active.where("last_seen_at < ?", import_start_time)
    count_deactivated = orphans.update_all(active: false)

    puts "\n🧹 Nettoyage terminé : #{count_deactivated} arrêtés marqués comme inactifs."
    puts "✅ Import terminé ! Résultats : #{@stats}"
  end

  private

  def process_node(node)
    # On garde l'identifiant DiaLog de chaque arrêté
    external_id = node['id']
    # Nom de l'organisation émettrice
    org_name = node.at_xpath('.//issuingAuthority/values/value')&.text&.strip || "Inconnu"
    # On trouve l'organisation concernée par l'arrêté, si absente on la crée
    organization = Organization.find_or_create_by!(name: org_name)
  
    # Idem pour les arrêtés
    regulation = Regulation.find_or_initialize_by(external_id: external_id)
    is_new = regulation.new_record?
    
    # On assigne les attributs sans sauvegarder immédiatement
    regulation.assign_attributes(
      regulation_id: node.at_xpath('.//regulationId')&.text,
      organization: organization,
      # Par défaut, tous les arrêtés trouvés sont active : true avant nettoyage dans la suite du traitement
      active: true,
      last_seen_at: Time.current
    )
  
    # On récupère chaque restriction dans l'arrêté
    if regulation.save
      regulation.restrictions.delete_all
      
      node.xpath('.//trafficRegulation').each do |res_node|
        # On garde : le type de restriction, les dates de début et de fin
        res_type = res_node.at_xpath('.//typeOfRegulation')&.attr('type') || "Autre"
        res_start = res_node.at_xpath('.//overallStartTime')&.text
        res_end = res_node.at_xpath('.//overallEndTime')&.text

        regulation.restrictions.create!(
          restriction_type: res_type, 
          start_date: res_start,
          end_date: res_end
        )
        @stats[:restrictions] += 1
      end
  
      # Le type d'un arrêté est déterminé par les types de restrictions qu'il contient
      # De même la durée de validité de l'arrêté est l'enveloppe des durées des restrictions qu'il contient
      regulation.update!(
        regulation_type: regulation.computed_type,
        start_date: regulation.restrictions.minimum(:start_date),
        end_date: regulation.permanent? ? nil : regulation.restrictions.maximum(:end_date)
      )
  
      is_new ? @stats[:created] += 1 : @stats[:updated] += 1
      print(is_new ? "+" : ".")
    else
      @stats[:errors] += 1
      puts "\n❌ Erreur #{external_id} : #{regulation.errors.full_messages.join(', ')}"
    end
  end
end