module TorcheDyn
  module Config
    # --- Couleurs des Matériaux (RGB) ---
    COLORS = {
      bois_clair: [222, 184, 135],
      bois_fonce: [101, 67, 33]
    }

    # --- Paramètres par Défaut ---
    # Utilisés pour l'initialisation de l'UI
    DEFAULTS = {
      mode: "Dressed",          # "Dressed" ou "OCL"
      curve: "Para",            # "Para" (Parabolique) ou "Lin" (Linéaire)
      radius: 1000.mm,
      nb_quarters: 4,
      offset: 50.mm,
      thickness: 20.mm,
      hmax: 500.mm,
      coeff: 1.2,
      pos_x: 0,
      pos_y: 0,
      mode_deroule: false,      # false = circulaire, true = linéaire
      nb_materials: 2,          # 1 = monochrome, 2 = alterné
      show_normals: false
    }

    # --- Version du Plugin ---
    VERSION = "1.0.0"
  end
end
