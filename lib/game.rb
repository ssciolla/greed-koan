require "minitest/autorun"

require_relative "player"
require_relative "turn"

class GameRuleError < StandardError
end

class Game
  @@in_game_threshold = 300

  attr_reader :players

  def initialize(players, ending_score = 3000, input = nil, output = nil)
    if players.size < 2
      raise GameRuleError, "There must be at least two players."
    end

    players.each { |p|
      if !p.instance_of?(Player)
        raise TypeError, "Players must be instances of class Player"
      end
    }

    @players = players
    @ending_score = ending_score

    @input = input.nil? ? $stdin : input
    @output = output.nil? ? $stdout : output
  end

  def turn(player)
    Turn.new(player: player, input: @input, output: @output)
  end

  def self.manage_turn(turn, current_score)
    turn_score, = turn.start current_score
    # check if "in game" or able to get "in game"
    if current_score >= @@in_game_threshold || turn_score >= @@in_game_threshold
      new_score = current_score + turn_score
      puts "Player #{turn.player} has a new score of #{new_score}."
      new_score
    else
      puts "You did not score high enough to get in the game."
      current_score
    end
  end

  def start
    score_data = {}
    @players.each do |p|
      score_data[p] = 0
    end

    puts "You are playing GREED!"
    puts "The game will end once one player reaches #{@ending_score}."
    puts "The other plays will get one remaining turn."
    puts "Here are the players:"
    @players.each { |p| puts p }

    player_who_reached_ending_score = nil
    while player_who_reached_ending_score.nil?
      @players.each do |player|
        puts "- - -"
        new_score = Game.manage_turn self.turn(player), score_data[player]
        score_data[player] = new_score
        if new_score >= @ending_score
          player_who_reached_ending_score = player
          break
        end
      end
    end
    puts "#{player_who_reached_ending_score} reached the ending score."
    puts "Other players will get one more turn."

    # Give other players one more turn.
    other_players = @players - [player_who_reached_ending_score]
    other_players.each do |player|
      score_data[player] = Game.manage_turn self.turn(player), score_data[player]
    end

    winner, score = score_data.max_by { |k, v| v }
    puts "#{winner} won the game with a score of #{score}."

    score_data
  end
end

class GameTest < Minitest::Test
  @@player_one = Player.new("One")
  @@player_two = Player.new("Two")

  def set_up_game
    Game.new([@@player_one, @@player_two], 500)
  end

  def test_game_requires_two_players
    assert_raises(GameRuleError) do
      Game.new([@@player_one])
    end
  end

  def test_game_restricts_type_of_players
    assert_raises(TypeError) do
      Game.new([@@player_one, 2])
    end
  end

  def test_game_accepts_players
    game = Game.new([Player.new("One"), Player.new("Two")])
    assert_equal true, game.players.size == 2
  end

  def test_game_manage_turn_lets_player_in_game
    game = self.set_up_game
    turn = game.turn @@player_one
    turn.stub :start, 400 do
      new_score = Game.manage_turn turn, 0
      assert_equal new_score, 400
    end
  end

  def test_game_manage_turn_does_not_let_player_in_game
    game = self.set_up_game
    turn = game.turn @@player_two
    turn.stub :start, 200 do
      new_score = Game.manage_turn turn, 0
      assert_equal new_score, 0
    end
  end

  def test_game_manage_turn_lets_player_in_game_score_again
    game = self.set_up_game
    turn = game.turn @@player_one
    turn.stub :start, 100 do
      new_score = Game.manage_turn turn, 350
      assert_equal new_score, 450
    end
  end
end
