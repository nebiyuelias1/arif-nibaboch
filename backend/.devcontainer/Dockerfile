# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.6
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# Install sqlite3 and fix CA certificates
RUN sudo apt-get update && \
    sudo apt-get install -y libsqlite3-dev sqlite3 ca-certificates && \
    sudo update-ca-certificates --fresh