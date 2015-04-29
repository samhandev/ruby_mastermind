require 'mastermind/guess'
require 'mastermind/code_score_calculator'
require 'ruby-prof'

module Mastermind
  class MinimaxAi

    def initialize
      @initial_guess = true
      @set_of_guesses = Guess.get_all_permutations
      @current_guess = "RRGG".split('')
    end

    def next_guess(exact_matches, unexact_matches)
      if initial_guess
        @initial_guess = false
        return current_guess
      end

      feedback = [exact_matches, unexact_matches]

      #filter out guesses based on feedback
      @set_of_guesses = filter_based_on_score(set_of_guesses, feedback, current_guess)

      #work out minimax score for each in the total set
      minimax_scores = Hash.new
      @set_of_guesses.each do |guess|
        minimax_scores[guess] = min_number_eliminated_from_all_possible_feedback(set_of_guesses, guess)
      end


      best_candidates = select_best_candidates(minimax_scores)
      
      #choose one from the set if possible
      best_candidates_in_set = best_candidates & set_of_guesses

      if best_candidates_in_set.count > 0
        @current_guess = best_candidates_in_set[0]
      else
        @current_guess = best_candidates[0]
      end

      #else choose other with max score
      @current_guess 
    end

    def select_best_candidates(minimax_scores)
      best_candidates = []

      minimax_scores.each do |guess, score|
        best_candidates << guess if score == minimax_scores.values.max
      end

      best_candidates
    end

    def available_permutations
      set_of_guesses
    end

    def filter_based_on_score(available_guesses, feedback, guess)
      code_score_calc = Mastermind::CodeScoreCalculator.new
      available_guesses.select do |a_guess|
        feedback == code_score_calc.score(guess, a_guess)
      end
    end

    def number_eliminated(available_guesses, feedback, guess)
      available_guesses.count - filter_based_on_score(available_guesses, feedback, guess).count
    end

    def min_number_eliminated_from_all_possible_feedback(available_guesses, guess)
      min_eliminated = 1296

      Guess::POSSIBLE_FEEDBACK.each do |feedback|
        this_min = number_eliminated(available_guesses, feedback, guess)
        if this_min < min_eliminated
          min_eliminated = this_min
        end
      end
      min_eliminated
    end

    private
    
    attr_reader :initial_guess, :set_of_guesses, :current_guess

  end
end
