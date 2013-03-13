require 'spec_helper'

describe PufferPages::Handlers do
  before(:all) { @handlers = described_class.handlers }
  after(:all) { described_class.instance_variable_set(:@handlers, @handlers) }

  before { subject.instance_variable_set(:@handlers, nil) }

  context do
    let(:klass) do
      Class.new do
        attr_accessor :type
        def initialize type
          @type = type
        end

        def process *args
          "processed #{@type}, #{args.first}"
        end

        def codemirror_mode
          'mode'
        end
      end
    end
    before { subject.register klass, :html, :json }

    specify { subject.handlers[:html].should be_a klass }
    specify { subject.handlers[:json].should be_a klass }
    specify { subject.select.should == [
      ['translation missing: en.puffer_pages.handlers.html', :html, {"data-codemirror-mode" => "mode"}],
      ['translation missing: en.puffer_pages.handlers.json', :json, {"data-codemirror-mode" => "mode"}]
    ] }
    specify { subject.process('html', 'object').should == 'processed html, object' }
  end
end
