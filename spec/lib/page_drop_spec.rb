require 'spec_helper'

describe PufferPages::Liquid::PageDrop do

  def render_layout layout, current_page, page = nil
    current_page.render_layout(layout, {
      'self' => current_page.to_drop,
      'page' => (page.to_drop if page)
    })
  end

  context do
    let!(:root){Fabricate :page, :layout_name => 'foo_layout', :name => 'root'}
    let!(:foo){Fabricate :page, :slug => 'hello', :parent => root, :name => 'foo'}
    let!(:bar) do
      Fabricate :page, :slug => 'world', :parent => foo, :name => 'bar',
        :page_parts => [Fabricate(:page_part, :name => 'sidebar', :body => "{{ 'hello!' }}")]
    end

    before do
      root.reload
      foo.reload
      bar.reload
    end

    specify{render_layout('{{ self.parent.name }}', bar).should == 'foo'}
    specify{render_layout('{{ self.root.name }}', bar).should == 'root'}

    specify{render_layout('{{ page.current? }}', foo, foo).should == 'true'}
    specify{render_layout('{{ page.current? }}', foo, root).should == 'false'}
    specify{render_layout('{{ page.current? }}', foo, bar).should == 'false'}

    specify{render_layout('{{ page.ancestor? }}', foo, foo).should == 'false'}
    specify{render_layout('{{ page.ancestor? }}', foo, root).should == 'true'}
    specify{render_layout('{{ page.ancestor? }}', foo, bar).should == 'false'}

    specify{render_layout('{% if self == page %}equal{% else %}not equal{% endif %}', foo, foo).should == 'equal'}
    specify{render_layout('{% if self == page %}equal{% else %}not equal{% endif %}', foo, root).should == 'not equal'}
    specify{render_layout('{% if self == page %}equal{% else %}not equal{% endif %}', foo, bar).should == 'not equal'}

    specify{render_layout('{{ self.sidebar }}', bar).should == 'hello!'}

    context 'url helpers' do
      include RSpec::Rails::RequestExampleGroup

      let!(:foo_layout){Fabricate :layout, :name => 'foo_layout', :body => '{{ self.path }} {{ self.url }}'}

      specify do
        get "/#{bar.location}"
        response.body.should == '/hello/world http://www.example.com/hello/world'
      end
    end
  end

end
