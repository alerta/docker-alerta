FROM ruby:3.0

COPY Gemfile* ./
RUN gem install bundler && bundle install --jobs=3 --retry=3

RUN apt-get -q update && apt-get -qy install netcat
RUN wget https://raw.githubusercontent.com/eficode/wait-for/v2.2.0/wait-for && chmod +x wait-for

COPY .rspec .
CMD ["bundle", "exec", "rspec"]
