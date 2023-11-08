require "minitest/autorun"

require_relative "./player.rb"
require_relative "./turn.rb"

class GameRuleError < StandardError
end

class Game

  @@in_game_threshold = 300

  attr_reader :players

  def initialize(players, ending_score=3000, input=nil, output=nil)
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

    @score_data = Hash.new
    @players.each do |p|
      @score_data[p] = 0
    end
  end

  def manage_turn(player, current_score)
    turn = Turn.new(player: player, input: @input, output: @output)
    turn_score, = turn.start @score_data[player]
    # check if "in game" or able to get "in game"
    if current_score >= @@in_game_threshold || turn_score >= @@in_game_threshold
      new_score = current_score += turn_score
      puts "Player #{player} has a new score of #{new_score}."
      new_score
    else
      puts "You did not score high enough to get in the game."
      current_score
    end
  end

  def start
    puts "You are playing GREED!"
    puts "The game will end once one player reaches #{@ending_score}."
    puts "The other plays will get one remaining turn."
    puts "Here are the players:"
    @players.each { |p| puts p }

    player_who_reached_ending_score = nil
    while player_who_reached_ending_score.nil?
      @players.each do |player|
        puts "- - -"
        current_player = player
        new_score = self.manage_turn player, @score_data[player]
        @score_data[player] = new_score
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
      @score_data[player] = self.manage_turn player, @score_data[player]
    end

    winner, score = @score_data.max_by { |k, v| v }
    puts "#{winner} won the game with a score of #{score}."

    @score_data
  end
end

class GameTest < Minitest::Test

  @@player_one = Player.new("One")
  @@player_two = Player.new("Two")

  def test_game_requires_two_players
    assert_raises(GameRuleError) do
      Game.new([@@player_one])
    end
  end

  def test_game_restricts_type_of_players
    assert_raises(TypeError) do
      game = Game.new([@@player_one, 2])
    end
  end

  def test_game_accepts_players
    game = Game.new([Player.new("One"), Player.new("Two")])
    assert_equal true, game.players.size == 2
  end

  def test_game_can_be_played_with_stdin_stdout
    game = Game.new([@@player_one, @@player_two], 500)
    score_data = game.start
    assert_equal score_data.size, 2
    assert_equal score_data.keys, [@@player_one, @@player_two]
    assert_equal true, score_data.values.all? { |x| x.is_a?(Integer) }
  end
end
