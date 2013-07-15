require 'spec_helper'

describe PufferPages::Liquid::PageDrop do

  def render_layout layout, current_page, page = nil
    current_page.render(layout, other: page)
  end

  context do
    let(:hash) { { 'hello' => '{{ self.name }}' } }

    let!(:root) { Fabricate :root, name: 'root' }
    let!(:first) { Fabricate :page, slug: 'first', parent: root }
    let!(:second) { Fabricate :page, slug: 'second', parent: first, page_parts: [main, sidebar] }
    let!(:css) { Fabricate :page, slug: 'page.css', parent: first }
    let!(:main) { Fabricate(:main) }
    let!(:sidebar) { Fabricate(:sidebar, handler: 'yaml', body: YAML.dump(hash)) }

    before do
      root.reload
      first.reload
      second.reload
    end

    specify { render_layout('{{ self.parent.name }}', second).should == first.name }
    specify { render_layout('{{ self.root.name }}', second).should == 'root' }

    specify { render_layout('{{ other.current? }}', first, first).should == 'true' }
    specify { render_layout('{{ other.current? }}', first, root).should == 'false' }
    specify { render_layout('{{ other.current? }}', first, second).should == 'false' }

    specify { render_layout('{{ other.ancestor? }}', first, first).should == 'false' }
    specify { render_layout('{{ other.ancestor? }}', first, root).should == 'true' }
    specify { render_layout('{{ other.ancestor? }}', first, second).should == 'false' }

    specify { render_layout('{% if self == other %}equal{% else %}not equal{% endif %}', first, first).should == 'equal' }
    specify { render_layout('{% if self == other %}equal{% else %}not equal{% endif %}', first, root).should == 'not equal' }
    specify { render_layout('{% if self == other %}equal{% else %}not equal{% endif %}', first, second).should == 'not equal' }

    specify { render_layout('{{ self.body }}', second).should == main.body }
    specify { render_layout('{{ self.sidebar.hello }}', second).should == second.name }

    context do
      include RSpec::Rails::RequestExampleGroup

      context 'url helpers' do
        let!(:application) { Fabricate :application, :body => '{{ self.path }} {{ self.url }}' }

        specify do
          get "/#{second.location}"
          response.body.should == '/first/second http://www.example.com/first/second'
        end
      end

      context 'render tag' do
        let!(:application) { Fabricate :application, :body => "{% render 'shared/first' %}" }

        specify do
          get "/#{second.location}"
          response.body.should == 'shared/first content'
        end
      end

      context 'render tag with other format' do
        let!(:application) { Fabricate :application, :body => "{% render 'shared/first' %}" }

        specify do
          get "/#{css.location}"
          response.body.should == 'shared/first content'
        end
      end
    end
  end

end
