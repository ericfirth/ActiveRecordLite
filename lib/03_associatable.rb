require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
    # ...
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: "#{name}_id".to_sym,
      class_name: name.to_s.camelcase,
      primary_key: :id,
    }
    options = defaults.merge(options)
    options.each do |k, v|
      k = "#{k.to_s}="
      self.send(k, v)
    end

  end
end



class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: "#{self_class_name.to_s.downcase}_id".to_sym,
      class_name: name.to_s.singularize.camelcase,
      primary_key: :id,
    }
    options = defaults.merge(options)
    options.each do |k, v|
      k = "@#{k}".to_sym
      self.instance_variable_set(k, v)
    end
    # ...
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      foreign_key = options.send(:foreign_key)
      foreign_key = self.send(foreign_key)
      result = options.model_class.where({id: foreign_key})
      result.first

    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    # byebug
    define_method(name) do
      foreign_key = options.send(:foreign_key)
      result = options.model_class.where({foreign_key => self.id})
    end
  end
  #
  # has_many :humans
  #   class_name: "Human",
  #   foreign_key: :human_id,
  #   primary_key: :id

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
