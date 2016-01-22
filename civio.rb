require 'mechanize'
require 'csv'
require 'pry'

class ScrapPlayers

  URL = 'http://es.soccerway.com/national/spain/primera-division/20152016/regular-season/r31781/players/?ICID=PL_3N_04'
  CSV_FILE = 'civio.csv'

  def scrap
    result = []
    mechanize = Mechanize.new
    page = mechanize.get(URL)

    players_s =  get_players(page)
    players_a = slice_players(players_s)
    goals_s = get_goals(page)
    goals_a = slice_goals(goals_s)  

    links = page.links_with(:href => /players/)
    photos = get_photos(links)
    games = get_games(links)

    result = merge_info(players_a,goals_a,photos,games)
    
    save_csv(result)

  end

  private

    def get_players page
      players = []
      clubs_s = page.search('td a').first(30)
      clubs_s.each do |l|
        players << l.text
      end
      players
    end

    def slice_players players_S
      players_a = players_S.each_slice(2).to_a
    end

    def get_goals page
      goal_s = page.search('tr td.goals')
    end

    def slice_goals goals_s
      goals_a = []
      goals_s.each do |l|
        goals_a << l.text.to_i
      end
      goals_a
    end

    def get_photos links
      photos = []
      links[4..-1].each do |link|
        page = link.click
        photo = page.search('.yui-u img')
        photos << photo.attribute('src').value  
      end
      photos
    end

    def get_games links
     games = []
     links[4..-1].each do |link|
       page = link.click
       num_games = page.search('td.appearances').first
       games << num_games.text.to_i
     end
     games
    end

    def merge_info players_a,goals_a,photos,games
      players_a.each_with_index  do |a,index|
        players_a[index] << goals_a[index]
        players_a[index] << photos[index]
        players_a[index] << games[index]
      end
      players_a
    end

    def save_csv(final_array)
      CSV.open(File.join(Dir.pwd, CSV_FILE), 'ab') do |csv_file|
        final_array.each do |row|
          csv_file << row
        end
        puts 'file read !'
      end
    end

end

players = ScrapPlayers.new()
players.scrap








