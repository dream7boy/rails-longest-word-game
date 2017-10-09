require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def game
    @grid = generate_grid(9)
    @start = @grid.join(" ")
    @start_time = Time.now
    # session[:grid] = grid
    # session[:start_time] = start_time
    # score(@grid, @start_time)
    # raise
  end

  def score
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    grid = params[:grid].split('')
    @answer = params[:answer]
    # raise
    @result = run_game(@answer, grid, start_time, end_time)
  end

  def generate_grid(grid_size)
  empty_array = []
  grid_size.times { empty_array << ("A".."Z").to_a.sample }
  empty_array
  end

  def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result

    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    answer = JSON.parse(open(url).read, symbolize_names: true)

    result = Hash.new(0)

    result[:time] = end_time - start_time

    unless validating_grid(attempt, grid, result).nil? || validating_number_letters(attempt, grid, result).nil?
      check_english_and_score(result, answer)
    end
    result
  end

  def validating_grid(given_attempt, given_grid, given_result)
    given_attempt.upcase.chars.each do |letter|
      unless given_grid.include?(letter)
        given_result[:message] = "The letter is not in the grid"
        break
      end
    end
  end

  def validating_number_letters(given_attempt, given_grid, given_result)
    given_attempt.upcase.chars.each do |letter|
      if given_attempt.upcase.count(letter) > given_grid.count(letter)
        given_result[:message] = "The letter is not in the grid"
        break
      end
    end
  end

  def check_english_and_score(given_result, given_answer)
    if given_answer[:found] == false
      given_result[:message] = "The word is not an english word"
    else
      given_result[:message] = "Well Done!"
      given_result[:score] = given_answer[:length].to_i
      given_result[:score] += (30 - given_result[:time])
    end
  end
end
