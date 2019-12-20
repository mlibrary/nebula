FROM ruby:2.5-stretch

RUN gem install 'bundler:~>1.17.3' 'bundler:~>2.0.2'

COPY Gemfile* /usr/src/nebula/
WORKDIR /usr/src/nebula

ENV BUNDLE_PATH /gems
RUN bundle install

COPY . /usr/src/nebula/
CMD ["/bin/bash"]
