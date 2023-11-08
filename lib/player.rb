require "minitest/autorun"

class Player

  def initialize(name)
    @name = name
    @id = self.object_id
  end
  
  attr_reader :name
  attr_reader :id

  def to_s
    "<Player name=\"#{@name}\" id=#{@id}>"
  end

end
  
class PlayerTest < Minitest::Test

  @@player_one = Player.new("One")

  def test_player_has_a_name_and_id
    assert_equal "One", @@player_one.name
    assert_equal true, @@player_one.id != nil
  end

  def test_player_has_string_rep
    assert_equal "<Player name=\"One\" id=#{@@player_one.object_id}>", @@player_one.to_s
  end
end
  