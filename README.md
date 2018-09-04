# Trello Slurper

Creates Trello cards in a given list, on a given board, from a supplied YAML file.

## Getting Required ENV Variables

* `TRELLO_BOARD_ID` You can get this from the URL of your board: `trello.com/b/SOME_ID/foo`.
* `TRELLO_LIST_ID` Add `.json` to the end of your board URL and look for the ID of the list you need.
* `TRELLO_DEVELOPER_PUBLIC_KEY` Run `ruby trello_slurper.rb configure` to open the URL where you can get this.
* `TRELLO_MEMBER_TOKEN` Run `ruby trello_slurper.rb token` after getting the public key to approve and get the token.

## Slurping Stories

Once you have all the variables you need, create a YAML file following
the template in `cards.sample.yml` and run the import:

```
ruby ./trello_slurper.rb your_file.yml
```
