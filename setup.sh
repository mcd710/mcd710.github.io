#!/bin/bash
# One-time setup script for Jekyll development environment

set -e  # Exit on error (but we'll handle some errors gracefully)

echo "Setting up Jekyll development environment..."
echo ""

# Check for Homebrew Ruby first (often more compatible with macOS 15+)
HOMEBREW_RUBY_PATH=""
if [ -f "/opt/homebrew/opt/ruby/bin/ruby" ]; then
    HOMEBREW_RUBY_PATH="/opt/homebrew/opt/ruby/bin"
elif [ -f "/usr/local/opt/ruby/bin/ruby" ]; then
    HOMEBREW_RUBY_PATH="/usr/local/opt/ruby/bin"
fi

# Check if rbenv is available and set it up
if command -v rbenv &> /dev/null; then
    eval "$(rbenv init -)"
    echo "✓ rbenv found"
fi

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    echo "Error: Ruby is not installed."
    if command -v rbenv &> /dev/null; then
        echo "Installing Ruby 3.2.7 with rbenv..."
        rbenv install 3.2.7 || {
            echo "Error: Failed to install Ruby. You may need to install ruby-build:"
            echo "  brew install ruby-build"
            exit 1
        }
        rbenv local 3.2.7
    else
        echo "On macOS, install with: brew install ruby"
        exit 1
    fi
fi

# Use Homebrew Ruby if available and it meets requirements
if [ -n "$HOMEBREW_RUBY_PATH" ]; then
    # Get gem bin directory for this Ruby
    GEM_BIN_DIR=$("$HOMEBREW_RUBY_PATH/ruby" -e "puts Gem.bindir" 2>/dev/null || echo "")
    if [ -n "$GEM_BIN_DIR" ]; then
        export PATH="$GEM_BIN_DIR:$HOMEBREW_RUBY_PATH:$PATH"
    else
        export PATH="$HOMEBREW_RUBY_PATH:$PATH"
    fi
    HOMEBREW_RUBY_VERSION=$("$HOMEBREW_RUBY_PATH/ruby" -e "puts RUBY_VERSION" 2>/dev/null)
    if "$HOMEBREW_RUBY_PATH/ruby" -e "exit(Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.0.0') ? 0 : 1)" 2>/dev/null; then
        echo "✓ Using Homebrew Ruby $HOMEBREW_RUBY_VERSION"
        CURRENT_RUBY_VERSION=$HOMEBREW_RUBY_VERSION
    fi
fi

CURRENT_RUBY_VERSION=${CURRENT_RUBY_VERSION:-$(ruby -e "puts RUBY_VERSION" 2>/dev/null)}
REQUIRED_VERSION="3.0.0"

# Check if Ruby version meets requirements (>= 3.0.0)
if ! ruby -e "exit(Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('$REQUIRED_VERSION') ? 0 : 1)" 2>/dev/null; then
    echo "⚠️  Ruby version $CURRENT_RUBY_VERSION is too old. This project requires Ruby >= $REQUIRED_VERSION"
    
    if command -v rbenv &> /dev/null; then
        echo ""
        # Try newer Ruby versions first (better macOS 15 support)
        RUBY_VERSIONS_TO_TRY=("3.2.7" "3.2.6" "3.2.5" "3.3.0" "3.2.0")
        RUBY_INSTALLED=false
        
        for ruby_version in "${RUBY_VERSIONS_TO_TRY[@]}"; do
            if rbenv versions | grep -q "$ruby_version"; then
                echo "Found Ruby $ruby_version already installed, using it..."
                rbenv local "$ruby_version"
                RUBY_INSTALLED=true
                break
            fi
        done
        
        if [ "$RUBY_INSTALLED" = false ]; then
            # Check if ruby-build is installed
            if ! command -v ruby-build &> /dev/null && command -v brew &> /dev/null; then
                echo "Installing ruby-build..."
                brew install ruby-build
            fi
            
            # Try installing Ruby versions in order
            for ruby_version in "${RUBY_VERSIONS_TO_TRY[@]}"; do
                echo "Attempting to install Ruby $ruby_version..."
                if rbenv install "$ruby_version" 2>&1; then
                    rbenv local "$ruby_version"
                    echo "✓ Successfully installed and switched to Ruby $ruby_version"
                    RUBY_INSTALLED=true
                    break
                else
                    echo "Failed to install Ruby $ruby_version, trying next version..."
                fi
            done
            
            if [ "$RUBY_INSTALLED" = false ]; then
                # Try using Homebrew Ruby as fallback
                if [ -n "$HOMEBREW_RUBY_PATH" ]; then
                    export PATH="$HOMEBREW_RUBY_PATH:$PATH"
                    if ruby -e "exit(Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('$REQUIRED_VERSION') ? 0 : 1)" 2>/dev/null; then
                        echo "✓ Using Homebrew Ruby $(ruby -e "puts RUBY_VERSION") as fallback"
                        RUBY_INSTALLED=true
                    fi
                fi
                
                if [ "$RUBY_INSTALLED" = false ]; then
                    echo ""
                    echo "❌ Failed to install Ruby via rbenv. Alternative options:"
                    echo ""
                    echo "Option 1: Install Ruby via Homebrew (recommended for macOS 15):"
                    echo "  brew install ruby"
                    echo "  Then update your PATH in ~/.zshrc:"
                    if [ -d "/opt/homebrew" ]; then
                        echo "  export PATH=\"/opt/homebrew/opt/ruby/bin:\$PATH\""
                    else
                        echo "  export PATH=\"/usr/local/opt/ruby/bin:\$PATH\""
                    fi
                    echo ""
                    echo "Option 2: Check build errors in rbenv log:"
                    echo "  cat /var/folders/*/ruby-build.*.log | tail -50"
                    echo ""
                    echo "Option 3: Use Docker instead (see README.md for docker-compose instructions)"
                    exit 1
                fi
            fi
        fi
    else
        echo ""
        echo "Please upgrade Ruby. Options:"
        echo "  1. Install rbenv: brew install rbenv ruby-build"
        echo "  2. Or upgrade system Ruby (if using Homebrew): brew upgrade ruby"
        exit 1
    fi
else
    echo "✓ Ruby version OK: $(ruby --version)"
fi

# Update RubyGems to avoid compatibility warnings
echo "Updating RubyGems..."
gem update --system 3.2.3 2>/dev/null || {
    echo "Note: Could not update RubyGems automatically. You can update it manually with:"
    echo "  gem update --system 3.2.3"
}

# Check and install/reinstall bundler
BUNDLER_WORKING=false
if command -v bundle &> /dev/null; then
    if bundle --version &> /dev/null 2>&1; then
        echo "✓ Bundler found: $(bundle --version)"
        BUNDLER_WORKING=true
    else
        echo "Bundler appears to be corrupted, reinstalling..."
    fi
fi

if [ "$BUNDLER_WORKING" = false ]; then
    echo "Installing/reinstalling bundler..."
    gem uninstall bundler -x -I -a 2>/dev/null || true
    gem install bundler --user-install 2>/dev/null || gem install bundler
    # Verify bundler works
    if bundle --version &> /dev/null 2>&1; then
        echo "✓ Bundler installed: $(bundle --version)"
    else
        echo "⚠️  Bundler installation may have issues, but continuing..."
    fi
fi

# Configure bundler to install gems locally (if not already configured)
if [ ! -f ".bundle/config" ]; then
    echo "Configuring bundler to install gems locally..."
    bundle config set --local path 'vendor/bundle'
fi

# Install dependencies
echo ""
echo "Installing Jekyll and dependencies..."
bundle install

echo ""
echo "✓ Setup complete!"
echo ""
echo "You can now run the site with:"
echo "  ./start-server.sh"
echo ""
echo "Or manually with:"
echo "  bundle exec jekyll serve -l -H localhost"

