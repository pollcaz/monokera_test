# README

# Microservices with Docker Compose

This project uses **Docker Compose** to manage multiple microservices, databases, and messaging queues in an isolated and controlled manner. The system consists of the following main services:

- **customer_service**: Customer microservice running on port 3000.
- **worker**: Worker that processes messages from the RabbitMQ queue.
- **order_service**: Order microservice running on port 3001.
- **db**: PostgreSQL database shared between the microservices.
- **rabbitmq**: Messaging system based on RabbitMQ for communication between microservices.

## Project Structure

The basic structure of services is composed of the following components:

- **customer_service**: Microservice managing customer logic.
- **worker**: Worker that listens to and processes messages from the RabbitMQ queue.
- **order_service**: Microservice managing order logic.
- **db**: Container for a PostgreSQL database shared between services.
- **rabbitmq**: Messaging service for communication between microservices.

## Architecture Diagram

Below is a simplified diagram of how the services interact with each other:

```plaintext
+------------------+        +------------------+        +------------------+
|  customer_service|        |  worker          |        |  order_service   |
|  (Port 3000)     | <----> |  (RabbitMQ Queue)| <----> |  (Port 3001)     |
+------------------+        +------------------+        +------------------+
           |                        ^                            ^
           |                        |                            |
           |                        |                            |
           v                        v                            |
     +-----------+           +--------------+           +----------------+
     |    db     |           |  rabbitmq    |           |    db (order)  |
     +-----------+           +--------------+           +----------------+
           |                        |                            |
           |                        |                            |
           +------------------------+----------------------------+
                            |
                +------------------------+
                |    postgres_data        |
                +------------------------+
* Video with explanation how is working the project:[https://www.loom.com/share/dde6545c501e4518ad834fd4eda9c849?sid=8eda2416-9929-4172-9f3e-59563d803560]

* Ruby version
3.3.6
* Rails version
7.2.2.1

* System dependencies
** Docker
** Docker-compose
** RabbitMQ
** PostgreSQL

* Configuration
This project is set up to run all services in development mode with docker if you want to run the app in development mode in local without docker you need to keep im maind the next aspects:
*** change database.yml settings
*** change the initializer settings for Bunny for both microservices to be able to find your rabbitmq
*** change the initializer settings for Rabbitmq for both microservices to be able to find your rabbitmq server
*** Edit CustomerService and its specs where I'm using the url for the microservices to change them to localhost.
*** Edit the cors hosts and config/environments/development and production to be able to run the app in localhost without forbiden issues(error 403)

*** All above is possible but is easier running docker and docker-compose

* To run the project using docker and docker-compose
docker-compose build
docker-compose up

* When you need to do some changes in your code you need to run the command: ´´´docker-compose up --build``` to be able to reflect the changes in your service

* Database creation
The database when you run the docker-compose up --build creates the database and ensure the migration using the command db:prepare so you don't need to run anything related to create and migrate the database and models

* Database initialization
To initialize the database with some data you can run the command the first time you run the next command in docker compose like this: ´´´docker-compose exec customer_service bash -c "bundle exec rails db:setup"´´´

* How to run the test suite
you can run the specs using the command: ´´´docker-compose exec customer_service bash -c "RAILS_ENV=test bundle exec rspec"
docker-compose exec order_service bash -c "RAILS_ENV=test bundle exec rspec"´´´

* To do some debugger 
You can check the microservices logs running the command: 
´´´
docker logs -f monokera_test-customer_service-1
docker logs -f monokera_test-order_service-1
´´´
* To check something related with databases
´´´
docker exec -it monokera_test-db-1 psql -U postgres
´´´

* To check the RabbitMq manager
http://localhost:15672

* Opportunities to improve
** Add swagger for api documentation in both microservices
** Use ActiveModel::Serializer instead of ActiveModel::Attributes in the endpoints as it's more secure


* ...
