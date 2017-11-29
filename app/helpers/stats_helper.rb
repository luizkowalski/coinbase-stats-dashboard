module StatsHelper
  def label_css_class(value)
    value.positive? ? 'label-success' : 'label-danger'
  end
end
