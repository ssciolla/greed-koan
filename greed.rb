require "./lib/game"
require "./lib/player"

game = Game.new([Player.new("One"), Player.new("Two")])
game.start
