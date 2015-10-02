# Pagina.io API

Pagina.io (pagina Dutch for "page") is a nice editor for [Jekyll](http://jekyllrb.com/) sites hosted on Github Pages. You can use it to edit your pages using a pleasant WYSIWYG interface.

Written using [Sinatra](http://www.sinatrarb.com/) and [Sequel](http://sequel.jeremyevans.net/).

This API is designed to work as a team with [pagina.io frontend](https://github.com/pagina.io/pagina.io).

## Setup

 * Run `bundle install`
 * Copy `.env-sample` to `.env` and put in your settings
 * Create an application on Github and put your `GITHUB_CLIENT_ID` and `GITHUB_SECRET` into the `.env` file
 * Run `bundle exec rake db:setup` to create the schema in your database
 * You're ready to go!

## Running

 * For the API, use `foreman start`
 * For the frontend, go to the frontend repo readme

By [@mtimofiiv](https://github.com/mtimofiiv) and [@harianus](https://github.com/harianus).
