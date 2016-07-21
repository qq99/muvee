module PrettyUrls
  extend ActiveSupport::Concern

  module ClassMethods
    def pretty_url_by(*args)
      self.class_variable_set('@@pretty_methods', args)
    end
  end

  included do
    def to_param
      slug_chain = [:id] + self.class.class_variable_get('@@pretty_methods')
      slug_chain.map{|s|
        self.send(s)
      }.reject(&:blank?).map(&:to_s).map(&:parameterize).join('-')
    end
  end
end
