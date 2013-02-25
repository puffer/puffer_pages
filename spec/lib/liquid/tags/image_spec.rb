require 'spec_helper'

describe PufferPages::Liquid::Tags::Image do
  describe 'snippet' do
    let!(:root) { Fabricate :root }

    specify { root.render("{% image 'i.png' %}").should == "<%= image_tag 'i.png', {} %>" }
    specify { root.render("{% image 'i.png', alt:'txt' %}").should == "<%= image_tag 'i.png', {\"alt\"=>\"txt\"} %>" }
    specify { root.render("{% image 'i.png', alt:var %}", var: 'txt').should == "<%= image_tag 'i.png', {\"alt\"=>\"txt\"} %>" }
  end
end
