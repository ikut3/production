# Wize Services Dev Ops Challenge
Welcome to the Wize Services Dev Ops challenge. This is the working repository, so feel free to clone, fork, upload in your account anything you see in here (including this README).

We want to deploy this simple Node.js application to a production server. We need the following features in order to ensure quality, easy access, development, security and scalability.

- Deploy to a new instance within the cloud (use your preferred provider)
- Deploy using a simple git push or a merge to master
- Deploy without downtime
- Avoid buggy code to be deployed to production
- Secure database with two environments (dev and prod)
- Automate tasks inside the server
- Monitor the health of the application and its components
- Track access metrics (to the application and the server)
- Test and show how these features were integrated
- You must be able to display information from the database ina  page

### Overview
- Uses Node.js application is using the port `3000`.
- Uses Express as router
- Has two endpoints available endpoints
  - `GET /`: Should return `Hello world!`
  - `GET /health`: Should return `All good`
  - `GET /database`: Must return data from the DB
- Uses command `npm start` to start the application
- Uses command `npm test` to test the application

#### Env Vars
- DB IP: `DATABASE_IP`
- DB Port: `DATABASE_PORT`
- DB Name: `DATABASE_NAME`
- DB User: `DATABASE_USER`
- DB Password: `DATABASE_PASSWORD`
- Environment: `ENVIRONMENT`
