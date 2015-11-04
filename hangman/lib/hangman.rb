require 'yaml'

# Class for hangman being gradually created
class DeadMan

  attr_accessor :wrong_letters, :wrong_guesses

  # Starts a fresh hangman person
  def initialize
    @wrong_letters = []
    @wrong_guesses = 0
  end

  # Displays letters that have been guessed incorrectly
  def show_wrong_letters
    puts "These letters are not in the word: #{@wrong_letters.join(", ")}"
    puts "\n"
  end

  # Displays a description of the hangman based on how many wrong guesses
  # have been made
  def description
    case @wrong_guesses
    when 1
      puts "The head has been drawn."
    when 2
      puts "The head and body have been drawn."
    when 3
      puts "The head, body, and one arm have been drawn."
    when 4
      puts "The head, body, and arms have been drawn."
    when 5
      puts "The head, body, arms, and one leg have been drawn."
    when 6
      puts "The head, body, arms, and legs have been drawn."
    when 7
      puts "The head, body, arms, legs, and one eye have been drawn."
      puts "One more wrong move, and he's dead!"
    when 8
      puts "The head, body, arms, legs, and eyes have been drawn."
      puts "The hangman's dead, and you've lost!"
    end
    puts "\n"
  end

end

# Class for word guess
class WordGuess

  attr_accessor :letters_guessed_array

  # Initialize the correct letters and guessed letters arrays
  def initialize(word)
    @correct_word_array = word.upcase.split(//)
    @letters_guessed_array = Array.new(word.length,"__")
  end

  # Display the current status of guesses
  def display(dead_man)
    puts @letters_guessed_array.join(" ")
    puts "\n"
    dead_man.show_wrong_letters unless dead_man.wrong_letters.empty?
    dead_man.description unless dead_man.wrong_guesses == 0
  end

  # Determines if a letter or word is being guessed
  def guess(input,dead_man)
    input.upcase!
    if input.length == 1
      letter_guess(input,dead_man) 
    else
      whole_word_guess(input,dead_man)
    end
  end

  # Determines if a letter guessed is correct or incorrect
  def letter_guess(input,dead_man)
    if @letters_guessed_array.include?(input) || dead_man.wrong_letters.include?(input)
      puts "You have already guessed this letter!"
      display(dead_man)
    elsif @correct_word_array.include?(input)
      @letters_guessed_array.each_with_index do |letter, index|
        @letters_guessed_array[index] = input if @correct_word_array[index] == input
      end
      puts "The letter #{input} is in the word."
      if @letters_guessed_array.include?("__")
        display(dead_man)
      else
        win
      end
    else
      puts "The letter #{input} is not in the word."
      dead_man.wrong_letters.push(input)
      dead_man.wrong_guesses += 1
      display(dead_man)
    end
  end

  # Determines if a word guessed is correct or incorrect
  def whole_word_guess(input,dead_man)
    guessed_word_array = input.split(//)
    if guessed_word_array == @correct_word_array
      win
    else
      puts "The word you have guessed is incorrect!"
      dead_man.wrong_guesses += 1
      display(dead_man)      
    end
  end

  # Gives a message if the player wins
  def win
    puts "\n"
    @letters_guessed_array = @correct_word_array
    puts @letters_guessed_array.join(" ")
    puts "\n"
    puts "You have guess the whole word correctly! You have saved"
    puts "this man from a hanging!"
  end

end

# Class for playing a game of Hangman
class Hangman

  # Initialize a new game of Hangman with an option menu
  def initialize(game_type,*p)
    if game_type == :new_game
      new_game
    elsif game_type == :load_game
      load_game(p[0],p[1],p[2])
    end 
  end

  # Starting a new round of Hangman
  def new_game
    dictionary = File.readlines("assets/5desk.txt").map {|word| word.chomp}
    dictionary.select! {|word| word.length >= 5 && word.length <= 12}
    @chosen_word = dictionary[(dictionary.size * rand).floor]

    puts "A word has been chosen that is #{@chosen_word.length} letters long."
    puts "You may guess the letters in that word one letter at a time,"
    puts "or you may guess the whole word, but a man's life \"hangs\" in"
    puts "the balance. So be careful not to make too many wrong guesses,"
    puts "because once his whole body and both of his eyes have been"
    puts "drawn, he's dead and you lose!"
    puts "\n"

    @word_guess = WordGuess.new(@chosen_word)
    @dead_man = DeadMan.new

    round
  end

  # Loading a previous game of Hangman
  def load_game(chosen_word,word_guess,dead_man)
    @chosen_word = chosen_word
    @word_guess = word_guess
    @dead_man = dead_man

    @word_guess.display(@dead_man)
    round
  end

  # Each turn in a game of Hangman
  def round
    puts "Guess a letter, guess the whole word, \"save\" game and exit,"
    puts "or \"exit\" game without saving."
    input = gets.chomp.strip
    case input
    when "exit"
      GameMenu.new
    when "save"
      saved_game = SaveGame.new(@chosen_word,@word_guess,@dead_man,Time.now)
      saved_game.dump
      GameMenu.new
    when ""
      puts "\n"
      round
    else
      @word_guess.guess(input,@dead_man)
      if @word_guess.letters_guessed_array.include?("__")
        if @dead_man.wrong_guesses == 8
          GameMenu.new
        else
          round
        end
      else
        GameMenu.new
      end
    end
  end

end

# Houses a saved game
class SaveGame

  attr_reader :chosen_word, :word_guess, :dead_man, :time

  # Initializes a saved game using given information
  def initialize(chosen_word,word_guess,dead_man,time)
    @chosen_word = chosen_word
    @word_guess = word_guess
    @dead_man = dead_man
    @time = time
  end

  # Saves the game as yaml to saved_game
  def dump
    File.open("saved_games.yaml", "a") do |out|
      YAML::dump(self, out)
    end
  end

  # Initiates a menu to access and select saved games
  def self.load
    i = 1
    File.new("saved_games.yaml","w") unless File.exist?("saved_games.yaml")
    if File.read("saved_games.yaml").empty?
      puts "There are no saved games, yet."
      GameMenu.new
    else
      YAML.load_stream(File.open("saved_games.yaml")) do |saved_game|
        puts "#{i}: " + saved_game.time.strftime("%m/%d/%Y %I:%M%P")
        i += 1
      end
      puts "\n"
      puts "Choose a game to load or \"exit\" to menu:"
      game_index = gets.chomp.strip.downcase
      if game_index == "exit"
        GameMenu.new
      elsif game_index.to_i <= i && game_index.to_i >= 1
        game_index = game_index.to_i
        i = 1
        File.new("temp.yaml","w")
        puts "\n"
        YAML.load_stream(File.open("saved_games.yaml")) do |game|
          if i == game_index
            @chosen_word = game.chosen_word
            @word_guess = game.word_guess
            @dead_man = game.dead_man
          else
            File.open("temp.yaml","a") do |out|
              YAML::dump(game,out)
            end
          end
          i += 1
        end
        File.delete("saved_games.yaml")
        File.rename("temp.yaml","saved_games.yaml")
        Hangman.new(:load_game,@chosen_word,@word_guess,@dead_man)
      else
        puts "Invalid input. Try again..."
        puts "\n"
        SaveGame.load
      end
    end
  end

end

# Opens a new game menu
class GameMenu

  # Gives choices to the player for how to start/continue a game
  def initialize
    puts "\nChoose from one of the following options:"
    puts "1: Start a new game"
    puts "2: Load a previously saved game"
    puts "3: Quit"
    choice = gets.chomp.strip
    case choice
    when "1"
      puts "\n"
      Hangman.new(:new_game)
    when "2"
      puts "\n"
      SaveGame.load
    when "3"
      puts "\n"
      puts "Goodbye!"
    else
      puts "\n"
      puts "Invalid input. Try again..."
      initialize
    end
  end

end

# Opens the options menu for Hangman
start_game = GameMenu.new