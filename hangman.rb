require 'yaml'

$dictionary = File.readlines("5desk.txt").collect do |line| 
	line.strip.downcase
end

class Word

	def initialize
		game_words = $dictionary.select { |word| word.length >= 5 && word.length <= 12 }

		@word = game_words[rand(game_words.length) - 1].split("")
	end

	def hide
		hidden_word = "_" * @word.length
		hidden_word
	end

	def guess
		letter = Guess.new.letter
		if @word.include?(letter)
			puts "you guessed right!"
		else
			puts "you guessed wrong"
			$game.incorrect_guesses += 1
			$game.incorrect_letters << letter + ", "
		end
		self.display(letter)
	end

	def display(letter)
		display_word = $game.current_view
		indexes = (0 ... @word.length).find_all { |i| @word[i] == letter }
		indexes.each do |i|
			display_word[i] = letter
			$game.correct_guesses += 1
			puts $game.correct_guesses
		end
		$game.current_view = display_word
	end
end

class Guess
	attr_accessor(:letter)
	def initialize
		puts "guess a letter"
		@letter = gets.chomp.downcase
	end
end

class Game
	attr_accessor(:correct_guesses, :incorrect_guesses, :incorrect_letters, :current_view)
	def initialize
		@secret = Word.new
		@correct_guesses = 0
		@incorrect_guesses = 0
		@incorrect_letters = ""
		@current_view = @secret.hide
	end

	def turn
		

		puts @current_view
		puts " Lives: #{'X' * @incorrect_guesses}#{'O' * (10 - @incorrect_guesses)}"
		puts "Letters you got wrong: #{@incorrect_letters}"
		puts %{would you like to save?
			1. Yes
			2. No, continue game}
		answer = gets.chomp
		if answer == '1'
			self.save
		end
		@secret.guess
	end

	def save
		cereal = YAML::dump(self)
		Dir.mkdir("saved_game") unless Dir.exists?("saved_game")
		filename = "saved_game/game"
		File.open(filename, 'w') do |file|
			file.puts cereal
		end
	end

	def won?
		if @correct_guesses == @current_view.length
			puts "well done!"
			true
		elsif @incorrect_guesses == 10
			puts "You Lose!"
			true
		else
			false
		end
	end
end

puts %{Load game?
			1. Yes
			2. No}
answer = gets.chomp
if answer == "1"
	cereal = File.open("saved_game/game")
	puts cereal
	$game = YAML::load(cereal)
else
	$game = Game.new
end




while $game.won? == false do
	$game.turn
end
