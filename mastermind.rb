# frozen_string_literal: true

# To greet player, explain rules, provide game status in text, show end game
# message. Also display colors to chose from for player convinience
# Meth: print_greet, print_rules, print_game_over, print_win, print_colors,
# print_status
module Messages
end

# To to compare player guess with code, count key pegs
# Meth: count_big_pegs, count_small_pegs
module Gamemaster
end

# To pick random color combination
# Attr: color_set, code_length
# Meth: single_random_color, choose_code
# LCycle: single_random_color => choose_code
class Codemaker
  attr_reader :color_set, :code

  def initialize
    @color_set = %w[
      red green blue yellow cyan magenta lime pink
    ]
    @code_length = 4
    @code = []
  end

  def choose_code
    code.push(single_random_color) until code.uniq.length == @code_length
    code.uniq
  end

  private

  def single_random_color
    color_set.sample
  end
end

# To ask and get player's guess
# Attr: color_set, code_length
# Meth: ask_for_guess, validate_guess
# LCycle: ask_for_guess => validate_guess
class Codebreaker
end

# To show game current state - previous guess attempts with key pegs counted
# Attr: guess_table
# Meth: print_guess_table
# LCycle: print_guess_table
class Board
end

# To handle game flow - check tries number, determine win for the player
# Attr: try_number
# Meth: check_for_try_limit, check_for_win
# LCycle: check_for_try_limit => check_for_win
class Game
end

code = Codemaker.new
# p code.single_random_color
p code.choose_code
