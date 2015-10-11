# Quizloot

Quizlet Command Line API Tool.

[Quizlet](https://quizlet.com) is a website that allows users to
create and share flash cards. Users can have both private and public sets of cards.
Quizloot allows fetching public sets, and with some configuring, private sets
via the command line. It uses the Quizlet API and returns sets in JSON format.

### Basic usage

##### Fetching a public set:

The ID of a set can be found from the set's URL. For example, set [https://quizlet.com/97859413/test-public-set-flash-cards/](https://quizlet.com/97859413/test-public-set-flash-cards/)
has an ID of `97859413`. We can use this ID to fetch the set with Quizloot:

`./bin/qzie.rb pull --sets 97859413`

Output:

```json
[
  {
    "id": 97859413,
    "title": "Test public set",
    "terms": [
      {
        "id": 3089768183,
        "term": "foo",
        "definition": "bar",
        "image": null,
        "rank": 0
      },
      {
        "id": 3089769106,
        "term": "foo2",
        "definition": "bar2",
        "image": null,
        "rank": 1
      }
    ]
  }
]
```

##### Fetching multiple public sets:

`./bin/qzie.rb pull --sets 97859413,97859489`

##### Fetching a public set including metadata:

By default, Quizloot only prints the set `title`, `id`, and a list of `terms`. However, the Quizlet API returns
a lot more information such as `created_date`, `access_type`, `visibility`, etc. To see everything that the Quizlet
API returns, run your command with the `--with_meta` flag:

`./bin/qzie.rb pull --sets 97859413 --with_meta`


#### Custom client ID

Accessing the Quizlet API requires a client ID. Quizloot comes with a default client ID, but you can use
your own if you would like to (or if the default one stops working).
See the directions [here](https://github.com/zfletch/quizloot/tree/master/server#quizlet-client-id).
Then run commands with `--api_key <YOUR_QUIZLET_CLIENT_ID>`:

`./bin/qzie.rb pull --api_key PB8AujhFBa --sets 97859413`

#### Private sets

Getting access to private sets requires some configuration. First you need your own client ID (see the step above).
Then you need to obtain a user access token for the user to whom the private sets you want to access belong.
You can follow the directions [here](https://github.com/zfletch/quizloot/tree/master/server#user-access-token)
to get a user access token. Once you have a user access token you
can get access to a user's private sets:

`./bin/qzie.rb pull --sets 97859548 --key <USER_ACCESS_TOKEN>`

Or you can get a list of all the user's sets.

`./bin/qzie.rb pull --key <USER_ACCESS_TOKEN> --user <USERNAME>`

Note that the user access token gives access to all of the user's private sets.
Don't make user access tokens publicly available, try to treat them like passwords.

#### Configuring

Quizloot will look up default configuration in `~/.qzierc`. The default `user`, `key`, and `api_key` can be set
either manually or with the `conf` command:

`./bin/qzie.rb conf --user <USERNAME> --key <USER_ACCESS_TOKEN>`

If Quizloot has been configured like the above command, then `./bin/qzie.rb pull` without any arguments
will return the list of all sets for that user.
