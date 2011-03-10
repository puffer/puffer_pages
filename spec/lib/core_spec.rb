require 'spec_helper'

describe 'Core' do

  describe 'arrange' do

    it 'should generate proper hash' do
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @bar = Fabricate :page, :slug => 'bar', :parent => @foo
      @baz = Fabricate :page, :slug => 'baz', :parent => @root

      @root.reload.self_and_descendants.all.arranged.should == @root.reload.self_and_descendants.arrange
    end

  end

end
