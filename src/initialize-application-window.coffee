AtomEnvironment = require './atom-environment'
ApplicationDelegate = require './application-delegate'
Clipboard = require './clipboard'
TextEditor = require './text-editor'
TextEditorComponent = require './text-editor-component'
require('about')
require('archive-view')
require('autocomplete-atom-api')
require('autocomplete-css')
require('autocomplete-html')
require('autocomplete-plus')
require('autocomplete-snippets')
require('autoflow')
require('autosave')
require('background-tips')
require('bookmarks')
require('bracket-matcher')
require('command-palette')
require('deprecation-cop')
require('dev-live-reload')
require('encoding-selector')
require('exception-reporting')
require('find-and-replace')
require('fuzzy-finder')
require('git-diff')
require('go-to-line')
require('grammar-selector')
require('image-view')
require('incompatible-packages')
require('keybinding-resolver')
require('line-ending-selector')
require('link')
require('markdown-preview')
require('metrics')
require('notifications')
require('open-on-github')
require('package-generator')
require('settings-view')
require('snippets')
require('spell-check')
require('status-bar')
require('styleguide')
require('symbols-view')
require('tabs')
require('timecop')
require('tree-view')
require('update-package-dependencies')
require('welcome')
require('whitespace')
require('wrap-guide')
# require('language-c')
# require('language-clojure')
# require('language-coffee-script')
# require('language-csharp')
# require('language-css')
# require('language-gfm')
# require('language-git')
# require('language-go')
# require('language-html')
# require('language-hyperlink')
# require('language-java')
# require('language-javascript')
# require('language-json')
# require('language-less')
# require('language-make')
# require('language-mustache')
# require('language-objective-c')
# require('language-perl')
# require('language-php')
# require('language-property-list')
# require('language-python')
# require('language-ruby')
# require('language-ruby-on-rails')
# require('language-sass')
# require('language-shellscript')
# require('language-source')
# require('language-sql')
# require('language-text')
# require('language-todo')
# require('language-toml')
# require('language-xml')
# require('language-yaml')

# Like sands through the hourglass, so are the days of our lives.
module.exports = ->
  {updateProcessEnv} = require('./update-process-env')
  path = require 'path'
  require './window'
  {getWindowLoadSettings} = require './window-load-settings-helpers'
  {ipcRenderer} = require 'electron'
  {resourcePath, devMode, env} = getWindowLoadSettings()
  require './electron-shims'

  # Add application-specific exports to module search path.
  exportsPath = path.join(resourcePath, 'exports')
  require('module').globalPaths.push(exportsPath)
  process.env.NODE_PATH = exportsPath

  # Make React faster
  process.env.NODE_ENV ?= 'production' unless devMode

  clipboard = new Clipboard
  TextEditor.setClipboard(clipboard)

  window.atom = new AtomEnvironment({
    window, document, clipboard,
    applicationDelegate: new ApplicationDelegate,
    configDirPath: process.env.ATOM_HOME,
    enablePersistence: true,
    env: process.env
  })

  window.atom.startEditorWindow().then ->
    # Workaround for focus getting cleared upon window creation
    windowFocused = ->
      window.removeEventListener('focus', windowFocused)
      setTimeout (-> document.querySelector('atom-workspace').focus()), 0
    window.addEventListener('focus', windowFocused)
    ipcRenderer.on('environment', (event, env) ->
      updateProcessEnv(env)
    )
