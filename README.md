# Puffer pages is lightweight rails 3 CMS

Interface of pages based on [puffer](https://github.com/puffer/puffer)

## Keyfeatures

* Full rails integration. Puffer pages is part of rails and you can different features related to pages in rails application directly
* Flexibility. Puffer designed to be as flexible as possible, so you can create your own functionality easily.
* Layouts. You can use rails layouts for pages and you can use pages as action layouts!

## Installation.

You can instal puffer as a gem:
<pre>gem install puffer_pages</pre>
Or in Gemfile:
<pre>gem "puffer_pages"</pre>
Next step is:
<pre>rails g puffer_pages:install</pre>
This will install puffer pages config file in your initializers, some css/js, controllers and migrations
<pre>rake db:migrate</pre>

To start working with admin interface, you need to have some routes like:
<pre>
namespace :admin do
  resources :pages
  resources :layouts
  resources :snippets
end
</pre>

## Introduction.

The first thing, you should do - setup routes if you want pages path different from /(*path).
Just put in your routes.rb:
<pre>puffer_page "pages/(*path)" => 'whatever#show'</pre>
Default pages route you can see with rake routes.

Puffer pages is radiant-like cms, so it has layouts, snippets and pages.
Puffer pages use liquid as template language.

## Pages.
Pages - tree-based structure of site.
Every page has one or more page parts.

## Layouts.
Layout is page canvas, so you can draw page parts on it.
In puffer pages you can use puffer pages layouts or applcation layouts.

### Puffer pages layouts
For puffer pages layouts page parts placeholder is liquid tag yield.
<pre>{% yield [page_part_name] %}</pre>

If no page_part_name specified, puffer layout will use page part with default name ('body'). You can change defaul page part name in puffer pages setup initializer.

Ex.
<pre>
  {% yield %} # renders body
  {% yield 'sidebar' %} # renders sidebar
  {% assign sb = 'sidebar' %}
  {% yield sb %} # renders sidebar too
</pre>

### Application layouts.
For application layout page part body will be inserted instead of SUDDENLY! <%= yield %>
Rules are the same. If no page part name specified puffer will use page part with default name.

So, main page part is action view and other are partials. So easy.

## Liquid.

The first tag was {% yield %}
Also, you can acces current page and root page from puffer pages templates.
Page named `self` in templates:
<pre>{{ self.name }}</pre>
And root page:
<pre>{{ root.name }}</pre>

Also you can do anything you can do with [liquid](http://github.com/tobi/liquid/)

`self` and `root` are both instances of page drop. View [this](https://github.com/puffer/puffer_pages/blob/master/lib/puffer_pages/liquid/page_drop.rb) to find list of possible page drop methods
