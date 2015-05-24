class Engine
  include ActiveModel::Model
  require 'date'

  attr_reader :parameters, :portfolio, :results
  attr_accessor :rebalance_frequency, :market_cap_floor, :market_cap_ceiling, :initial_balance, :use_dual_momentum

  def initialize(parameters=nil)
    @parameters = parameters
  end

  def run(args=nil)
    @portfolio = Portfolio.new(
      position_count: parameters[:position_count],
      initial_balance: parameters[:initial_balance],
      start_date: parameters[:start_date],
      rebalance_frequency: parameters[:rebalance_frequency]
    )
    PricePoint.all_periods(development: true).each do |period|
      period = period.to_s
      current_market_data = ScoreCalculator.new(
        market_cap_floor: parameters[:market_cap_floor], 
        market_cap_ceiling: parameters[:market_cap_ceiling],
        period: period
      ).assign_scores

      @portfolio.carry_forward(period) unless period == parameters[:start_date]
      target_portfolio = TargetPortfolio.new(
        current_portfolio_balance: @portfolio.as_of(period)[:total_market_value],
        position_count: @portfolio.position_count,
        current_market_data: current_market_data,
        parameters: parameters
        ).build
      @portfolio.rebalance(new_period: period, target: target_portfolio, parameters: parameters)
    end
    generate_results
    self
  end

  def generate_results
    @results = {}
    @results[:parameters] = parameters
    @results[:performance] = generate_performance
    @results[:positions] = generate_positions
  end

  def generate_performance
    result = []
    portfolio.periods.each do |date, state|
      next if date == portfolio.periods.first[0]
      this_period = {}
      this_period[:date] = date
      previous_period = (Date.strptime(date, '%Y-%m-%d') - 1.year).to_s
      this_period[:balance] = portfolio.as_of(date)[:total_market_value]
      previous_period_balance = portfolio.as_of(previous_period)[:total_market_value]
      this_period[:return_by_period] = this_period[:balance] / previous_period_balance - 1
      result << this_period 
    end
    result
  end

  def generate_positions

  end
end
