# Puppet Hack Data

This is a little app to collect pull request data. It was created to be used for #puppethack, so all the default
settings (e.g. dates, repos) reflect that fact. This is a ruby CLI app which will produce a CSV full of data for
the request pull requests.

## Installation

To install this app, simply clone the repository. Then run a bundle install to get the gems you need:

```
  cd /path/to/puppethack_data
  bundle install
```

## Usage

To run puppet hack data use the following command:

```
  bundle exec ruby puppet_hack_data.rb
```

puppet hack data comes with several flags which allow the user to define specifics around the data the app will
collect. Only one flag is required, the rest are optional. The required flag is `--github_token`. This is because an OATH
is required to get data from GitHub. You will need to generate a token if you don't already have one. Instructions for
how to do that can be found [here](https://help.github.com/articles/creating-an-access-token-for-command-line-use).

There are a few other optional flags you can use. These all have default values which will generate the data we would
like for puppet hack. The options are:

`--start_date`: This option allows you to specify the beginning of the range you would like to find pull requests in.
It expects a : separated format like so: YYYY:MM:DD:HH:MM (year, month, day, hour, minute)

`--end_date`: This option allows you to specify the end of the range you would like to find pull requests in. It expects
a : sperarated like so: YYYY:MM:DD:HH::MM (year, month, day, hour, minute)

`--open_only`: By default, puppet hack data will collect both open and closed pull requests. If you use this flag it
will only collect open ones.

`--repo_owner`: If you want to specify a list of repos other than the default, you will need to provide the owner for
the repositories (e.g. all of our repos are owned by 'puppetlabs'). If you specify a owner you must also pass in a list
of repos as an argument.

One you list all your options you can also pass in a white space seperated list of respository names if you don't want
to use the default list.

## Examples

Using all default values:
```
  bundle exec ruby puppet_hack_data.rb --github_token 12345
```

Defining your own repositories:
```
  bundle exec ruby puppet_hack_data.rb --repo_owner puppetlabs --github_token 12345 puppet facter hiera
```

Setting your own dates:
```
  bundle exec ruby puppet_hack_data.rb --start_date 2015:06:20:00:00 --end_date 2015:07:20:02:30 --github_token 12345
```
