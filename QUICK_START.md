# Quick Start Guide

## Want to enhance RST rendering in GitLab? Here's how to get started!

## Option 1: Browser Extension (Easiest - Works on GitLab.com)

### 1. Install the Extension

**For Chrome/Edge:**
1. Open `chrome://extensions/` or `edge://extensions/`
2. Enable **Developer mode** (toggle in top right)
3. Click **Load unpacked**
4. Select the `browser-extension/` folder in this repository
5. That's it! The extension is now active.

**For Firefox:**
1. Open `about:debugging`
2. Click **This Firefox** (left sidebar)
3. Click **Load Temporary Add-on**
4. Select any file in the `browser-extension/` folder
5. The extension will be active until you restart Firefox

### 2. Test It

1. Go to any `.rst` file in GitLab (e.g., `https://gitlab.com/username/project/-/blob/main/README.rst`)
2. The extension will automatically enhance the rendering:
   - Admonitions will have colored backgrounds and borders
   - Tables will have better styling
   - Code blocks will be more readable

### 3. Configure (Optional)

Click the extension icon in your browser toolbar to:
- Enable/disable the extension
- Toggle individual features (admonitions, tables, code blocks)
- Access settings

## Option 2: Ruby Gem (For Self-Managed GitLab)

### 1. Install the Gem

```bash
# Navigate to the gem directory
cd gem-solution

# Install dependencies
bundle install

# Build and install the gem
gem build gitlab-rst-enhanced.gemspec
gem install gitlab-rst-enhanced-1.0.0.gem
```

### 2. Install in GitLab

Add this to your GitLab's `Gemfile`:

```ruby
gem 'gitlab-rst-enhanced', '1.0.0'
```

Then run:

```bash
bundle install
```

### 3. Create an Initializer

Create a new file at `config/initializers/rst_enhanced.rb`:

```ruby
require 'gitlab/rst_enhanced'

# Patch gitlab-markup to use enhanced renderer
module GitHub
  class Markup
    class << self
      alias_method :original_render, :render
      
      def render(file, content)
        if file.to_s.end_with?('.rst')
          GitLab::RSTEnhanced.new.render(content)
        else
          original_render(file, content)
        end
      end
    end
  end
end
```

### 4. Restart GitLab

```bash
# For Omnibus installations
gitlab-ctl restart

# For source installations
sudo service gitlab restart
```

### 5. Test It

1. Create a `.rst` file in your project
2. View it in GitLab
3. Admonitions and tables should now be properly styled

## Option 3: Use Both for Best Results

For self-managed GitLab instances, you can use **both** solutions:

1. Install the Ruby gem for server-side rendering
2. Have users install the browser extension for client-side fallback

This ensures the best experience even if the server-side rendering has issues.

## Testing Your Setup

### Create a Test File

Create a file named `test.rst` in your project with this content:

```rst
Test RST File
=============

.. warning::

   This is a warning! It should have a yellow/orange background.

.. note::

   This is a note. It should have a blue background.

+-------+-------+
| A     | B     |
+=======+=======+
| 1     | 2     |
+-------+-------+

.. code:: python

   print("Hello, GitLab!")
```

### What to Expect

✅ **Admonitions**: Should have colored backgrounds and borders
✅ **Tables**: Should have borders and alternating row colors
✅ **Code blocks**: Should have proper syntax highlighting and background
✅ **Overall**: Should look much better than default GitLab RST rendering

## Troubleshooting

### Browser Extension

**Problem:** Extension not working
- **Solution:** Make sure you're on a GitLab page with RST content. Check the console for errors (F12 → Console)

**Problem:** Admonitions not styled
- **Solution:** The extension needs to detect the admonition structure. Try refreshing the page

**Problem:** Styles not applied
- **Solution:** Check that the extension is enabled in the popup

### Ruby Gem

**Problem:** Gem not found
- **Solution:** Make sure you've built and installed the gem: `gem install gitlab-rst-enhanced-1.0.0.gem`

**Problem:** GitLab not using the enhanced renderer
- **Solution:** Check that the initializer is in the right place and GitLab has been restarted

**Problem:** RST files not rendering
- **Solution:** Check GitLab logs for errors: `gitlab-ctl tail`

## Need Help?

- Check the [full documentation](docs/README.md)
- Review the [solution summary](SOLUTION_SUMMARY.md)
- Look at the [test sample](test-sample/README.rst) for examples

## Contributing

Found a bug or want to add a feature?

1. Fork this repository
2. Create a branch for your changes
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Enjoy enhanced RST rendering in GitLab!** 🎉
