require "minitest/autorun"

def score(dice)
  count_data = Hash.new
  dice.uniq.each { |die|
    count_data[die] = dice.count(die)
  }

  roll_score = 0
  num_scored_dice = 0
  count_data.each_pair do |die, count|
    count_to_score = count
    if count_to_score >= 3
      roll_score += (die == 1 ? 1000 : (100 * die))
      count_to_score -= 3
      num_scored_dice += 3
    end

    if count_to_score > 0
      case
      when die == 1
        roll_score += 100 * count_to_score
        num_scored_dice += count_to_score
      when die == 5
        roll_score += 50 * count_to_score
        num_scored_dice += count_to_score
      end
    end
  end
  num_non_scoring_dice = dice.size - num_scored_dice
  return [roll_score, num_non_scoring_dice]
end

# Adapted from about_scoring_project
class ScoreTest < Minitest::Test
  def test_score_of_an_empty_list_is_zero
    assert_equal [0, 0], score([])
  end

  def test_score_of_a_single_roll_of_5_is_50
    assert_equal [50, 0], score([5])
  end

  def test_score_of_a_single_roll_of_1_is_100
    assert_equal [100, 0], score([1])
  end

  def test_score_of_multiple_1s_and_5s_is_the_sum_of_individual_scores
    assert_equal [300, 0], score([1,5,5,1])
  end

  def test_score_of_single_2s_3s_4s_and_6s_are_zero
    assert_equal [0, 4], score([2,3,4,6])
  end

  def test_score_of_a_triple_1_is_1000
    assert_equal [1000, 0], score([1,1,1])
  end

  def test_score_of_other_triples_is_100x
    assert_equal [200, 0], score([2,2,2])
    assert_equal [300, 0], score([3,3,3])
    assert_equal [400, 0], score([4,4,4])
    assert_equal [500, 0], score([5,5,5])
    assert_equal [600, 0], score([6,6,6])
  end

  def test_score_of_mixed_is_sum
    assert_equal [250, 1], score([2,5,2,2,3])
    assert_equal [550, 0], score([5,5,5,5])
    assert_equal [1100, 0], score([1,1,1,1])
    assert_equal [1200, 0], score([1,1,1,1,1])
    assert_equal [1150, 0], score([1,1,1,5,1])
  end
end