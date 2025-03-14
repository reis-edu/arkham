# Dockerfile

FROM ruby:3.4.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set the working directory
WORKDIR /arkham

# Copy the Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Command to run the Rails server
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bin/rails server -b '0.0.0.0'"]
