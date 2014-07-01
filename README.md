zmp
===

Zomebie Multiplayer


# Scripting
* Use gstr for 144 sized global strings, gstr2 for 255 items. Do not define new strings with that size, use the global ones.

* Use __GetIP,__GetName,__GetSerial rather than server natives. Reset player vars etc in "ResetPlayerVars".


# Versioning

There are sub-versions which form the main version: Major,Minor,Patch. Draft a new release every minor or major version change.

It's self explaning, use patch for small changes, minor for new versions with features and fixes etc. Major versions should only be pushed when very big changes have been made and the old version branch runs out of numbers like 2.9.14

There can still be version numbers greater than 9 like 3.14.2 etc.
