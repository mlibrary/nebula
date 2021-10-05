FROM ruby:2.5
ARG UNAME=app
ARG UID=1000
ARG GID=1000
ARG APP_HOME=/app

RUN gem install 'bundler:~>2.1.4'
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -d $APP_HOME -u $UID -g $GID -o -s /bin/bash $UNAME
RUN mkdir -p /gems && chown $UID:$GID /gems

USER $UNAME
COPY --chown=$UID:$GID Gemfile* ${APP_HOME}/
ENV BUNDLE_GEMFILE ${APP_HOME}/Gemfile
ENV BUNDLE_PATH /gems
WORKDIR ${APP_HOME}

RUN bundle install

COPY --chown=$UID:$GID . ${APP_HOME}

CMD ["bundle exec rake spec"]
