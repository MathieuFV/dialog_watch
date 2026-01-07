require 'open-uri'

class RegulationsImporter
  URL = "https://dialog.beta.gouv.fr/api/regulations.xml"

  def initialize
    @stats = { created: 0, updated: 0, errors: 0, restrictions: 0 }
  end

  def perform
    puts "📡 Démarrage de l'import depuis #{URL}..."
    import_start_time = Time.current
    
    xml_data = URI.open(URL)
    doc = Nokogiri::XML(xml_data)
    doc.remove_namespaces!

    nodes = doc.xpath('//trafficRegulationOrder')
    puts "🔍 #{nodes.count} arrêtés trouvés dans le XML."

    nodes.each { |node| process_node(node) }

    # Désactivation des anciens
    orphans = Regulation.active.where("last_seen_at < ?", import_start_time)
    count_deactivated = orphans.update_all(active: false)

    puts "\n🧹 Nettoyage terminé : #{count_deactivated} arrêtés marqués comme inactifs."
    puts "✅ Import terminé ! Résultats : #{@stats}"
  end

  private

  def process_node(node)
    external_id = node['id']
    org_name = node.at_xpath('.//issuingAuthority/values/value')&.text&.strip || "Inconnu"
    organization = Organization.find_or_create_by!(name: org_name)
  
    regulation = Regulation.find_or_initialize_by(external_id: external_id)
    is_new = regulation.new_record?
    
    # On assigne les attributs sans sauvegarder immédiatement
    regulation.assign_attributes(
      regulation_id: node.at_xpath('.//regulationId')&.text,
      organization: organization,
      active: true,
      last_seen_at: Time.current
    )
  
    if regulation.save
      # On traite les restrictions
      regulation.restrictions.delete_all
      
      node.xpath('.//trafficRegulation').each do |res_node|
        res_type = res_node.at_xpath('.//typeOfRegulation')&.attr('type') || "Autre"
        res_start = res_node.at_xpath('.//overallStartTime')&.text
        res_end = res_node.at_xpath('.//overallEndTime')&.text

        regulation.restrictions.create!(
          restriction_type: res_type, 
          start_date: res_start,
          end_date: res_end
        )
        @stats[:restrictions] += 1 # On oublie pas d'incrémenter ici
      end
  
      # Mise à jour des métadonnées héritées
      # On utilise la base de données (SQL) pour le min/max, c'est plus fiable
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