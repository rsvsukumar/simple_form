require 'simple_form/abstract_component'
require 'simple_form/label'
require 'simple_form/input'
require 'simple_form/hint'
require 'simple_form/error'

module SimpleForm
  class FormBuilder < ActionView::Helpers::FormBuilder
    # Components used by the folder builder. By default is:
    # [SimpleForm::Label, SimpleForm::Input, SimpleForm::Hint, SimpleForm::Error]
    cattr_accessor :components, :instance_writer => false
    @@components = [SimpleForm::Label, SimpleForm::Input, SimpleForm::Hint, SimpleForm::Error]

    # Make the template accessible for components
    attr_reader :template

    def input(attribute, options={})
      # TODO Do this makes sense since we are delegating to components?
      options.assert_valid_keys(:as, :label, :required, :hint, :options, :html,
                                 :collection, :label_method, :value_method)

      input_type = (options[:as] || default_input_type(attribute, options)).to_sym

      pieces = self.components.collect do |klass|
        next if options[klass.basename] == false
        klass.new(self, attribute, input_type, options).generate
      end

      pieces.compact.join
    end

    private

      def default_input_type(attribute, options)
        column = @object.column_for_attribute(attribute)
        input_type = column.type
        case input_type
          when :decimal, :integer then :numeric
          when :timestamp then :datetime
          when nil, :string then
            attribute.to_s =~ /password/ ? :password : :string
          else input_type
        end
      end

  end
end
