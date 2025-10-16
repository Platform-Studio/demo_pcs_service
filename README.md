# demo_pcs_service
A demo PCS (Platform Copilot System) app showing how Service, Agent, Function, etc definitions can be defined in their own repo.

tl;dr? Just check out `/definitions/wine.yml` and you'll get the idea.

The core objective of this demo is to show how a very small amount of low-code can be used to create a relatively sophisticated LLM-driven app that is immediately usable "out-of-the-box" due to PCS's managed environment, responsive UX, etc.

## Example: Wine Recommender
This example defines a simple app that recommends wines to the user based on a conversation with the user about their preferences.
The agent creates a recommended tasting list that is displayed to the user.

It shows many of the core aspects of defining a PCS app:

- Service definition with custom CSS styling
- Agent definition with custom Functions and Tunings
- Function definitions implemented inline
- View definitions
- connection to a Twilio number for SMS/text (a fake number for this example)

It is already deployed and available to use through the web UX at:
https://os.platformstud.io/chat/service/wines_demo

You can also email with any PCS agent by using its agent name.
So, in this case, you can email `wine_selector@pcs.platformstud.io`

## YAML definitions
`/definitions/wine.yml`

In this example, the Service, Agent, Functions, and Views are defined in YAML, the recommended format.

(It is also possible to use JSON to write definitions but YAML is preferred due to its brevity.)

## Service deployment
### Initial setup
Currently, a PCS App must initially be registered by a Platform team member.

However, this setup is a one-time event, and then the process is entirely self-serve, through the PCS AI Dev dashboard.

The AI Dev dashboard is shown in the left-most column when logged into PlatformOS or reached directly at https://os.platformstud.io/chat/dash.

### App Definition
A PCS App definition specifies a URL for a Github repo.

At this URL, PCS expects to find definitions and assets in that repo in the `/definitions/` and `/assets/` folders, respectively.

All other paths are ignored.

### Private Repos
For private repos, a credential must also be provided to grant PCS access to read from the repo.

At the time of writing, only Personal Access Tokens (PATs) are supported.

To generate a PAT, go to:
https://github.com/settings/tokens

Your PAT is encrypted at rest in the PCS database.

### Development vs Production Mode
Through the PCS dashboard, you are able to toggle an app between Development and Production mode.

In Development mode, the definitions will be pulled from the specified repo __every time a Service, Agent or Function is invoked__.

This introduces a slight delay when using the app but makes the development cycle easier since updates you push to your repo are reflected immediately.

In Production mode, the definitions are only pulled and updated when you explicitly initiate a pull from the PCS dashboard.

(In future, we plan to support deployment hooks to make deployment of updates even easier.)

### Assets
Assets in the `/assets/` folder are copied from the repo and cached by PCS.

However, pulling of assets from the repo always requires an explicit pull, regardless of whether the App is in Development vs Production mode.

## Functions

### Supported implementations
At the time of writing, functions can be implemented as any of the following:

- JavaScript
- Cloud functions that are uploaded to Google Cloud on deployment and called via API (most flexible but introduces another potential point of failure)

### Function environment
When a Function is invoked, it has access to a number of objects and methods from the PCS environment:

- `params` - a hash of the params passed to the Function by the LLM
- `chat` - the Chat the function was called from, allowing the Function to access Messages, update the UX, modify suggestions, etc
- `config` - a hash of the configuration for the Function specified in the Agent definition

From the `chat` object, the `store` can be accessed (`chat.getStore()`). 
The `store` provides key/value storage for the current Service to allow data to be persisted (also referred to as "memories").

### External functions
A Function can optionally be set as "external". 

This means that, in addition to the LLM being able to call it through a tool call, it can also be called over HTTP/S.

External Functions allow the LLM and any forms-and-buttons views to share the same functionality and state.

### MCP Support
Agents defined in PCS can also call tools over the MCP protocol (see https://modelcontextprotocol.io/introduction).

You can mix-and-match MCP tool calls with your own function definitions.

To use MCP servers, you simply add them to the Agent definition using the standard MCP JSON definitions (the same that you may have used to add MCP servers to Cursor or the Claude desktop).

The wine.yml example file contains an example here, albeit commented out.

## Debugging
The default web UX provides a lot of additional debugging options.

Just add a `debug=true` parameter to the URL in the browser. (You must be logged in with an account that has management rights.)

The debug view provides a number of things:

- all system messages are shown (initial objectives, etc)
- raw responses from the LLM are viewable
- function calls and their responses are shown
- all defined functions are shown and each function is validated to see if it is in fact callable
- individual messages can be deleted
- the conversation can be re-run through the LLM on demand
- the whole conversation can be downloaded

