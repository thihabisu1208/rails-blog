class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def landing
    # Landing page is public - we'll build this in Week 1, Day 6-7
  end
end
