# Intro 

The working (very very very buggy) branch for TaskToggle, an in-progress SBSettings alternative.  TaskToggle intends to replace the older package entirely (e.g., you install it, then remove SBSettings) while providing full compatibility with existing toggles and partial compatibility with themes.  Designed with iPad and iPhone 4 in mind, including a Preference Loader-based system for editing the same options SBSettings.app currently allows.

Hopefully, showing it off to others will get me to commit more and more often.  We'll see how this goes.

Oh, and this is unfinished.

# Credits

Borrows liberally design-wise (being my first tweak; rather ambitious, eh?) from Ryan Petrich's brilliant LibActivator.  Neat stuff.

# License

This software is provided with no warranty, blah blah blah.  I'll nail down a license later.

# To-Do

* Finish implementing the various settings, toggle switches, etc.
* Re-implement "Poof"; AppList is wonky on 4.2 and often causes Preferences to crash for me.  Make a simple UITableViewDataSource using SpringBoard's data stores
* Toggle drawing (big mama)
* Toggle display methods for different devices
** iPad will just use multiple pages
** iPhone could maybe bring the switcher up higher to resemble an SBSettings switcher, multiple pages, or have a vertical scroll view?
* Internationalization
* A pretty icon
* Petition the maker of a good SBSettings theme to adapt theirs for use as the official TaskToggle one