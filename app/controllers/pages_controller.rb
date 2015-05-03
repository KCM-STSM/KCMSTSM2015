class PagesController < ApplicationController
  def home
  end

  def teamtotals
  	 if user_signed_in?
      if current_admin_user
        @finances_grid = initialize_grid(Finance,
          :include => [:user])
        @total_cash = Finance.sum("cash_amount")
        @total_check = Finance.sum("check_amount")
        @total_amount = @total_cash + @total_check

		@team_total_cash = Array.new(Team.all.size + 1, 0);
		@team_total_check = Array.new(Team.all.size + 1, 0);
		@team_total_amount = Array.new(Team.all.size + 1, 0);


        User.all.each do |user|
		  #add all the funds of teams who aren't admins and aren't leaders
          if !user.leader
			@team_total_cash[user.team.to_i - 1] += user.finances.sum("cash_amount")
			@team_total_check[user.team.to_i - 1] += user.finances.sum("check_amount")
		  #the last "team" is the leaders' funds
		  else
			@team_total_cash[Team.all.size] += user.finances.sum("cash_amount")
			@team_total_check[Team.all.size] += user.finances.sum("check_amount")
		  end
		end
		#very...scrappy way of adding the totals
		for i in 0..Team.all.size
			@team_total_amount[i] = @team_total_cash[i] + @team_total_check[i]
		end
      end
    end
  end
  
  def teammanagement
	if user_signed_in?
      if current_user.leader?
	    @users = User.where(:team => current_user.team).order(:id)
		@total_amount = 0
		@member_total_amount = Array.new(@users.size, 0)
	
		@counter = 0
		@users.each do |u| 
		  @member_total_amount[@counter] = u.finances.sum("cash_amount") + u.finances.sum("check_amount")
		  if !u.leader?
		    @total_amount += @member_total_amount[@counter]
		  end
		  @counter += 1
		end
	  end
	end
  end
  
  def leaderlookup
	if user_signed_in?
	  if current_user.leader?
	    @user = User.find(params[:id])
		if current_user.team != @user.team
		  redirect_to root_path, notice: "Not authorized"
		else
		  @finances_grid = initialize_grid(Finance,
            :include => [:user],
            :order => 'finances.id',
            :order_direction => 'desc',
            :conditions => "user_id = #{@user.id}" )
          @total_cash = @user.finances.sum("cash_amount")
          @total_check = @user.finances.sum("check_amount")
          @total_amount = @total_cash + @total_check
		end
	  end
	end
  end
end
