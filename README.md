# rsense-reloaded
Rsense is a ruby project designed to provide auto-completion facilities, for the ruby language. It is a server that receives and emits POST requests filled with JSON data. You have to provide a JSON object consisting of some specific pieces of information like the content of your ruby file inside which autocompletion is to be made, the position where you want to autocomplete...
I wrote some lisp functions that make emacs able to communicate with this server, using the auto-completion framework Company (I created a simple backend that fetch results directly from this Rsense server).

Many things remain undone :
- managing the status of the rsense server automatically
- locating the root of a project ( with a .rsense file)
- mixing up completions, adding a fuzzy matching option
- enrich the backend to provide moe information about functions, completion choices
...
