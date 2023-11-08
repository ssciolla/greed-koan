# Greed Koan

I wrote this program to complete the extra-credit portion of the
[Ruby Koans](https://www.rubykoans.com/), an implementation of a dice game called
[Greed](http://en.wikipedia.org/wiki/Greed_(dice_game)).
I am also using this opportunity to explore the set up and structure of Ruby programs, testing, and object-oriented programming.

## Installation

The only prerequisite is that you have Ruby 3 installed.

Run the following commands to install gems (just for testing at this point).
```sh
gem install bundler  # If you don't have it
bundle install
```

## Usage

Modify the names and number of players in `greed.rb`, and then run the entrypoint program.
```sh
ruby greed.rb
```

## Tests

To start the tests using Minitest, run the following command targeting all the lib files.
(This will be improved later.)
```
ruby -Ilib:test lib/game.rb lib/turn.rb lib/player.rb lib/dice_set.rb lib/score.rb
```
