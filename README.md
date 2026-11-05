# GitLab RST Extension

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitLab](https://img.shields.io/badge/GitLab-Compatible-green.svg)](https://gitlab.com)

**Enhanced reStructuredText (RST) rendering for GitLab**

## 🚀 Overview

This project provides **complete solutions** to enable **full reStructuredText rendering** in GitLab, addressing the limitations of GitLab's current RST support.

GitLab already has **basic RST support** (via the `gitlab-markup` gem), but it lacks proper styling for many RST features like admonitions, tables, and more. This project provides **two complementary solutions** to fix that.

## 📋 Solutions

### 1. Browser Extension (Client-Side)
**Works on GitLab.com and self-managed instances without any server access!**

- ✅ Enhances RST rendering client-side
- ✅ Works on any GitLab instance
- ✅ No installation required on the server
- ✅ Configurable via popup UI

### 2. Ruby Gem (Server-Side)
**For self-managed GitLab instances**

- ✅ Enhanced RST to HTML conversion
- ✅ Drop-in replacement for gitlab-markup's RST support
- ✅ Proper admonition and table support
- ✅ Custom CSS for RST elements

## 🌟 Features

### Enhanced RST Elements
- **Admonitions**: `.. warning::`, `.. note::`, `.. tip::`, `.. important::`, `.. caution::`, etc.
- **Tables**: Simple tables, grid tables, CSV tables
- **Code Blocks**: With syntax highlighting support
- **Sidebars**: Floating content boxes
- **Rubrics**: Special headings
- **Topics**: Content containers
- **Field Lists**: Metadata formatting
- **Option Lists**: Command-line option formatting
- **And more!**

### What Was Previously Missing in GitLab
1. **Admonitions** - Rendered as plain paragraphs without styling
2. **Proper table styling** - Missing borders, headers, alternating rows
3. **Code block enhancement** - Limited styling
4. **CSS classes** - Missing RST-specific classes for custom styling

## 📖 Documentation

- [Quick Start Guide](QUICK_START.md) - Get started in 5 minutes
- [Solution Summary](SOLUTION_SUMMARY.md) - Complete technical overview
- [Browser Extension Docs](docs/README.md#browser-extension) - Detailed extension documentation
- [Ruby Gem Docs](gem-solution/README.md) - Gem documentation

## 💻 Installation

### Browser Extension
```bash
# For development/testing
# 1. Open chrome://extensions/ or edge://extensions/
# 2. Enable Developer mode
# 3. Click "Load unpacked"
# 4. Select the browser-extension/ folder
```

### Ruby Gem
```bash
cd gem-solution
gem build gitlab-rst-enhanced.gemspec
gem install gitlab-rst-enhanced-1.0.0.gem
```

## 🧪 Testing

### Test with Sample File
We've included a comprehensive test file at [`test-sample/README.rst`](test-sample/README.rst) that demonstrates all the RST features that are now properly rendered.

### Run Gem Tests
```bash
cd gem-solution
bundle install
rake spec
```

## 📁 Project Structure

```
gitlab-rst-extension/
├── browser-extension/          # Chrome/Edge/Firefox extension
│   ├── manifest.json           # Extension manifest
│   ├── content.js              # Content script
│   ├── styles.css              # CSS styles
│   ├── popup.html              # Popup UI
│   ├── popup.js                # Popup logic
│   ├── popup.css               # Popup styles
│   ├── options.html            # Options page
│   ├── options.js              # Options logic
│   └── icons/                  # Extension icons
│
├── gem-solution/              # Ruby gem for server-side
│   ├── lib/                    # Ruby library
│   │   └── gitlab/             # Main module
│   │       ├── rst_enhanced.rb # Main renderer
│   │       └── rst_enhanced/   # Version file
│   ├── bin/                    # Executables
│   │   └── rst2html-enhanced   # Enhanced Python renderer
│   ├── spec/                   # Tests
│   ├── gitlab-rst-enhanced.gemspec  # Gem specification
│   └── README.md              # Gem documentation
│
├── test-sample/               # Test files
│   └── README.rst              # Comprehensive RST test file
│
├── docs/                      # Documentation
│   └── README.md               # Main documentation
│
├── QUICK_START.md              # Quick start guide
├── SOLUTION_SUMMARY.md         # Technical summary
└── README.md                   # This file
```

## 📸 Screenshots

### Before (GitLab Default)
![Before](https://img.shields.io/badge/Before-Plain_HTML-gray) *(Admonitions appear as plain paragraphs)*

### After (Enhanced)
![After](https://img.shields.io/badge/After-Styled_Admonitions-brightgreen) *(Admonitions have proper styling with colors and borders)*

## 🔒 Security

Both solutions maintain GitLab's security model:
- ✅ Raw HTML remains disabled
- ✅ File inclusions remain disabled
- ✅ No external API calls
- ✅ Respects GitLab's sanitization pipeline

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) (coming soon).

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- GitLab team for their work on gitlab-markup
- Docutils team for the RST parser
- All contributors to the reStructuredText specification

## 📧 Support

- [Documentation](docs/README.md)
- [Issues](https://github.com/example/gitlab-rst-extension/issues) *(create your own repo for issues)*
- [Discussions](https://github.com/example/gitlab-rst-extension/discussions) *(create your own repo for discussions)*

## 🚀 Getting Started

Ready to enhance RST rendering in GitLab?

👉 **[Read the Quick Start Guide](QUICK_START.md)**

---

**Built with ❤️ by Mistral AI**

*Enhance your GitLab RST experience today!*
