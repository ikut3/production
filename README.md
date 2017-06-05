# How did I resolve WizeLine practice challenge 


## 1. Building beautiful architecture together

I was so excited since WizeLine(WL) team gave me many challenges to resolve their real issues which have similar, I did everyday on environment. I couldn't stop thinking about it after We have quick discussion
to hear their explanation about these exact things to do. More than their meaningful description which they provided I realized that We may be don't live in same Country, don't study in same University but it doesn't matter when We have same passion for technology. 
I want to take this chance to send my appreciation to Leon, HR team & Recuritment company whoever gave me this opportunity to have 3 rounds interview (Take around more than 3 hours for discussing, 4 hours for resolve pratices, 18 hours for this challenge only)

**Disclaim** : This is the story of a long journey

## 2. System Architecture 

### What was cloud being used ? 

After take few hours during my sleeping time to think about How to design this architecture to adapt with WizeLine's challenge. I decided to spin only 1 instance machine at Digital Ocean to build these stuffs 

- Why ? Digital Ocean (DO) ? 

In our theory about building scalability systems, We always hear their(our teachers) recommended that "The system should be built near the location of user which will be our customer". Luckily There are no users will be used this system (I assumed that) So I choose the location where easy to maintain & good quality service for my connection from VN. That was Singapore. And Digital Ocean has full enough things to adapt my requirement at that moment. 

I spinned up 1 machine at Digital Ocean with 2GB Ram & 40GB hardisk. Centos 7. My SSH publickey added under root account 

### What is our backend ? What do they do ? 

Unfortunately, WizeLine has gave me opportunity to develop NODEJS application as backend which I never have knowledge on this programing language. But my teacher google have, So I believe He can teach me within 18 hours challenge.

So Our backend is just simply main.js which was written by WL team. They also included most popular module is EXPRESS (a.k.a Web Application Framework)

I took around 30 minutes for spining DO machine, install Node & NPM. As Usual I used Nginx as reverse proxy to pass all traffic from HTTP default port (80) to my backend application which was listening on port (3000) but We missed ...

### DNS ? 

Actually, Because I think Leon & his team also want to see my achivement from his office at Mexico thus I don't want to ask him to use his /etc/hosts. I decided to assign 1 subdomain for all WL challenge is *http://ch.ilawyer.vn*. This domain was managed at Cloudns since I want to get rid NameCheap. 

### Make a Proper service of NODEJS

After 15 minutes waiting for DNS propagation. I can see "Hello World" content on my web browse and "All good" also appeared when I try /health. The small issue which was encountered  is Nodejs application runing over my terminal through 

```
# node main.js
```

But I want it should be started like normal service, It should be controlled by some of process control application.
I confident to talk about SystemV, SystemD day by day but the problem is If I use SystemD to make proper service I will completely blinded on these NODEJS error which I really need to debug at sometimes. 

```
# journalctl -u nodejs
```

This command won't help me much when I want to analysis the problem inside. So I decide to use NODEJS to manage itself.
That was `Forever`. The advantage of `Forever` is I can control a tons of nodejs process where I can grab any log information of each process, each services running. Otherwise `Forever` also has very good feature to use in future is *Watch-For-File-Change*, beside that It also has capability to force Nodejs process run continuosly

### Continuosly Build & Deploy Application  

That was main thing I think it must has priorities in this challenge. So my topology 

![alt_test](http://cdn.rancher.com/wp-content/uploads/2015/11/18175501/ci_flow.png)

Yes ! Docker will be used. I was using few images to spin few services in my machine such as : Jenkins(8080), Mongo(27017), Centos7 

I also created new repository on my own space at _https://github.com/ikut3/production/_

The jenkins started under localhost port 8080, once again Nginx was used as reverse proxy. For Jenkins plugin I also selected GitHub plugin to make Jenkins able to communicate with GitHub. 

Once the project is setup, I have to input few information about my github repository on jenkins configuration. Importatn thing is set trigger build **GitHub hook trigger for GITScm polling** 

Click the Add build step drop-down, and select Execute shell. This will make a Command dialogue available, and what we put in this dialogue will be run when a build initiates. I wrote a simple bash script and call it _deploy_

```
#!/bin/sh

ssh prod@ch.ilawyer.vn <<EOF
  cd ~/production
  git pull
  npm install
  forever restartall
  exit
EOF
```

So the workflow at this moment has bit complicated. I want everytime whenever We have a change on _master_ branch
It must be automatically trigged to Jenkins and force building. The build step actually is excuting _deploy_ script by accessing from Jenkins container over SSH with specified account then pulling all new data. Last step is restarting to apply these changes

After finish with all configuration from Jenkins, don't forget  to make sure that GitHub able to push event into _Jenkins-Webhook_ on our own link `http://ch.ilawyer.vn/github-webhooks`

Luckily My understanding has correct direction. I could demonstrated with few change requests. 

#### How about prevent Buggy code ####

Just friendly remind that I haven't much skill on programming, especially NODEJS. But AFAIK NODEJS has similar with other programming language which I had been. It meant that during coding time We can have a lot of bugs such as : wrong on parameter defination, syntax incorrect, input & output data different with what we expected and so on. 

So I tried to have basic understanding of app behavior.

- I tell my test to expect the response to be _This is a production_ and if it is, the test passes.

```
var request = require('supertest');
var app = require('../main.js');

describe('GET /', function() {
    it('respond with This is a production', function(done) {
          request(app).get('/').expect('This is a production', done);
            });
});
```

I found supertest, mocha by randomly during asking time with my teacher (Google). So Immediately I wrapped it with my bash-script to increase the complexity 

```
#!/bin/sh
ssh prod@ch.ilawyer.vn <<EOF
sudo docker exec 133e18e9d894 /bin/bash -c 'cd /opt/production; git checkout master; git pull; npm install; cd /opt/production; node_modules/mocha/bin/mocha /opt/production/test/test.js'
EOF
```

I want everytime when testing something, It shouldn't be related with my live environment. Thus I using centos7 container which I mentioned at above. If the test passed, the build will be continued on deployment. 

Once again We have to trigger on Jenkins 

![alt_test](https://cms-assets.tutsplus.com/uploads/users/383/posts/21511/image/15_jenkins_configure_add_deploy.jpg)

After near 20 times change script, test again and again. I can make sure that my workflow runs smoothly. 

- What was behind ? 

1. Yes ! 1 thing I have to adjust behind to adapt these changes to make it work with Supertest & Mocha.

One of them is when I run this test I get a complaint about the app object not having a method named address. So I have to 
call http.js project in scope. I have modified our main.js like  

```module.exports = app;``

2. How can we manage environment variables in Node.js ? 

In my understanding Environment variables help us define values which we do not want hard-coded in our source. They allow us to customize code behavior depending on the environment in which it is running.
Definitely, We cannot use same source to run for 2 environments Live & Staging. So I have to think about How to manage variables for 1 application in multiple environments

I choose `dotenv`. I refactor our code on main.js to able fetch data from `.env` file like 

```
var dotenv = require('dotenv');

var conf = {
  development: {
    servers: [[process.env.DATABASE_DEV_IP, process.env.DATABASE_DEV_PORT]],
    database: process.env.DATABASE_NAME,
    user: '',
    password: '',
    replicaSet: null,
  },
  production: {
    servers: [[process.env.DATABASE_IP, process.env.DATABASE_PORT]],
    database: process.env.DATABASE_NAME,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    replicaSet: null,
  }
};

app.listen(process.env.PORT, 'localhost', function () {
  console.log('Example app listening on port 3000!');
});
```


And my environment was also declared 

```
DATABASE_DEV_IP=127.0.0.1
DATABASE_DEV_PORT=27017
DATABASE_NAME=db_name
DATABASE_IP=127.0.0.1
DATABASE_PASSWORD=27018
PORT=3000
```

#The End
As indicated by your scroll bar being very tiny right now.I would like to tell you more about monitoring, securing which I implemented on this system. Hopefully I can explain by talking better than continue writing article