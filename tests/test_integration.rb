# tests/test_integration.rb
require_relative 'test_helper'

class TestIntegration < Minitest::Test
  def test_full_generation_cycle
    params = TorcheDyn::Config::DEFAULTS.dup
    mats = TorcheDyn::UIHandler.setup_material(2)
    
    model = Sketchup.active_model
    model.start_operation('Test Gen', true)
    
    generator = TorcheDyn::Core.new(params, mats)
    generator.generate
    
    # Vérification : est-ce qu'un composant a été ajouté aux définitions ?
    assert model.definitions.any? { |d| d.name.include?("Dressed") }
    
    model.abort_operation # On nettoie le modèle après le test
  end
end
