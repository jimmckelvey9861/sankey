class SankeyController < ApplicationController
  def index
    @months = SamplePipelineDataGenerator.generate_year_data(2025)

    month_param = params[:month].to_i
    month_param = 1 if month_param == 0
    month_data = @months[month_param - 1]

    sankey_data = SankeyLineageTransformer.transform(month_data)

    @month_label = month_data[:month]
    @nodes = sankey_data[:nodes]
    @node_x = sankey_data[:node_x]
    @node_y = sankey_data[:node_y]
    @links = sankey_data[:links]
  end
end