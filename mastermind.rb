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

    You can play as the CODEBREAKER or the CODEMAKER.

    CODEBREAKER
    Try to guess the code, chosen by a computer. Each guess evaluated by two
    numbers. First one shows how many colors you guessed right not concerning
    their possition in code. Second one shows number of exact matches - right
    colors in right positions.

    CODEMAKER
    Try to choose the code, which cannot be broken by a computer.

  HEREDOC

  COLORS = <<~HEREDOC
    Colors of the game are red, blue, green, cyan, magenta, lime, pink, yellow.
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

  def print_logo
    puts LOGO
  end

  def print_intro
    puts <<~HEREDOC

      The object of the game is to guess a secret code consisting of a series of
      #{@code.code_length} colors. Each guess results in narrowing down the
      possibilities of the code. Codebreaker won the game if he manage to guess
      the code in less than #{@tries} tries. Otherwise Codemaker is the winner.

    HEREDOC
  end

  def print_greet_codebreaker
    puts "Computer made a #{@code.code_length}-piece code."
    puts 'Try to guess it. Use first letters of colors. Examples: rgby, plbr.'
  end

  def print_greet_codemaker
    puts "Choose a #{@code.code_length}-piece code."
    puts 'Use first letters of colors. Examples: rgby, plbr.'
  end

  def print_rules
    puts RULES
  end

  def print_game_over_codebreaker
    puts 'You have no tries left, but don\'t give in to discouragement.'
    puts 'Come on! Try again. You\'ll definitely crack it next time!'
    puts "The code was #{@code_to_guess.join}."
  end

  def print_game_over_codemaker
    puts "Computer cracked your code with #{turn} tries."
  end

  def print_win_codebreaker
    puts "Well done! You managed to guess the code with #{@tries} tries left!"
  end

  def print_win_codemaker
    puts 'Computer can\'t guess your code. You won the war against machines!'
  end

  def print_colors
    puts COLORS
  end

  def print_status
    puts "#{@tries} tries left."
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
class RandomCode
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

# To ask and get player's code
class CodeInput
  attr_reader :code_input

  def initialize
    @code_input = ''
  end

  def ask_for_guess(code)
    loop do
      print '> '
      code_input = gets.chomp.downcase
      break code_input.chars if validate_input_length(code_input, code) &&
                                validate_input_duplicates(code_input) &&
                                validate_input_content(code_input, code)
    end
  end

  private

  def validate_input_length(code_input, code)
    if code_input.length != code.code_length
      puts 'Make sure you entered correct number of letters.'
      false
    else
      true
    end
  end

  def validate_input_content(code_input, code)
    code_input_array = []
    code_input.each_char do |char|
      code_input_array.push(char) if code.color_set.join.include?(char)
    end
    if code_input_array.length != code.code_length
      puts 'Use only first letters of related colors.'
      false
    else
      true
    end
  end

  def validate_input_duplicates(code_input)
    if code_input.chars.length != code_input.chars.uniq.length
      puts 'Duplicates are not allowed in code. Enter unique letters.'
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

  def print_single_guess
    guess = @guess_table.values.last
    puts <<~HEREDOC
      -----------
      #{guess[0].join} -> #{guess[1]} matches #{guess[2]} of them exact.
    HEREDOC
  end

  # private

  def add_guess(guess, small_pegs, big_pegs)
    @turn_number += 1
    @guess_table[@turn_number] = [guess, small_pegs, big_pegs]
  end
end

# To handle game flow for Codebreaker mode - check tries number, determine win
# for the player
class GameBreaker
  include CountMatchPegs
  include Messages
  attr_reader :tries

  def initialize
    @code = RandomCode.new
    @code_to_guess = @code.choose_code
    print_intro
    print_greet_codebreaker
    @tries = 12
    @board = Board.new
  end

  def play_game
    @tries -= 1 until check_for_try_limit || check_for_win(guess_try)
  end

  private

  def guess_try
    print_status
    guess = CodeInput.new.ask_for_guess(@code)
    small_pegs = CountMatchPegs.count_small_pegs(guess, @code_to_guess)
    big_pegs = CountMatchPegs.count_big_pegs(guess, @code_to_guess)
    @board.add_guess(guess, small_pegs, big_pegs)
    @board.print_guess_table
    big_pegs
  end

  def check_for_try_limit
    if @tries <= 0
      print_game_over_codebreaker
      true
    else
      false
    end
  end

  def check_for_win(big_pegs)
    if big_pegs == 4
      print_win_codebreaker
      return true
    end
    false
  end
end

# To handle game flow for Codemaker mode - count tries, determine win or lose
# for computer
class GameMaker < GameBreaker
  def initialize
    @code = RandomCode.new
    print_intro
    print_greet_codemaker
    @code_to_guess = CodeInput.new.ask_for_guess(@code)
    @tries = 12
    @board = Board.new
  end

  def guess_try
    print_status
    sleep 2
    guess = RandomCode.new.choose_code
    small_pegs = CountMatchPegs.count_small_pegs(guess, @code_to_guess)
    big_pegs = CountMatchPegs.count_big_pegs(guess, @code_to_guess)
    @board.add_guess(guess, small_pegs, big_pegs)
    @board.print_single_guess
    big_pegs
  end

  def check_for_try_limit
    if @tries <= 0
      print_win_codemaker
      true
    else
      false
    end
  end

  def check_for_win(big_pegs)
    if big_pegs == 4
      print_game_over_codemaker
      return true
    end
    false
  end
end

# To greet player, choose game mode
class Intro
  include Messages
  def start_game
    print_logo
    print_rules
    puts 'Choose game mode you want to play (1- CODEMAKER/ 2 -CODEBEAKER)'
    input = gets.chomp until %w[1 2].include?(input)
    if input == '1'
      GameMaker.new.play_game
    else
      GameBreaker.new.play_game
    end
  end
end

game = Intro.new
game.start_game
