class EngineWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  include ActiveModel::Model
  require 'date'

  attr_reader :parameters, :portfolio
  attr_accessor :rebalance_frequency, :market_cap_floor, :market_cap_ceiling, :initial_balance, :use_dual_momentum

  def initialize(parameters=nil)
    @parameters = parameters
  end

  def perform(args=nil)
    @portfolio = Portfolio.new(
      position_count: parameters["position_count"],
      initial_balance: parameters["initial_balance"],
      start_date: parameters["start_date"],
      rebalance_frequency: parameters["rebalance_frequency"]
    )

    PricePoint.all_periods(development: true).each do |period|
      period = period.to_s
      store current_period: period
      
      current_market_data = ScoreCalculator.new(
        market_cap_floor: parameters["market_cap_floor"], 
        market_cap_ceiling: parameters["market_cap_ceiling"],
        period: period
      ).assign_scores

      @portfolio.carry_forward(period) unless period == parameters["start_date"]

      target_portfolio = TargetPortfolio.new(
        current_portfolio_balance: @portfolio.as_of(period)[:total_market_value],
        position_count: @portfolio.position_count,
        current_market_data: current_market_data,
        parameters: parameters
        ).build
      @portfolio.rebalance(new_period: period, target: target_portfolio, parameters: parameters)
    end
    self
  end
end