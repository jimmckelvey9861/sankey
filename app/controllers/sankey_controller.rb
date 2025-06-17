class SankeyController < ApplicationController
  def index
    @months = SamplePipelineDataGenerator.generate_year_data(2025)
    month_param = params[:month].to_i
    month_param = 1 if month_param == 0
    month_data = @months[month_param - 1]

    @month_label = month_data[:month]
    @graph_data = SankeyLineageTransformer.transform(month_data)
  end
end