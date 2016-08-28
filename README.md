
An alternative UI for Wallabag

Freerange Walrus
================

Wallabag is a **self hostable application for saving web pages**.
This means it is a really nice, free/open source solution
for keeping all your bookmarks in one place on your server.

Wallabag has lots of nice features,
but it misses the mark on some of the
(for me)
most important ones.

This is the reason why this project (codename Freerange Walrus) was born.
The focus of the project is to provide a complete single-user bookmarking system.

- Provide a tag-based bookmark listing (something that is still missing in Wallabag 2.x)
- Provide different layouts when listing the bookmarks (the default Wallabag UI provides only the card layout)

Release
-------

The code is under development. I'll post the packages and the installation instructions when we reach the first stable version.

Implementation
--------------

Freerange Walrus is implemented in the ELM programming language, with a few server-side PHP scripts. 
It uses the great Semantic UI framework for the visuals.

Building
--------

If you want to build it, just clone it and type `make`. (you'll need ELM installed)
