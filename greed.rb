require "./lib/game.rb"
require "./lib/player.rb"

game = Game.new([Player.new("One"), Player.new("Two")])
game.start
