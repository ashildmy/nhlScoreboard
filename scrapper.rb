require 'rest-client'
require 'json'
require 'awesome_print'
require 'terminal-notifier'
require 'time'

URL = 'http://live.nhle.com/GameData/RegularSeasonScoreboardv3.jsonp'

class NHL
  attr_accessor :home_score
  attr_accessor :away_score

  def initialize(team, sounds)
    @team_name = team 
    if sounds.downcase == 'on'
      @sound = true
    else
      @sound = false
    end
  end

  def get_game
    resp = RestClient.get(URL)
    data = JSON.parse(resp.body[15..-2])

      data['games']
      .select { |game| game['atv'] == @team_name || game['htv'] == @team_name }
      .select { |game| game['bs'] == 'LIVE' || game['bsc'].empty?}
      .select { |game| game['ats'] = cleanup_score(game['ats']) }
      .select { |game| game['hts'] = cleanup_score(game['hts']) }
      .first
  end

  def print_score(game)
    set_score(game)
    home_team = capitalize_first_letter(game['htv'])
    away_team = capitalize_first_letter(game['atv'])

    score_announcement = "#{game['htn']} #{home_team}: #{@home_score} #{game['atn']} #{away_team}: #{@away_score}"
    ap score_announcement
    send_notification(game, score_announcement)
  end

  def send_notification(game, string)
    TerminalNotifier.notify(string, :title => 'Score Update', :appIcon => "nhl.png")
  end

  def capitalize_first_letter(string)
    string.slice(0,1).capitalize + string.slice(1..-1)
  end

  def check_for_hawks(string)
    play_hawks_song if string == 'blackhawks'
  end

  def set_score(game)
    # ap "#{@away_score} = #{game['ats']}"
    if @away_score < game['ats']
      @away_score = game['ats']
      check_for_hawks(game['atv']) 
    end

    # ap "#{@home_score} = #{game['hts']}"
    if @home_score < game['hts']
      @home_score = game['hts']
      check_for_hawks(game['htv'])
    end
  end

  def cleanup_score(score)
    score.empty? ? 0 : score.to_i
  end

  def play_hawks_song
    if @sound == true
      sleep(5)
      `play hawks.wav`
    end
  end

  def time_until_game(game)
    Time.parse(game['bs']) - Time.now
  end

  def check_if_game_is_today(game)
    if game['ts'] != 'TODAY'
      ap "Please try running this program again on #{game['ts']}."
      exit
    end
  end

  def is_game_over(game)
    if game['bs'] == 'FINAL'
      get_winner(game)
      exit
    end
  end

  def get_winner(game)
    if game['htc'] == 'winner'
      ap "#{game['htv'].capitalize_first_letter} win!!!"
    else
      ap "#{game['atv'].capitalize_first_letter} win!!!"
    end
  end

  def give_game_time(game)
    if game['tsc'].empty?
      ap "The #{game['htn']} #{capitalize_first_letter(game['htv'])} vs. #{game['atn']} #{capitalize_first_letter(game['atv'])} game is #{game['ts']} at #{game['bs']}."
      check_if_game_is_today(game)
      ap "This program will resume at that time."
      # ap Time.parse(game['bs']) - Time.now
      sleep(time_until_game(game))
      ap "The game is starting!!!"
    end
  end

  def check_valid_game(game)
    if game.nil?
      ap "The #{@team_name} game you're looking for is either over or not today"
      exit
    end
  end

end

def check_for_arguments()
  if ARGV[0].nil? || ARGV[1].nil?
    ap "Try running again with a NHL team name followed by on or off to indicate the playing of sounds"
    exit
  end
end

check_for_arguments
nhl = NHL.new(ARGV[0], ARGV[1])
nhl.home_score = 0;
nhl.away_score = 0;
game = nhl.get_game
nhl.check_valid_game(game)
nhl.give_game_time(game)
nhl.print_score(game)
while true do
  game = nhl.get_game
  if game['hts'].to_i != nhl.home_score || game['ats'].to_i != nhl.away_score 
    nhl.print_score(game)
  end
  sleep(5)
end

