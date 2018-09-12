# Griffin Documentation Site
Welcome to the Apache Griffin documentation!

## Prerequisites

Install [jekyll](https://jekyllrb.com/) gem

    $ gem install jekyll

Generate the site, and start a server locally:

    $ jekyll serve -w
  
The `-w` option tells jekyll to watch for changes to files and regenerate the site automatically when any content changes.

Point your browser to [http://localhost:4000](http://localhost:4000)

By default, jekyll will generate the site in a `_site` directory.

## Editing documentations
1. Create a markdown file and add following content in header

        ---
        layout: doc
        title:  "Griffin Overview" 
        permalink: /docs/some-new-doc.html
        ---
        
        More content here ..
    
## Publishing the Apache Website
In order to publish the website, you must have committer access to Griffin's apache repository.

To publish changes, run 

```
bash ./deploy.sh
```
