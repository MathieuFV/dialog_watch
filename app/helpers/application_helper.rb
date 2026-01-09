module ApplicationHelper
    # Cette méthode retourne la classe CSS COMPLÈTE pour le background.
    # Tailwind verra 'bg-blue-500' écrit en dur ici et générera le CSS.
    def progress_bar_class_for_type(type)
      case type
      when 'AccessRestriction', 'Restriction de circulation'
        'bg-blue-500' 
      when 'StandingOrParkingRestriction', 'Restriction de stationnement'
        'bg-amber-500'
      when 'SpeedLimit', 'Limitation de vitesse'
        'bg-rose-500'
      when 'Multi-type'
        'bg-slate-500'
      else
        'bg-gray-500'
      end
    end
  
    # On garde celle-ci pour tes badges (qui utilisent bg-COLOR-100)
    # Mais idéalement, on devrait faire pareil : retourner "bg-blue-100 text-blue-800"
    def color_for_type(type)
      case type
      when 'AccessRestriction', 'Restriction de circulation' then 'blue'
      when 'StandingOrParkingRestriction', 'Restriction de stationnement' then 'amber'
      when 'SpeedLimit', 'Limitation de vitesse' then 'rose'
      when 'Multi-type' then 'slate'
      else 'gray'
      end
    end
  
    def type_badge(type)
      color = color_for_type(type)
      translated_type = t("regulations.types.#{type}", default: type)
      
      # Ici, assure-toi que tes commentaires Safelist sont bien là pour les badges
      # Ou utilise une méthode dédiée qui retourne les classes complètes
      content_tag(:span, translated_type, 
        class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-#{color}-100 text-#{color}-800")
    end

    def dot_class_for_type(type)
        case type
        when 'AccessRestriction', 'Restriction de circulation'
          'bg-blue-400'
        when 'StandingOrParkingRestriction', 'Restriction de stationnement'
          'bg-amber-400'
        when 'SpeedLimit', 'Limitation de vitesse'
          'bg-rose-400'
        when 'Multi-type'
          'bg-slate-400'
        else
          'bg-gray-400'
        end
      end
  end