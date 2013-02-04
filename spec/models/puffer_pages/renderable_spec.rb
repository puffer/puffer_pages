# encoding: UTF-8
require 'spec_helper'

describe PufferPages::Backends::Mixins::Renderable do
  let(:klass) do
    Class.new do
      include PufferPages::Backends::Mixins::Renderable
    end
  end
  subject { klass.new }

  def merge *args
    subject.send(:merge_context, *args)
  end

  describe "#normalize_render_options" do
    let(:string) { 'Hello ^^' }
    let(:object) { Object.new }
    let(:hash) { { a: 1 } }
    let(:another_hash) { { b: 2 } }
    let(:context) { ::Liquid::Context.new }

    def normalize *args
      subject.send(:normalize_render_options, *args)
    end

    specify { normalize(string, context, hash).should == [string, merge(context, hash)] }
    specify { normalize(object, context, hash).should == [object, merge(context, hash)] }
    specify { normalize(context, hash).should == [nil, merge(context, hash)] }
    specify { normalize(string, hash, another_hash).should == [string, merge(hash, another_hash)] }
    specify { normalize(hash, another_hash).should == [nil, merge(hash, another_hash)] }
    specify { normalize(string, context).should == [string, merge(context, {})] }
    specify { normalize(string, hash).should == [string, merge(hash, {})] }
    specify { normalize(context).should == [nil, context] }
    specify { normalize(hash).should == [nil, merge(hash, {})] }
    specify { expect { normalize(string, context, hash, 42).should }.to raise_error ArgumentError }
  end

  describe "#merge_context" do
    let(:hash) { { a: 1 } }
    let(:another_hash) { { registers: { b: 2 }, environment: { c: 3 } } }
    let(:context) { ::Liquid::Context.new }

    specify { merge(hash, {}).should == { drops: { 'a' => 1 }, environment: {}, registers: {} } }
    specify { merge(another_hash, {}).should == { drops: {}, environment: { c: 3 }, registers: { b: 2 } } }
    specify { merge(hash, another_hash).should == { drops: { 'a' => 1 }, environment: { c: 3 }, registers: { b: 2 } } }
    specify { merge(context, {}).should == context }
    specify { merge(context, hash)['a'].should == 1 }
    specify { merge(context, hash).registers.should == {} }
    specify { merge(context, another_hash).registers.should == { b: 2 } }
  end

  describe "#normalize_context_options" do
    let(:hash1) { { a: 1 } }
    let(:hash2) { { b: 2 } }
    let(:hash3) { { c: 3 } }

    def normalize *args
      subject.send(:normalize_context_options, *args)
    end

    specify { normalize(foo: hash1).should == { drops: { 'foo' => hash1 }, environment: {}, registers: {} } }
    specify { normalize(drops: { 'a' => 1 }, environment: hash2, registers: hash3).should ==
      { drops: { 'a' => 1 }, environment: hash2, registers: hash3 } }
    specify { normalize(environment: hash1, foo: hash2).should ==
      { drops: { 'environment' => hash1, 'foo' => hash2 }, environment: {}, registers: {} } }
  end

  describe "#render_template" do
    def render *args
      subject.send(:render_template, *args)
    end

    context 'with hash context' do
      specify { render("{{ hello }}", hello: 'Hello').should == 'Hello' }
    end

    context 'with object context' do
      let(:liquid_context) { ::Liquid::Context.new('hello' => 'Hello') }

      specify { render("{{ hello }}", liquid_context).should == 'Hello' }
    end
  end
end
