module MoviesHelper

  ROW_LAYOUTS = {
    1 => {min_items: 1, max_items: 4},
    2 => {req_items: 3},
    3 => {req_items: 6},
    4 => {req_items: 3}
  }.freeze

  def layout(movies)
    n_layouts = ROW_LAYOUTS.keys.size
    which_layout = (rand() * n_layouts).to_i + 1
    layout = ROW_LAYOUTS[which_layout]

    number_to_take = layout[:req_items]
    if number_to_take.blank?
      min = layout[:min_items]
      max = layout[:max_items]
      number_to_take = (rand() * max).to_i + min
    end
    render "row_style_#{which_layout}", movies: movies.shift(number_to_take)
  end

end
