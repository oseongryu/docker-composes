docker run -it -d -p 4000:4000 -v /c/Users/osryu/git-personal/test:/usr/src/apptest/ --name centos-ruby ruby:2.6 bash
docker exec -it centos-jekyll bash

gem install bundler
gem install bundler:2.3.26
bundler _2.3.26_ install
bundle exec jekyll serve -H 0.0.0.0 -t