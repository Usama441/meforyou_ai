FROM ruby:3.3

# NodeJS & Yarn for Rails assets
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -qq && \
    apt-get install -y nodejs postgresql-client && \
    npm install -g yarn

# App directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy project files
COPY . .

# Default command
CMD ["bash", "-c", "bundle exec rails db:migrate && bundle exec puma -C config/puma.rb"]
