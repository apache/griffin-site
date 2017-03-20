# Apache Griffin (incubating) website

This is the website for [Apache Griffin](	http://griffin.incubator.apache.org/) (incubating).

## About
This website is based on Hexo and a default Hexo theme.

## Prerequisite
1. Nodejs
2. Git


## Install & Run
1. npm install hexo-cli -g
2. git clone https://github.com/apache/incubator-griffin-site.git
3. cd incubator-griffin-site
4. npm install
5. hexo server


## Deploy to asf-site
1. Checkout branch master
2. Generate the site to content directory: `hexo generate`
3. Install plugin as `install hexo-deployer-git --save`
4. Push asf-site to remote branch by command `hexo deploy`, asf-site is hard-coded in _config.yml

## Questions

### Where to check configuration

Please refer to _config.yml for more details.

