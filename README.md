App Remote
==========

Listens to button presses from an Apple Remote, and calls application-specific AppleScript subroutines.

Similar to the basic functionality of [Sofa Control](http://www.caseapps.com/sofacontrol/), without the bells and whistles, and the price tag.

Tested on OS X 10.8 Mountain Lion using a white Apple Remote.

Building
--------
Assuming you have [Xcode](https://developer.apple.com/xcode/) and [git](http://git-scm.com/) installed, run the following command in Terminal:

	git clone https://github.com/DennisTT/App-Remote.git
	cd App-Remote
	git submodule update --init

Open App-Remote.xcodeproj in Xcode, select the target "App Remote", and click Run.

Usage
-----
App Remote runs as a menu bar extra.  Currently the icon is "▶".

On the first launch, App Remote will prompt you to select a directory for the event handling scripts.  This is where you will put the AppleScript to handle remote button presses.  This folder can be changed by clicking on the app menu and "Choose Script Folder".

Scripts can be written in the AppleScript Editor, which is bundled with Mac OS X.  Scripts must be named "NameOfApp.scpt", for example, "Keynote.scpt".  The handlers are subroutines named in the following way:

 * *NameOfApp*Play
 * *NameOfApp*PlayHold
 * *NameOfApp*Up
 * *NameOfApp*UpHold
 * *NameOfApp*Down
 * *NameOfApp*DownHold
 * *NameOfApp*Left
 * *NameOfApp*LeftHold
 * *NameOfApp*Right
 * *NameOfApp*RightHold

An example for the Keynote script would be:

	on KeynoteUp
		*... do something in AppleScript*
	end KeynoteUp

Take a look at Default.scpt (the fallback script) in the Resources folder for an example script file.