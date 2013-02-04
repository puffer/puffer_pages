require 'spec_helper'

describe 'Interpolation' do
  let!(:root) { Fabricate :root }

  context 'double quotes' do
    let!(:layout) { Fabricate :application, body: '{% assign var = "#{foo} interpolation" %}{{ var }}' }
    specify { root.render('foo' => 'bar').should == 'bar interpolation' }
  end

  context 'single quotes' do
    let!(:layout) { Fabricate :application, body: '{% assign var = \'#{foo} interpolation\' %}{{ var }}' }
    specify { root.render('foo' => 'bar').should == '#{foo} interpolation' }
  end

  context 'filters' do
    let!(:layout) { Fabricate :application, body: '{% assign var = "#{foo | capitalize} interpolation" %}{{ var }}' }
    specify { root.render('foo' => 'bar').should == 'Bar interpolation' }
  end

  context 'filters with parameters' do
    let!(:layout) { Fabricate :application, body: '{% assign var = "#{foo | minus: 1} interpolation" %}{{ var }}' }
    specify { root.render('foo' => 4).should == '3 interpolation' }
  end
end
