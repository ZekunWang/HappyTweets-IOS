# Project 4 - *HappyTweets*

**HappyTweets** is a basic twitter app to read and compose tweets from the [Twitter API](https://apps.twitter.com/).

Time spent: **28** hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] Hamburger menu
   - [x] Dragging anywhere in the view should reveal the menu.
   - [x] The menu should include links to your profile, the home timeline, and the mentions view.
   - [x] The menu can look similar to the example or feel free to take liberty with the UI.
- [x] Profile page
   - [x] Contains the user header view
   - [x] Contains a section with the users basic stats: # tweets, # following, # followers
- [x] Home Timeline
   - [x] Tapping on a user image should bring up that user's profile page

The following **optional** features are implemented:

- [x] Profile Page
   - [ ] Implement the paging view for the user description.
   - [ ] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
   - [x] Pulling down the profile page should blur and resize the header image.
- [ ] Account switching
   - [ ] Long press on tab bar to bring up Account view with animation
   - [ ] Tap account to switch to
   - [ ] Include a plus button to Add an Account
   - [ ] Swipe to delete an account


The following **additional** features are implemented:

- [x] Customize navigation bar
- [x] Add fake UI elements to make the app more like the Twitter app
- [x] Customize launch page and add app icon
- [x] User can retweet, favorite, and reply directly on table cell
- [x] Add/remove compose hint with stack view to indicate reply or new tweet
- [x] Add/remove retweet hint with stack view to indicate retweeted or original tweet
- [x] Show time difference in table cell
- [x] Format retweet count and favorite count in table cell and tweet detail page
- [x] Use Realm to store data locally
- [x] Show image in tweet cells and detail page, need to make detail page scrollable
- [x] Implement scroll effects in profile page like Twitter app

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

  1. Pass data among view controllers and react to changes


## Video Walkthrough

Here's a walkthrough of implemented user stories:

![Video Walkthrough](HappyTweets_v1.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.
1. Pass data between view controllers and make update to the right view
2. Implement hamburger view and manipulate navigation bar 

## License

    Copyright [yyyy] [Zekun Wang]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
