class GamesController < ApplicationController
  # Lists all the games
  def index
    @games = Game.all.sort_by { |game| game.start_time }
  end

  # Checks if user is signed in, they can buy-in and view a game to submit.
  def show
    if user_signed_in?
      game_id = params[:id]
      @drafted_players = DraftedPlayer.where(game_id: game_id).order(:tier)
      @game = Game.find(game_id)

      if ParticipatingUser.where(game_id: @game.id, user_id: current_user.id)
        @selections = DraftPick.where(user_id: current_user.id)
        @selection_ids = @selections.map {|s| s.drafted_player_id }
      end

      if @game
        render action: :show
      else
        render file: 'public/404', status: 404, formats: [:html]
      end
    else
      flash[:alert] = 'You need to sign in or create an account in order to play.'
      redirect_to '/'
    end
  end

  def live
    if user_signed_in?
      game_id = params[:id]
      @game = Game.find(game_id)

      # Gets our users picks for the game
      @userPicks = []
      allUsersPicks = DraftPick.where(user_id: current_user.id)
      allUsersPicks.each do |pick|
        searchDraftedPlayer = DraftedPlayer.where(id: pick.drafted_player_id, game_id: game_id)[0]
        @userPicks << Player.where(id: searchDraftedPlayer.player_id)[0]
      end

      # Gets all of the users in the game.
      usersForGame = ParticipatingUser.where(game_id: @game.id)
      @userList = []
      usersForGame.each do |user|
        @userList << User.where(id: user.user_id)[0]
      end

      if @game && @game.start_time < DateTime.now
        render action: :live
      else
        render file: 'public/404', status: 404, formats: [:html]
      end
    end
  end

  def getuser
    theUser = params[:user]
    game_id = params[:id]
    @game = Game.find(game_id)

    @theUserObject = Game.get_user_by_username(theUser)

    @userPicks = []
    allUsersPicks = DraftPick.where(user_id: @theUserObject.id)
    allUsersPicks.each do |pick|
      searchDraftedPlayer = DraftedPlayer.where(id: pick.drafted_player_id, game_id: game_id)[0]
      @userPicks << Player.where(id: searchDraftedPlayer.player_id)[0]
    end

    if theUser
      render action: :getuser
    else
      render file: 'public/404', status: 404, formats: [:html]
    end

  end

end
