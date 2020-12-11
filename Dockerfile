FROM ruby:2.5
ARG UNAME=app
ARG UID=1000
ARG GID=1000
ARG APP_HOME=/app
ARG GEM_HOME=/gems

RUN groupadd -g $GID -o $UNAME
RUN useradd -m -d $APP_HOME -u $UID -g $GID -o -s /bin/bash $UNAME
RUN mkdir -p $GEM_HOME && chown $UID:$GID $GEM_HOME

USER $UNAME
RUN gem install 'bundler:~>1.17.3' 'bundler:~>2.0.2'
COPY --chown=$UID:$GID Gemfile* ${APP_HOME}/
ENV BUNDLE_GEMFILE=${APP_HOME}/Gemfile
ENV BUNDLE_PATH=${GEM_HOME}
WORKDIR ${APP_HOME}

RUN bundle install

COPY --chown=$UID:$GID . ${APP_HOME}

CMD ["bundle exec rake spec"]
