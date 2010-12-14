Purpose:
--------

Presence is a Twitter client originally started as an assignment for CS193P. 
It has since moved away from strictly being based on those assignments to 
explore other aspects of iPhone Development.

Building/Running:
-----------------

Presence depends on the fmdb sqlite3 wrapper written by Gus Mueller and json-framework by Stig Brautaset.
To that end, I have forked the github repositories for those projects and included them as git submodules.
The steps to get up and running are:
     git clone git://github.com/adamvduke/Presence.git
     cd Presence
     git submodule init
     git submodule update

The submodules will be their own git repositories in the directories Presence/External/fmdb and Presence/External/JSON