# frozen_string_literal: true

# To greet player, explain rules, provide game status in text, show end game
# message. Also display colors to chose from for player convinience
module Messages
  LOGO = <<~HEREDOC

    ███    ███  █████  ███████ ████████ ███████ ██████  ███    ███ ██ ███    ██ ██████
    ████  ████ ██   ██ ██         ██    ██      ██   ██ ████  ████ ██ ████   ██ ██   ██ 
    ██ ████ ██ ███████ ███████    ██    █████   ██████  ██ ████ ██ ██ ██ ██  ██ ██   ██ 
    ██  ██  ██ ██   ██      ██    ██    ██      ██   ██ ██  ██  ██ ██ ██  ██ ██ ██   ██ 
    ██      ██ ██   ██ ███████    ██    ███████ ██   ██ ██      ██ ██ ██   ████ ██████  

  HEREDOC

  RULES = <<~HEREDOC

    Colors of the game are red, blue, green, cyan, magenta, lime, pink, yellow.
    Enter your guess using only first characters of related colors.
    Each guess evaluated by two numbers. First one shows how many colors you
    guessed right not concerning their possition in code. Second one shows
    number of exact matches - right colors in right positions.

    Take your time. Try to use as less turns as possible. Good luck!

  HEREDOC

  COLORS = <<~HEREDOC
    Use following letters for colors
    r for red
    g for green
    b for blue
    y for yellow
    c for cyan
    m for magenta
    l for lime
    p for pink

  HEREDOC

  def print_greet
    puts LOGO
    puts "Computer made a #{@code.code_length}-piece code."
    puts 'Try to guess it. Use first letters of colors. Examples: rgby, plbr.'
  end

  def print_rules
    puts <<~HEREDOC

      The object of the game is to guess a secret code consisting of a series of
      #{@code.code_length} colors pegs. Each guess results in narrowing down the
      possibilities of the code. You won the game if you manage to guess the
      code in less than #{@tries} tries.
    HEREDOC
    puts RULES
  end

  def print_game_over
    puts 'You have no tries left, but don\'t give in to discouragement.'
    puts 'Come on! Try again. You\'ll definitely crack it next time!'
    puts "The code was #{@code_to_guess.join}."
  end

  def print_win
    puts "Well done! You managed to guess the code with #{@tries} tries left!"
  end

  def print_colors
    puts COLORS
  end

  def print_status
    puts "You have #{@tries} tries left."
  end
end

# To to compare player guess with code, count key pegs
module CountMatchPegs
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
class Codebreaker
  attr_reader :guess

  def initialize
    @guess = ''
  end

  def ask_for_guess(code)
    loop do
      print '> '
      guess = gets.chomp.downcase
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
      puts 'Use only first letters of related colors.'
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
class Board
  def initialize
    @guess_table = {}
    @turn_number = 0
  end

  def print_guess_table
    @guess_table.each_pair do |turn, guess|
      puts <<~HEREDOC
        -----------
        Turn #{turn}: #{guess[0].join} -> #{guess[1]} matches #{guess[2]} of them exact.
      HEREDOC
    end
  end

  # private

  def add_guess(guess, small_pegs, big_pegs)
    @turn_number += 1
    @guess_table[@turn_number] = [guess, small_pegs, big_pegs]
  end
end

# To handle game flow - check tries number, determine win for the player
class Game
  include CountMatchPegs
  include Messages
  attr_reader :tries

  def initialize
    @code = Codemaker.new
    @code_to_guess = @code.choose_code
    @tries = 12
    @board = Board.new
  end

  def play_game
    print_greet
    print_rules
    print_colors
    @tries -= 1 until check_for_try_limit || check_for_win(guess_try)
  end

  private

  def guess_try
    print_status
    guess = Codebreaker.new.ask_for_guess(@code)
    small_pegs = CountMatchPegs.count_small_pegs(guess, @code_to_guess)
    big_pegs = CountMatchPegs.count_big_pegs(guess, @code_to_guess)
    @board.add_guess(guess, small_pegs, big_pegs)
    @board.print_guess_table
    big_pegs
  end

  def check_for_try_limit
    if @tries <= 0
      print_game_over
      true
    else
      false
    end
  end

  def check_for_win(big_pegs)
    if big_pegs == 4
      print_win
      return true
    end
    false
  end
end

game = Game.new
game.play_game
