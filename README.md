TasksByStoryByIteration App
=========================

## Overview

This app displays a grid of all the tasks of all the stories of a selected iteration.

It was written in CoffeeScript (see src/App.coffee), but you can edit the javascript (src/App.js) instead, if you want.

The app uses grunt as its build system, see the Gruntfile.js for a complete list of the commands available. Below is an overview of some of the more useful ones.

* grunt watch:coffee
	* Compiles any coffee files in the src directory to javascript, upon saving the file.
* grunt template:debug
	* Builds App-debug.html, a version of the app that you can run locally.
* grunt build
	* Builds the app into deploy/App.html which you can copy and paste into a Custom HTML App in Rally


I hope this app is useful!

## License

AppTemplate is released under the MIT license.  See the file [LICENSE](https://raw.github.com/RallyApps/AppTemplate/master/LICENSE) for the full text.
