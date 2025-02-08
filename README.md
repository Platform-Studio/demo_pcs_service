# demo_pcs_service
A demo PCS (Platform Copilot System) app showing how Service, Agent, Function, etc definitions can be defined in a separate repo.

tl;dr? Just check out `/definitions/wine.yml` and you'll get the idea.

The core objective of this demo is to show how a very small amount of low-code can be used to create a relatively sophisticated LLM-driven app that is immediately usable.

## Example: Wine Recommender
This example defines a simple app that recommends wines to the user based on a conversation with the user about their preferences.

It shows many of the core aspects of defining a PCS app:

- Service definition with custom CSS
- Agent definition with custom functions and tunings
- Function definitions implemented two different ways - inline Ruby and Ruby classes
- connection to a Twilio number for SMS/text (a fake number for this example)

It is already deployed and available to use through the web UX at:
https://os.platformstud.io/chat/service/wine


## YAML definitions
`/definitions/wine.yml`

In this example, the Service, Agent, and Functions are defined in YAML, the recommended format.

It is also possible to use JSON or Ruby to write definitions but YAML is preferred due to its brevity.

## Service deployment
### Initial setup
Currently, a PCS App must initially be set up by a Platform team member.

Setup in one-time, and then the process is entirely self-serve, through the PCS dashboard.

### App Definition
The PCS App definitions can specify a link to a Github repo.

If this URL is specified, PCS expects to find definitions and assets in that repo in the `/definitions/` and `/assets/` folders, respectively.

All other paths are ignored.

### Private Repos
For private repos, a credential must also be provided to grant PCS access.

At the time of writing, only Personal Access Tokens (PATs) are supported.

To generate a PAT, go to:
https://github.com/settings/tokens

Your PAT is encrypted at rest in the PCS database.

### Development vs Production Mode
Through the PCS dashboard, you are able to toggle an app between Development and Production mode.

In Development mode, the definitions will be pulled from the specified repo __every time a Service, Agent or Function is invoked__.

This introduces a slight delay but makes the development cycle easier since updates you push to your repo are reflected immediately.

In Production mode, the definitions are only pulled and updated when you explicitly initiate the process from the PCS dashboard.

(In a future version, we plan to support deployment hooks to make deployment of updates even easier.)

### Assets
Assets in the `/assets/` folder are copied from the repo and cached by PCS.

However, pulling of assets from the repo always requires a manual pull, regardless of whether the App is in Development vs Production mode.

## Functions

### Supported implementations
At the time of writing, functions can be implemented as any of the following:

- inline Ruby defined in the Function definition (suitable for simple functions)
- Ruby class (suitable for more complex functions)
- Cloud functions that are uploaded to Google Cloud on deployment and called via API (most flexible but introduces another potential point of failure)

### Ruby Class naming convention
PCS expects any Ruby Class definitions to be rooted in the `/definitions/` folder.

They must follow a specific naming convention or they will not be called at run-time.

The naming convention is `module_name.class_name.method_name`.

e.g. if your function is called wine.reds.drink, then the Ruby class implementation should be:
```ruby
module Wine
    class Reds
        def drink
            # Implement function here
        end
    end
end
```

### Function environment
When a Function is invoked, it has access to a number of objects and methods:

- `params` - a hash of the params passed to the Function by the LLM
- `chat` - the Chat the function was called from, allowing the Function to access messages, update UX, modify suggestions, etc
- `config` - a hash of the configuration for the Function specified in the Agent definition
- `store` - providing access to key/value storage for the current Service to allow data to be persisted between Chats

## Debugging
The default web UX provides a lot of additional debugging options.

Just add `debug=true` to the URL in the browser. You must be logged in with an account that has management rights.

The debug view provides a number of things:

- all system messages are shown (initial objectives, etc)
- raw responses from the LLM are viewable
- function calls and their responses are shown
- all defined functions are shown and each function is validated to see if it is in fact callable
- individual messages can be deleted
- the conversation can be re-run through the LLM on demand
- the whole conversation can be downloaded