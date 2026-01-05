require 'open-uri'

class RegulationsImporter
  URL = "https://dialog.beta.gouv.fr/api/regulations.xml"

  def initialize
    @stats = { created: 0, updated: 0, errors: 0 }
  end

  def perform
    puts "📡 Démarrage de l'import depuis #{URL}..."
    
    xml_data = URI.open(URL)
    doc = Nokogiri::XML(xml_data)
    doc.remove_namespaces!

    nodes = doc.xpath('//trafficRegulationOrder')
    puts "🔍 #{nodes.count} arrêtés trouvés dans le XML."

    nodes.each do |node|
      process_node(node)
    end

    puts "✅ Import terminé ! Résultats : #{@stats}"
  end

  private

  def process_node(node)
    # 1. Extraction des données
    external_id = node['id']
    
    # On cherche précisément dans issuingAuthority -> values -> value
    # Le '&.text' évite le crash si le champ est vide
    org_name = node.at_xpath('.//issuingAuthority/values/value')&.text&.strip || "Inconnu"
    
    # Extraction des dates (souvent dans validityTimeSpecification)
    start_date_str = node.at_xpath('.//overallStartTime')&.text
    end_date_str = node.at_xpath('.//overallEndTime')&.text

    # Bonus : Essayons de capturer le type (ex: noEntry)
    # On cherche n'importe quelle balise qui finit par 'Type' ou le typeOfRegulation
    reg_type = node.at_xpath('.//accessRestrictionType')&.text || 
               node.at_xpath('.//typeOfRegulation')&.attr('type') || 
               "Autre"

    # 2. Gestion de l'Organisation
    organization = Organization.find_or_create_by(name: org_name)

    # 3. Gestion du Règlement
    regulation = Regulation.find_or_initialize_by(external_id: external_id)
    is_new = regulation.new_record?

    regulation.organization = organization
    regulation.start_date = start_date_str
    regulation.end_date = end_date_str
    regulation.regulation_type = reg_type # On sauvegarde le type
    regulation.last_seen_at = Time.current

    if regulation.save
      if is_new
        @stats[:created] += 1
        print "+" # Un petit "+" pour une création
      else
        @stats[:updated] += 1
        print "." # Un petit "." pour une mise à jour
      end
    else
      @stats[:errors] += 1
      # On n'affiche l'erreur que si ce n'est pas juste un doublon d'ID (ce qui ne devrait pas arriver avec find_or_initialize)
      puts "\n❌ Erreur #{external_id} : #{regulation.errors.full_messages.join(', ')}"
    end
  end
end