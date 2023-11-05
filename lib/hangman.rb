require 'yaml'


class Hangman ()
    def initialize ()
        if Dir.exist?('games')
            puts "Would you like to open a saved game. Enter y/n"
        end
        if gets.chomp == 'y'
            open_game()
            return
        end
        dictionary = []
        IO.readlines("raw.githubusercontent.com_first20hours_google-10000-english_master_google-10000-english-no-swears.txt").each do |line|
            line = line.strip
            if line.length > 4 && line.length < 13
                dictionary.push(line)
            end
        end
        @word = dictionary.sample.split("")
        puts @word
        @guesses_left = 10
        @correct_guesses = []
        @incorrect_guesses = []
        @word.length.times {@correct_guesses.push("_")}
        puts "Welcome to Hangman. When prompted, enter the letter of your guess."
        turn()
    end
        

    def turn ()
        puts "Would you like to save your game? Enter y/n"
        if gets.chomp == "y"
            save_game()
            return
        end
        puts 'Please type your guess'
        good_move = move(gets.chomp.downcase)
        puts
        if good_move
            puts "Correct guess"
        else
            puts "Incorrect guess"
            @guesses_left -= 1
        end
        puts
        turn_output()
        unless @correct_guesses.any?('_')
            puts "You win"
            puts "Would you like to play again. Enter y/n"
            if gets.chomp == "y"
                new_hangman = Hangman.new
            end
            puts "Exit message"
            return
        end
        if @guesses_left == 0
            puts "You lose"
            puts "Would you like to play again. Enter y/n"
            if gets.chomp == "y"
                new_hangman = Hangman.new
            end
            puts "Exit message"
            return
        end
        turn()
    end

    def move (letter)
        l_index = @word.each_with_index.select {|l, index| l == letter}.map {|pair| pair[1]}
        unless l_index.empty?
            l_index.each { |i| @correct_guesses[i] = letter }
            return true
        end
        @incorrect_guesses << letter
        return false

    end

    def save_game ()
        new_file = YAML.dump ({
            :word => @word,
            :correct_guesses => @correct_guesses,
            :incorrect_guesses => @incorrect_guesses,
            :guesses_left => @guesses_left
        })

        Dir.mkdir('games') unless Dir.exist?('games')
        namer = @correct_guesses.join("")
        filename = "games/game of #{namer}.yml"
        File.open(filename, 'w') do |file|
            file.puts new_file
        end
    end

    def open_game ()
        puts Dir.entries('games')
        puts 'Please type the name of the game you would like to resume. Only include the unfinished word, without "game of " or the .yml extention'
        game_name = gets.chomp
        filename = "games/game of #{game_name}.yml"
        loaded_game = File.read(filename)
        File.delete(filename)
        loaded_game = YAML.load loaded_game
        @word = loaded_game[:word]
        @correct_guesses = loaded_game[:correct_guesses]
        @incorrect_guesses = loaded_game[:incorrect_guesses]
        @guesses_left = loaded_game[:guesses_left]
        turn_output()
        puts "Welcome to Hangman. When prompted, enter the letter of your guess."
        turn()

    end

    def turn_output ()
        puts 'Current guesses'
        @correct_guesses.each do |letter|
            print letter + ' '
        end
        puts
        puts 'Incorrect guesses'
        @incorrect_guesses.each do |letter|
            print letter + ' '
        end
        puts
        puts "You have #{@guesses_left} guesses left"
    end
end

new_hangman = Hangman.new