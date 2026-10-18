# torche_dyn/main.rb
puts "🚀 Torche Generator: Main.rb has been loaded successfully!"

current_dir = File.expand_path(File.dirname(__FILE__))
files_to_load = ['config.rb', 'logger.rb', 'core.rb', 'ui_handler.rb']

puts "--- 🛠️ TorcheGenerator Loading Start ---"
puts "Looking in: #{current_dir}"

files_to_load.each do |file|
  full_path = File.join(current_dir, file)
  if File.exist?(full_path)
    begin
      load full_path
      puts "✅ Loaded: #{file}"
    rescue StandardError => e
      puts "❌ Error loading #{file}: #{e.message}"
      puts e.backtrace.first(3).join("\n")
    end
  else
    puts "❓ File NOT FOUND: #{file} (Path: #{full_path})"
  end
end
puts "--- 🏁 TorcheGenerator Loading End ---"

# --- AJOUT : Création du menu SketchUp avec Version ---
unless file_loaded?(__FILE__)
  # On récupère la version depuis le module Config
  version = (defined?(TorcheDyn::Config) && TorcheDyn::Config::VERSION) || "0.0.0"
  
  # On l'insère dynamiquement dans le nom de l'item du menu
  UI.menu("Plugins").add_item("Générer Torche v#{version}") {
    TorcheDyn::UIHandler.run
  }
end
