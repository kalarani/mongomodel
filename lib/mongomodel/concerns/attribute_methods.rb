module MongoModel
  module AttributeMethods
    extend ActiveSupport::Concern
    
    include ActiveModel::AttributeMethods
    
    module ClassMethods
      # Generates all the attribute related methods for defined properties
      # accessors, mutators and query methods.
      def define_attribute_methods
        return if attribute_methods_generated?
        super(properties.keys)
        @attribute_methods_generated = true
      end
      
      def attribute_methods_generated?
        @attribute_methods_generated ||= false
      end
      
      def undefine_attribute_methods(*args)
        super
        @attribute_methods_generated = false
      end
      
      def property(*args)
        property = super
        undefine_attribute_methods
        property
      end
    end
    
    def method_missing(method, *args, &block)
      unless self.class.attribute_methods_generated?
        self.class.define_attribute_methods

        if respond_to_without_attributes?(method)
          send(method, *args, &block)
        else
          super
        end
      else
        super
      end
    end
    
    def respond_to?(*args)
      self.class.define_attribute_methods unless self.class.attribute_methods_generated?
      super
    end
    
    def clone_attribute_value(attribute_name)
      value = read_attribute(attribute_name)
      value.duplicable? ? value.clone : value
    rescue TypeError, NoMethodError
      value
    end
    
  protected
    def attribute_method?(attr_name)
      properties.has_key?(attr_name)
    end
  end
end
