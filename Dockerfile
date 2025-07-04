FROM ruby:3.2.2

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs yarn

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Copy app
COPY . .

# Precompile assets in production
# RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000
