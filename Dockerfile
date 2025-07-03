FROM ruby:3.2

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  curl \
  git

# Set working directory
WORKDIR /app

# Install bundler and copy gem files
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Copy rest of the app
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Expose port 8080 for Fly.io
EXPOSE 8080

# Set entrypoint
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
