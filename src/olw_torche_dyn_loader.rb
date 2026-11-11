require 'sketchup.rb'
require 'extensions.rb'

module OlliwaTorcheDyn
  # 1. CONFIGURATION ET LOGGER
  plugin_dir = File.join(File.dirname(__FILE__), 'olw_torche_dyn')

  # Module de secours pour éviter les crashs si logger.rb est absent ou corrompu
  module TorcheLogger
    def self.log(msg, lvl=:info); puts "[#{lvl.to_s.upcase}] TorcheDyn: #{msg}"; end
    def self.debug(msg); log(msg, :debug); end
    def self.error(msg); log(msg, :error); end
  end

  begin
    # On charge le logger externe
    require File.join(plugin_dir, 'logger.rb')
    # On utilise le logger officiel si chargé, sinon le secours
    logger = defined?(TorcheDyn::TorcheLogger) ? TorcheDyn::TorcheLogger : TorcheLogger
    logger.info("Début du chargement du plugin Olliwa Torche Generator")
  rescue LoadError
    TorcheLogger.log("Utilisation du logger de secours (logger.rb introuvable)", :info)
    logger = TorcheLogger
  rescue => e
    TorcheLogger.log("Erreur lors du chargement du logger : #{e.message}", :error)
    logger = TorcheLogger
  end

  # 2. VÉRIFICATION DE LA VERSION MINIMALE
  SKETCHUP_MIN_VERSION = 20.0
  
  if Sketchup.version.to_f < SKETCHUP_MIN_VERSION
    UI.messagebox("Torche Generator nécessite SketchUp 2020 ou une version plus récente.")
  else
    # 3. CHARGEMENT SÉQUENTIEL DES FICHIERS
    # Important : config.rb doit être chargé avant les autres pour les constantes
    files = ['config.rb', 'core.rb', 'ui_handler.rb']

    files.each do |file|
      begin
        path = File.join(plugin_dir, file)
        require path
        logger.debug("Chargement réussi : #{file}")
      rescue LoadError => e
        logger.error("Impossible de charger #{file}. Détails : #{e.message}")
      rescue StandardError => e
        logger.error("Erreur critique dans #{file} : #{e.message}")
      end
    end

    # Initialisation du header de log une fois que tout (y compris Config) est chargé
    if defined?(TorcheDyn::TorcheLogger) && TorcheDyn::TorcheLogger.respond_to?(:write_header)
      TorcheDyn::TorcheLogger.write_header
    end

    # 4. CRÉATION DES MENUS
    unless file_loaded?(__FILE__)
      begin
        version_label = (defined?(TorcheDyn::Config) && TorcheDyn::Config::VERSION) rescue "0.0.0"

        main_menu = UI.menu('Plugins').add_submenu("Olliwa Torche Generator")
        
        main_menu.add_item("Lancer l'outil v#{version_label}") {
          logger.info("Bouton Lancement cliqué")
          TorcheDyn::UIHandler.run rescue logger.error("Erreur : Interface non trouvée")
        }
        
        main_menu.add_separator
        
        main_menu.add_item("Aide / Documentation") {
          logger.info("Bouton Aide cliqué")
          help_text = <<~TEXT
            Guide d'utilisation de Torche Generator :

            L'outil permet de générer des structures de torches 
            en définissant les paramètres de hauteur, rayon et espacement.

            1. Lancez l'outil via le menu.
            2. Saisissez les dimensions dans le dialogue.
            3. Cliquez sur OK pour générer la géométrie.
          TEXT
          UI.messagebox(help_text, 64, "Guide d'utilisation")
          TorcheDyn::UIHandler.run rescue logger.error("Erreur : Interface non trouvée")
        }
        
        file_loaded(__FILE__)
        logger.info("Menu 'Plugins' ajouté avec succès")
      rescue => e
        logger.error("Erreur lors de la création du menu : #{e.message}")
      end
    end
  end
end

# Enregistrement de l'extension
version_label = (defined?(TorcheDyn::Config) && TorcheDyn::Config::VERSION) rescue "0.0.0"
extension_name = "Olliwa Torche Bois v#{version_label}"
ext = SketchupExtension.new(extension_name, __FILE__)
ext.description = "Générateur de torches pour SketchUp"
ext.creator = "Olliwa"
Sketchup.register_extension(ext)
