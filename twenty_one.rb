CARDS_TO_WIN = 21
DEALER_HITS_UNTIL = 17
SUITS = ['H', 'D', 'S', 'C']
VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
DISPLAY_SCORE_ALWAYS = true # can be true for debugging
# or false for realistic play.

def initialize_deck
  SUITS.product(VALUES).shuffle
end

def prompt(msg)
  puts "=> #{msg}"
end

# rubocop:disable Metrics/AbcSize
def draw_card_image(card, cards_image)
  cards_image[0] << "+-------+ "
  cards_image[1] << "| #{card[1].ljust(2)}    | "
  cards_image[2] << "|       | "
  cards_image[3] << "| - #{card[0]} - | "
  cards_image[4] << "|       | "
  cards_image[5] << "|    #{card[1].rjust(2)} | "
  cards_image[6] << "+-------+ "
  cards_image
end
# rubocop:enbable Metrics/AbcSize

def draw_downcard_image(cards_image)
  cards_image[0] << "+-------+ "
  cards_image[1] << "|       | "
  cards_image[2] << "|   |   | "
  cards_image[3] << "|  - -  | "
  cards_image[4] << "|   |   | "
  cards_image[5] << "|       | "
  cards_image[6] << "+-------+ "
end

def init_cards_image
  cards_image = []
  7.times { |element| cards_image[element] = '' }
  cards_image
end

def display_some_cards(cards)
  cards_image = init_cards_image
  draw_downcard_image(cards_image)
  draw_card_image(cards[1], cards_image)
  puts cards_image
end

def display_all_cards(cards)
  cards_image = init_cards_image
  cards.each { |card| draw_card_image(card, cards_image) }
  puts cards_image
end

def dealer_draw(dealer_cards, deck)
  until total(dealer_cards) >= DEALER_HITS_UNTIL
    dealer_cards << draw(deck)
    break if busted?(dealer_cards)
  end
end

def display_score(score_games)
  puts "+#{' GAME SCOREBOARD '.center(48, '-')}+"
  puts "|#{' DEALER '.center(24)}#{'PLAYER'.center(24)}|"
  puts "|#{score_games[0].to_s.center(24)}#{(score_games[1]).to_s.center(24)}|"
  puts "+#{''.center(48, '-')}+"
  puts ''
end

def display_banner_messages(cards1_total, cards2_total)
  total1_string = cards1_total.to_s.center(6)
  if cards1_total == cards2_total
    puts " TIE  TIE  TIE |#{total1_string}| TIE  TIE  TIE ".center(50, "~ ")
  elsif busted?(cards1_total)
    puts " BUSTED  BUSTED |#{total1_string}| BUSTED  BUSTED ".center(50, "~ ")
  elsif winner?(cards1_total, cards2_total)
    puts " WINNER  WINNER |#{total1_string}| CHIK'N  DINNER ".center(50, "! ")
  else
    puts "  |#{total1_string}|  ".center(50, "~ ")
  end
end

def display_banner_details(totals_info, name)
  total_string = totals_info.to_s.center(6)

  puts " #{name} ".center(50, "*")
  if DISPLAY_SCORE_ALWAYS
    puts "  | #{total_string} |".center(50, "~ ")
  else
    puts "".center(50, "~ ")
  end
  puts " #{name} ".center(50, "*")
end

def display_banner_for_dealer_in_play(totals)
  display_banner_details(totals[0], 'DEALER')
end

def display_banner_for_player_in_play(totals)
  display_banner_details(totals[1], 'PLAYER')
end

def display_banner_details_at_end(total1, total2, name)
  puts " #{name} ".center(50, "*")
  display_banner_messages(total1, total2)
  puts " #{name} ".center(50, "*")
end

def display_banner_for_dealer_at_end(totals)
  display_banner_details_at_end(totals[0], totals[1], 'DEALER')
end

def display_banner_for_player_at_end(totals)
  display_banner_details_at_end(totals[1], totals[0], 'PLAYER')
end

def display_game_table_in_play(players,
                               totals,
                               score_games)
  system('clear')
  display_score(score_games)
  display_banner_for_dealer_in_play(totals)
  display_some_cards(players[0])
  puts ''
  puts ''
  display_banner_for_player_in_play(totals)
  display_all_cards(players[1])
  puts ''
  puts ''
end

def display_game_table_at_end(players,
                              totals,
                              score_games)
  system('clear')
  display_score(score_games)
  display_banner_for_dealer_at_end(totals)
  display_all_cards(players[0])
  puts ''
  puts ''
  display_banner_for_player_at_end(totals)
  display_all_cards(players[1])
  puts ''
  puts ''
end

def draw(deck)
  deck.delete(deck.sample)
end

def deal(players, deck)
  players.each do |cards|
    2.times { cards << draw(deck) }
  end
end

def total(cards)
  values = cards.map { |card| card[1] }

  sum = 0
  values.each do |value|
    sum += if value == 'A'
             11
           elsif value.to_i == 0
             10
           else
             value.to_i
           end
  end

  # Correct for aces
  values.count('A').times do
    sum -= 10 if sum > CARDS_TO_WIN
  end

  sum
end

def busted?(total)
  total > CARDS_TO_WIN
end

def winner?(cards1_total, cards2_total)
  return true if busted?(cards2_total)
  return true if cards1_total > cards2_total
  false
end

def play_again?
  puts "----------------------"
  prompt "Do you want to play again? (y or n)"
  loop do
    answer = gets.chomp.downcase
    case answer
    when 'y'
      break true
    when 'n'
      break false
    else
      prompt "Invalid response, please enter y or n."
    end
  end
end

score_games = [0, 0]
loop do
  # Initialize Variables
  player_cards = []
  dealer_cards = []
  players = [dealer_cards, player_cards]
  deck = initialize_deck

  deal(players, deck)
  player_total = total(player_cards)
  dealer_total = total(dealer_cards)
  totals = [dealer_total, player_total]

  display_game_table_in_play(players, totals, score_games)
  prompt("Welcome to Twenty-One!")

  loop do
    player_turn = nil
    loop do
      prompt "Would you like to (h)it or (s)tay?"
      player_turn = gets.chomp.downcase
      break if ['h', 's'].include?(player_turn)
      prompt("Sorry, must enter 'h' or 's'")
    end

    player_cards << draw(deck) if player_turn == 'h'
    totals[1] = player_total = total(player_cards)
    display_game_table_in_play(players, totals, score_games)
    break if player_turn == 's' || busted?(player_total)
  end

  if busted?(player_total)
    prompt 'Game Over'
  else
    until total(dealer_cards) >= DEALER_HITS_UNTIL
      dealer_cards << draw(deck)
      totals[0] = dealer_total = total(dealer_cards)
      break if busted?(dealer_total)
    end
  end

  if winner?(dealer_total, player_total) && !busted?(dealer_total)
    score_games[0] += 1
  end
  if winner?(player_total, dealer_total) && !busted?(player_total)
    score_games[1] += 1
  end
  display_game_table_at_end(players, totals, score_games)

  break if score_games.any? { |score| score >= 5 }
  play_again? ? next : break
end

puts "GAME OVER!"
puts ''
puts "!!! DEALER WINS !!!" if score_games[0] > score_games[1]
puts "!!! PLAYER WINS !!!" if score_games[1] > score_games[0]
puts "IT'S A TIE" if score_games[0] == score_games[1]
