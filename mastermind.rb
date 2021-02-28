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
  # Match position AND color
  def self.count_big_pegs(guess, code_to_guess)
    big_pegs = 0
    guess.each_with_index do |item, index|
      big_pegs += 1 if item == code_to_guess[index]
    end
    big_pegs
  end

  # Match color only
  def self.count_small_pegs(guess, code_to_guess)
    small_pegs = 0
    guess.each do |item|
      small_pegs += 1 if code_to_guess.include?(item)
    end
    small_pegs
  end
end

# To pick random color combination
# Attr: color_set, code_length
# Meth: single_random_color, choose_code
# LCycle: single_random_color => choose_code
class Codemaker
  attr_reader :color_set, :code, :code_length

  def initialize
    @color_set = %w[
      r g b y c m l p
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
  attr_reader :guess

  def initialize
    @guess = ''
  end

  def ask_for_guess(code)
    puts "Computer made a #{code.code_length}-piece code."
    puts 'Try to guess it. Use first letters of colors. Examples: rgby, plbr.'
    loop do
      print '> '
      guess = gets.chomp
      break guess.chars if validate_guess_length(guess, code) &&
                           validate_guess_duplicates(guess) &&
                           validate_guess_content(guess, code)
    end
  end

  private

  def validate_guess_length(guess, code)
    if guess.length != code.code_length
      puts 'Make sure you entered correct number of letters.'
      false
    else
      true
    end
  end

  def validate_guess_content(guess, code)
    guess_array = []
    guess.each_char do |char|
      guess_array.push(char) if code.color_set.join.include?(char)
    end
    if guess_array.length != code.code_length
      puts 'Use only first and downcased letters of related colors.'
      false
    else
      true
    end
  end

  def validate_guess_duplicates(guess)
    if guess.chars.length != guess.chars.uniq.length
      puts 'Computer was not allowed duplicates in code. Enter unique letters.'
      false
    else
      true
    end
  end
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
  include Gamemaster
  def initialize
    @code = Codemaker.new
    @code_to_guess = @code.choose_code
  end

  def guess_try
    guess = Codebreaker.new.ask_for_guess(@code)
    Gamemaster.count_small_pegs(guess, @code_to_guess)
    Gamemaster.count_big_pegs(guess, @code_to_guess)
  end
end

# code = Codemaker.new
# p code.single_random_color
# p code.choose_code
# guess = Codebreaker.new
# p guess.ask_for_guess(code)
game = Game.new
game.guess_try
