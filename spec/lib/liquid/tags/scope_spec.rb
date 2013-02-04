require 'spec_helper'

describe PufferPages::Liquid::Tags::Scope do
  let(:klass) do
    Class.new do
      include PufferPages::Backends::Mixins::Renderable

      def render *args
        render_template *args
      end
    end
  end
  let(:template) do
    klass.new
  end

  specify { template.render("{% scope foo: 'hello' %}{{ foo }}{% endscope %}").should == 'hello' }
end
