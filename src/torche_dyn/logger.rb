module TorcheDyn
  class LogManager
    class << self
      # Détermine le chemin absolu du fichier log basé sur le modèle actuel
      def log_path
        model = Sketchup.active_model
        base_dir = (model && model.path) ? File.dirname(model.path) : Dir.home
        # On utilise la constante VERSION définie dans Config
        version = (defined?(TorcheDyn::Config) && TorcheDyn::Config::VERSION) || "0.0.0"
        File.expand_path(File.join(base_dir, "torche_dyn_v#{version}.log"))
      end

      # Crée l'en-tête de session détaillé
      def write_header
        absolute_path = log_path
        version = (defined?(TorcheDyn::Config) && TorcheDyn::Config::VERSION) || "0.0.0"
        
        header = <<~HEADER
          ======================================================================
          SESSION START  : #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}
          Plugin Version : #{version} | SketchUp: #{Sketchup.version}
          LOG PATH (ABS) : #{absolute_path}
          ======================================================================
        HEADER
        log("SYSTEM", header)
      end

      # Méthode centrale de journalisation
      def log(level, msg, e = nil)
        timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        line = "[#{timestamp}] #{level}: #{msg}"
        
        # Ajout de la trace d'erreur si une exception est fournie
        if e
          line += "\n#{e.message}\n#{e.backtrace[0..3].join("\n")}"
        end
        
        # 1. Affichage console Ruby
        puts line
        
        # 2. Écriture fichier
        begin
          File.open(log_path, 'a') { |f| f.puts line }
        rescue => err
          puts "Logging failed to #{log_path}: #{err.message}"
        end
      end

      # Raccourcis de niveaux de log
      def info(msg);  log("INFO", msg); end
      def debug(msg); log("DEBUG", msg); end
      def warn(msg);  log("WARN", msg); end
      def error(msg, e = nil); log("ERROR", msg, e); end
    end
  end
end
