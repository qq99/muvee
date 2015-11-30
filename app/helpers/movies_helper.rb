module MoviesHelper

  ROW_LAYOUTS = {
    1 => {min_items: 1, max_items: 4},
    2 => {req_items: 3},
    3 => {req_items: 6},
    4 => {req_items: 3}
  }.freeze

  def layout(objects, prng)
    n_layouts = ROW_LAYOUTS.keys.size
    which_layout = (prng.rand() * n_layouts).to_i + 1
    layout = ROW_LAYOUTS[which_layout]

    number_to_take = layout[:req_items]
    if number_to_take.blank?
      min = layout[:min_items]
      max = layout[:max_items]
      number_to_take = (prng.rand() * max).to_i + min
    end

    # hacky solution to make sure we have a full row at all times:
    if number_to_take > objects.size
      if objects.size <= 4 # take some and stick in layout 1
        which_layout = 1
        number_to_take = [4, objects.size].min
      end
    end

    render "shared/row_style_#{which_layout}", objects: objects.shift(number_to_take)
  end

end
