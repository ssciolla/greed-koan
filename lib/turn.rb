require "minitest/autorun"

require_relative "./dice_set.rb"
require_relative "./player.rb"
require_relative "./score.rb"

class Turn

  attr_reader :player

  def initialize(player:, input:, output:)
    @player = player
    @input = input
    @output = output
  end

  def Turn.report_roll_results(dice_values, score)
    "You rolled #{dice_values}, which has a score of #{score}."
  end

  def continue?(dice_values, roll_score, turn_score)
    prompt = "Would you like to continue? (Y/N)"
    @output.print(
      Turn.report_roll_results(dice_values, roll_score) + " " +
      "Your score this turn so far is #{turn_score}. #{prompt}\n"
    )
    
    no_valid_response = true
    response = nil
    while no_valid_response
      response = @input.gets.strip
      if ["Y", "N"].include? response
        no_valid_response = false
      else
        @output.print "Response \"#{response}\" was not valid. #{prompt}\n"
      end
    end
    response == "Y"
  end

  def start(current_score, seed=nil)
    turn_score = 0
    num_rolls = 0
    wants_to_continue = true
    dice = DiceSet.new(seed)
    num_active_dice = 5

    @output.puts "Turn for #{@player}."
    @output.puts "Your current score is #{current_score}."

    while wants_to_continue
      dice.roll(num_active_dice)
      num_rolls += 1
      roll_score, num_nonscoring_dice = score dice.values
      if num_nonscoring_dice == num_active_dice
        turn_score = 0
        @output.puts Turn.report_roll_results dice.values, roll_score
        break
      else
        turn_score += roll_score
      end
      wants_to_continue = self.continue? dice.values, roll_score, turn_score
      
      if wants_to_continue
        @output.print "You're greedy :P\n"
        num_active_dice = num_nonscoring_dice == 0 ? 5 : num_nonscoring_dice
      end
    end

    @output.puts "You scored #{turn_score} for your turn."
    [turn_score, num_rolls]
  end
end

class TurnTest < Minitest::Test

  @@player_one = Player.new("One")

  def test_report_roll_results
    message = Turn.report_roll_results([1, 1, 1], 1000)
    assert_equal "You rolled [1, 1, 1], which has a score of 1000.", message
  end

  def test_turn_continue_prompts_player
    input = StringIO.new("Y")
    output = StringIO.new
    turn = Turn.new(player: @@player_one, input: input, output: output)
    turn.continue? [1, 1, 1, 1, 1], 1200, 1200
    assert_equal(
      output.string,
      "You rolled [1, 1, 1, 1, 1], which has a score of 1200. " +
      "Your score this turn so far is 1200. Would you like to continue? (Y/N)\n"
    )
  end

  def test_turn_continue_reprompts_when_invalid
    input = StringIO.new("X\nX\nY\n")
    output = StringIO.new
    turn = Turn.new(player: @@player_one, input: input, output: output)
    result = turn.continue? [1, 1, 1, 1, 1], 1200, 1200
    assert_equal 2, output.string.scan(/Response \"X\" was not valid\./).size
    assert_equal 3, output.string.scan(/Would you like to continue\?/).size
  end

  def test_turn_continue_reprompts_when_empty
    input = StringIO.new("\nY\n")
    output = StringIO.new
    turn = Turn.new(player: @@player_one, input: input, output: output)
    result = turn.continue? [1, 1, 1, 1, 1], 1200, 1200
    assert_equal true, output.string.include?("Response \"\" was not valid.")
    assert_equal 2, output.string.scan(/Would you like to continue\?/).size
  end

  def test_continue_declined
    input = StringIO.new("N\n")
    output = StringIO.new
    turn = Turn.new(player: @@player_one, input: input, output: output)
    result = turn.continue? [1, 1, 1, 1, 1], 1200, 1200
    assert_equal false, result
    assert_equal true, input.string.include?("N")
  end

  def test_turn_continue_accepted
    input = StringIO.new("Y\n")
    output = StringIO.new
    turn = Turn.new(player: @@player_one, input: input, output: output)
    result = turn.continue? [1, 1, 1, 1, 1], 1200, 1200
    assert_equal true, result
    assert_equal true, input.string.include?("Y")
  end

  def test_turn_start_returns_score
    input = StringIO.new("N\n")
    output = StringIO.new
    turn = Turn.new(player: @@player_one, input: input, output: output)
    turn_score, = turn.start 0, 0
    assert_equal true, turn_score.is_a?(Integer)
  end

  def test_turn_start_when_player_is_greedy
    input = StringIO.new("Y\nY\nN\n")
    output = StringIO.new
    turn = Turn.new(player: @@player_one, input: input, output: output)
    turn_score, num_rolls = turn.start 0, 0
    assert_equal true, turn_score.is_a?(Integer)
    assert_equal 3, num_rolls
  end
end
