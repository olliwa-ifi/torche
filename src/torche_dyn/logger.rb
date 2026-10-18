module TorcheDyn
  module Logger
    # Préfixes pour identifier rapidement le type de message
    PREFIXES = {
      info:  "[TORCHE-INFO]  ",
      warn:  "[TORCHE-WARN]  ",
      error: "[TORCHE-ERROR] "
    }

    # Affiche un message d'information général
    def self.info(message)
      puts "#{PREFIXES[:info]}#{message}"
    end

    # Affiche un avertissement (le script continue de tourner)
    def self.warn(message)
      puts "#{PREFIXES[:warn]}#{message}"
    end

    # Affiche une erreur critique
    def self.error(message)
      # On ajoute un saut de ligne et un séparateur pour rendre l'erreur visible
      puts "\n" + "="*50
      puts "#{PREFIXES[:error]}CRITICAL ERROR"
      puts "Message: #{message}"
      puts "="*50 + "\n"
    end
  end
end
