# YourCandidates.org.uk 
A voter advice app for UK general election 2015.

YourCandidates.org.uk was a voter advice app that pulled together various sources of information about candidates in the UK general election 2015. It showed:

* List of all candidates running in your local constituency
* Candidate's Web presence and contact information
* Party policy
* 2010 results and current predictions based on polls
* Twitter feeds

Data sources included [YourNextMP.com](http://yournextmp.com) and [ElectionForecast.co.uk](http://electionforecast.co.uk).

# Installation

N.b. since the YourNextMP API for the general election is no longer available, the service won't currently run.

Assuming recent Ruby with bundler gem installed:

```
bundle install
bundle exec rake db:migrate
rails s
```

# Screenshots

![frontpage](https://raw.githubusercontent.com/AleksiKnuutila/yourcandidates/master/screenshots/frontpage.png "Frontpage")

![candidates](https://raw.githubusercontent.com/AleksiKnuutila/yourcandidates/master/screenshots/candidates.png "Frontpage")
