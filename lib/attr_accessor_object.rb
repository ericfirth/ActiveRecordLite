class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      instance_variable = "@#{name}".to_sym
      setter = "#{name}="
      define_method(setter) do |new_name|
        self.instance_variable_set(instance_variable, new_name)
      end

      define_method(name) do
        self.instance_variable_get(instance_variable)
      end
    end
  end
end
