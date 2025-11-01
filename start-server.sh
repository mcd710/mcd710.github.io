#!/bin/bash
cd /Users/merieldoyle/CODE/mcd710.github.io

# Initialize rbenv if available
if command -v rbenv &> /dev/null; then
    eval "$(rbenv init -)"
fi

# Use Homebrew Ruby if available (often better for macOS 15+)
if [ -f "/opt/homebrew/opt/ruby/bin/ruby" ]; then
    HOMEBREW_RUBY_BIN="/opt/homebrew/opt/ruby/bin"
    GEM_BIN_DIR=$(/opt/homebrew/opt/ruby/bin/ruby -e "puts Gem.bindir" 2>/dev/null || echo "")
    if [ -n "$GEM_BIN_DIR" ]; then
        export PATH="$GEM_BIN_DIR:$HOMEBREW_RUBY_BIN:$PATH"
    else
        export PATH="$HOMEBREW_RUBY_BIN:$PATH"
    fi
elif [ -f "/usr/local/opt/ruby/bin/ruby" ]; then
    HOMEBREW_RUBY_BIN="/usr/local/opt/ruby/bin"
    GEM_BIN_DIR=$(/usr/local/opt/ruby/bin/ruby -e "puts Gem.bindir" 2>/dev/null || echo "")
    if [ -n "$GEM_BIN_DIR" ]; then
        export PATH="$GEM_BIN_DIR:$HOMEBREW_RUBY_BIN:$PATH"
    else
        export PATH="$HOMEBREW_RUBY_BIN:$PATH"
    fi
fi

# Check if bundle is installed
if ! command -v bundle &> /dev/null; then
    echo "Error: bundler is not installed."
    echo "Install it with: gem install bundler"
    exit 1
fi

# Check if dependencies are installed
if [ ! -d "vendor/bundle" ] || [ ! -f "vendor/bundle/.complete" ]; then
    echo "Installing dependencies with bundle install..."
    bundle install || {
        echo "Error: bundle install failed. Please check the error above."
        exit 1
    }
    touch vendor/bundle/.complete 2>/dev/null || true
fi

# Verify jekyll is available
if ! bundle exec jekyll -v &> /dev/null 2>&1; then
    echo "Error: Jekyll is not available. Running bundle install..."
    bundle install
    if ! bundle exec jekyll -v &> /dev/null 2>&1; then
        echo "Error: Failed to install Jekyll. Please check the errors above."
        exit 1
    fi
fi

echo "✓ Jekyll $(bundle exec jekyll -v 2>/dev/null | head -1) is ready"

echo "Starting Jekyll server..."
bundle exec jekyll serve -l -H localhost 