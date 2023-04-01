FROM phusion/passenger-full:1.0.0
WORKDIR /app
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
COPY . .
CMD ["passenger", "start"]
