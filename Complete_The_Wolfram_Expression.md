# Complete The Wolfram Expression

An interactive browser game where you can improve your skill with wolfram language, starting from a topic of your intrest the system will show you a Wolfram Expression with a missing part to complete, in a growing of difficulty and fun.

## Goal
The primary goal  of this project is adding question mark in a random point of one of the expressions of the documentation of Mathematica and present it to the user alongside it's output.
When user solve the problem the system give him a score related with his performance and present him another problem related with the first.

## Poject Steps

* Design a generator of problem
* Create a mock-up for the web application
* Create the web application with Wolfram Cloud's Api
* Design a sand-box that can run solutions proposed by users
* Design a graph of problem that user can explore from documentation
* Design different step of complessity in the game, multiple choice, lenght of the missing part, only position
* Design a system of Karma Point, Badge and progression in the game
* Improve layout and user experience


## Start the server

All the web server is self contained in _$CompleteExpressionApp_
you just have to import the Project` directory and running the server.

```
Unprotect[$TemplatePath];
$TemplatePath = Prepend[
   					$TemplatePath,
   					PacletManager`PacletResource["Project", "Assets"]
   					];
<< HTTPHandling`
<< Project`
StartWebServer[$CompleteExpressionApp]
```

## Screenshot

### home
![home](http://community.wolfram.com//c/portal/getImageAttachment?filename=home_new.png&userId=1123820)
### game section
![game](http://community.wolfram.com//c/portal/getImageAttachment?filename=difficile.png&userId=1123820)
