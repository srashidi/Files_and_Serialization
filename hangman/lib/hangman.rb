# Class for hangman being gradually created
class DeadMan

  attr_accessor :wrong_letters, :wrong_guesses

  def initialize
    @wrong_letters = []
    @wrong_guesses = 0
  end

  def show_wrong_letters
    puts "These letters are not in the word: #{@wrong_letters.join(", ")}"
    puts "\n"
  end

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

  def initialize(word)
    @correct_word_array = word.upcase.split(//)
    @letters_guessed_array = Array.new(word.length,"__")
  end

  def display(dead_man)
    puts @letters_guessed_array.join(" ")
    puts "\n"
    dead_man.show_wrong_letters unless dead_man.wrong_letters.empty?
    dead_man.description unless dead_man.wrong_guesses == 0
  end

  def guess(input,dead_man)
    input.upcase!
    if input.length == 1
      letter_guess(input,dead_man) 
    else
      whole_word_guess(input,dead_man)
    end
  end

  def letter_guess(input,dead_man)
    if @letters_guessed_array.include?(input) || dead_man.wrong_letters.include?(input)
      puts "You have already guessed this letter!"
      display(dead_man)
    elsif @correct_word_array.include?(input)
      @letters_guessed_array.each_with_index do |letter, index|
        @letters_guessed_array[index] = input if @correct_word_array[index] == input
      end
      puts "The letter #{input} is in the word."
      display(dead_man)
      win unless @letters_guessed_array.include?("__")
    else
      puts "The letter #{input} is not in the word."
      dead_man.wrong_letters.push(input)
      dead_man.wrong_guesses += 1
      display(dead_man)
    end
  end

  def whole_word_guess(input,dead_man)
    guessed_word_array = input.split(//)
    if guessed_word_array == @correct_word_array
      puts "\n"
      @letters_guessed_array = @correct_word_array
      puts @letters_guessed_array.join(" ")
      puts "\n"
      win
    else
      puts "The word you have guessed is incorrect!"
      dead_man.wrong_guesses += 1
      display(dead_man)      
    end
  end

  def win
    puts "You have guess the whole word correctly! You have saved"
    puts "this man from a hanging!"
  end

end

class SaveGame
  def initialize(chosen_word,word_guess,dead_man)
  end
end

class Hangman

  def initialize
    puts "\nChoose from one of the following options:"
    puts "1: Start a new game"
    puts "2: Load a previously saved game"
    puts "3: Quit"
    choice = gets.chomp.strip
    case choice
    when "1"
      puts "\n"
      new_game
    when "2"
      puts "\n"
      load_game
    when "3"
      puts "\n"
      puts "Goodbye!"
    else
      puts "\n"
      puts "Invalid input. Try again..."
      initialize
    end
  end

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

  def load_game
    
  end

  def round
    puts "Guess a letter, guess the whole word, \"save game\" and exit,"
    puts "or \"exit game\" without saving."
    input = gets.chomp.strip
    case input
    when "exit game"
      initialize
    when "save game"
      saved_game = SaveGame.new(@chosen_word,@word_guess,@dead_man)
    else
      @word_guess.guess(input,@dead_man)
      if @word_guess.letters_guessed_array.include?("__")
        if @dead_man.wrong_guesses == 8
          initialize
        else
          round
        end
      else
        initialize
      end
    end
  end

end

start_game = Hangman.new