# A definition of a Service, Agent, and Functions in Ruby

ChatRegistry.register_service :wines_demo do
  display_name "Wine Demo"
  description "Helping you select the best wines"
  logo_url "/assets/logo.jpg"
  hero_image_url "/assets/hero.jpg"

  text_number "+14151118888"

  starter_agent_name :wine_selector

  custom_css <<~CSS
    .chat-other-message {
        background-color: darkred;
        color: black;
    }   
  CSS
end

ChatRegistry.register_agent :wine_selector do
  display_name "Tarquin"
  description "Helps you find great wines that will match your taste"
  objective <<~TEXT
    You are an expert sommelier with a broad and deep knowledge of wines from around the world.
    Your job is to make recommendations to the user of varietals, regions, vintages, and specific wines they might like.
    You should first ask for their name. When you have their name, record it by calling the wines.functions.set_name function.
    Your ultimate job is to create a personal tasting list for the user - a list of 10 wines you think they MUST try.
    Ask whatever questions you deem appropriate to build that list for the user.
    A good place to start is to ask them about the wines they already like and why they like them.
    When you have built the users personal tasting list, record it by calling the wines.functions.create_tasting_list function.
  TEXT

  initial_message <<~TEXT
    Hi, I'm Tarquin.
    I love to recommend wines.
    Is there a particular kind of wine that you already know you love?
  TEXT

  default_service :wines_demo

  function 'wines.functions.set_name'
  function 'wines.functions.create_tasting_list', {sommelier: "Tarquin"}
end

# An example of a Functino that is implemented with inline Ruby in the Function defintion
ChatRegistry.register_function 'wines.functions.set_name' do
    description "Record the user's name"
    parameters({
                 type: "object",
                 properties: {
                   user_name: {
                     type: "string",
                     description: "the user's name"
                   }
                 },
                 required: ["user_name"]
               })

    implementation_type "ruby"
    implementation <<~RUBY
      store.set(chat.uid, params[:user_name])
      {success: true}
    RUBY
  end

# An example of a Function that is implemented as a separate Ruby class method. This is the default so implementation_type is not specified.
ChatRegistry.register_function 'wines.functions.create_tasting_list' do
  description "Record the user's recommended tasting list"
  parameters({
               type: "object",
               properties: {
                 user_name: {
                   type: "string",
                   description: "the user's name"
                 }
               },
               required: ["user_name"]
             })
end

# An example of a Function that is implemented as a Cloud function.
ChatRegistry.register_function 'wines.functions.get_wine_types' do
  description "Return a list of the main wine types"
  parameters({})

  implementation_type "cloud_function"
  implementation <<~JAVASCRIPT
        return (['white', 'red', 'rose']);
  JAVASCRIPT
end

