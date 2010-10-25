Purpose:
--------

Presence is a Twitter client originally started as an assignment for CS193P. 
It has since moved away from strictly being based on those assignments to 
explore other aspects of iPhone Development.

Building/Running:
-----------------

Presence depends on the fmdb sqlite3 wrapper written by Gus Mueller. To that end, I have
forked his fmdb repository [here](http://github.com/adamvduke/fmdb) and included it as a git
submodule. The steps to get up and running are:
     git clone git://github.com/adamvduke/Presence.git
     cd Presence
     git submodule init
     git submodule update

The submodule will be it's own git repository in the directory Presence/External/fmdb