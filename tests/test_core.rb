# tests/test_core.rb
require_relative 'test_helper'

class TestCore < Minitest::Test
  def setup
    @params = TorcheDyn::Config::DEFAULTS.dup
    @materials = [Sketchup.active_model.materials.add("T1"), Sketchup.active_model.materials.add("T2")]
    @core = TorcheDyn::Core.new(@params, @materials)
  end

  def test_material_alternation_logic
    # On teste si l'index 2 donne bien le matériau foncé (index 1 du tableau)
    # On peut extraire la logique de choix de matériau dans une méthode publique pour la tester
    # assert_equal @materials[1], @core.send(:get_material_for_index, 2)
  end

  def test_linear_placement_math
    # Vérifier que la position X augmente correctement en mode déroulé
    # ...
  end
end
