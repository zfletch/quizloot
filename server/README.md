# Getting the Required Tokens

There are two tokens needed in order to use the Quizlet API:
Quizlet Client ID and User Access Token.
While you can access public sets with a Quizlet Client ID, in order
to access your private sets, you need a User Access Token.

## Quizlet Client ID

Getting a client ID is fairly easy.
You just need a Quizlet account and then you can sign up for a developer key.

- Visit [https://quizlet.com/api/2.0/docs](https://quizlet.com/api/2.0/docs)
- Click 'Sign up for an API 2.0 developer key'
- Fill out the fields.
- The information you enter isn't important. If you don't have a website, you can put 'example' in the 'URI our servers should redirect to' field for now.
- Click 'Generate Dev Key'
- Your `api_token` is listed under "Your Quizlet Client ID"

## User Access Token

Before getting a User Access Token, make sure you have a Quizlet Client ID.

Quizlet uses OAuth 2 which wasn't really designed for command line tools.
The basic idea is that a developer signs up to use the Quizlet API and is given an Access Token, a Secret Key,
and provides a Redirect URL.
The developer then generates a unique url using the Access Token, Secret Key, Redirect URL, and a random number.
When this unique url is visited by a Quizlet user, the user is asked if they want to allow the application or not.
If the user allows the application, they are sent to the Redirect URL provided by the developer with a payload
that includes a User Access Token.

Fortunately, you can run a local server and use your ip address as the Redirect URL.
I should mention that there is a small chance of a man in the middle attack since this method is just using http.

- If you are using a router, forward port 8000 to your local ip address port 8000
- Visit [https://quizlet.com/api-dashboard/](https://quizlet.com/api-dashboard/)
- Change the Redirect URL to `http://your.gobal.ip.address:8000` (note the `http://`)
- Using the other information on the page, run `ruby server/server.rb --id <Quizlet Client ID> --key <Your Secret Key> --url <Your Redirect URL>`
- This will start a local server and print out a url
- Copy the url and visit it in your browser
- Quizlet will ask you if you want to allow the application
- If you click 'allow' then you will be redirected to the server you're running locally. The body of the response should contain some JSON with an `access_token` field
- This access token is the User Access Token you need to access the user's private sets
- Shut down the server (^C)
- If you set up port forwarding earlier for port 8000, remove it.
