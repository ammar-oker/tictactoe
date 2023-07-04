# Tic-Tac-Toe

## Overview
This project provides a full-stack solution to the classic game of Tic-Tac-Toe. The project has two main parts: the frontend, which provides a user interface for the game, and the backend, which manages the game's state.

## Tech Stack
- Backend: Ruby on Rails with SQLite3 as the database
- Frontend: Ember.js with custom SCSS styles
- Deployment: Docker, Docker Compose, and Nginx

## Setup Development Environment

### Prerequisites
- Ruby v3.2.2
- Node v18
- Yarn 1.22.*
- Docker

### Backend Setup
- Navigate to the backend directory: `cd backend`
- Install gems: `bundle install`
- Setup the database: `rails db:setup`

### Frontend Setup
- Navigate to the frontend directory: `cd ../frontend`
- Install dependencies: `yarn install`

### Run The Application
From the root of the project:
- Start the backend: `cd backend && rails s`
- Start the frontend: `cd frontend && yarn start`

### Building Docker Images

#### Backend
From the backend directory, build the Docker image:
```shell
docker build -t tictactoe/backend .
```

#### Frontend
From the frontend directory, build the Docker image:
```shell
docker build -t tictactoe/frontend .
```

## Deployment With Docker Compose and Docker Swarm
Ensure you're at the root of the project, and use the following command to start the project with Docker Compose:
```shell
SECRET_KEY_BASE=secret docker-compose up -d
```

For Docker Swarm, ensure Docker Swarm is initialized (docker swarm init). Then deploy the stack with:
```shell
SECRET_KEY_BASE=secret docker stack deploy -c docker-compose.yml tictactoe
```

## About Nginx For Production
The application uses Nginx as a reverse proxy to serve the frontend and route API requests to the backend.

The Nginx configuration is located at `frontend/nginx/nginx.conf`. The configuration is designed to serve the static files for the frontend Ember.js application and route any requests beginning with /api to the backend Rails API.

API requests are proxied to the backend Rails server. This is done using the location /api block in the Nginx configuration. This block matches any incoming request path that begins with /api and proxies the request to the Rails server.

## Testing
The backend includes unit tests for models and controllers. To run them:
```shell
cd backend
rails test
```

Please note that the frontend does not currently include tests.

Happy coding!
