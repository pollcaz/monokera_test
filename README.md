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
```

## Video with explanation how is working the project
[video in Spanish using loom](https://www.loom.com/share/dde6545c501e4518ad834fd4eda9c849?sid=8eda2416-9929-4172-9f3e-59563d803560)

 ## Microservices Architecture
```plaintext
+-------------------------+                           +-------------------------+
|    customer_service     |                          |     order_service       |
+-------------------------+                           +-------------------------+
|  app/                   |                          |  app/                   |
|   - controllers/        |                          |   - controllers/        |
|     - customers_controller.rb |                    |     - orders_controller.rb |
|   - models/             |                          |   - events/             |
|     - customer.rb       |                          |     - order_event_publisher.rb |
|   - workers/            |                          |   - models/             |
|     - customer_orders_count_worker.rb |            |     - order.rb          |
|  config/                |                          |   - services/           |
|   - initializers/       |                          |     - customer_service.rb |
|     - rabbitmq.rb       |                          |     - order_creator_service.rb |
|   - database.yml        |                          |  config/                |
|   - routes.rb           |                          |    - initializers/      |
|   - environments/       |                          |      - rabbitmq.rb      |
|       - development.rb  |                          |    - database.yml       |
|       - production.rb   |                          |    - routes.rb          |
|   db/                   |                          |    - environments/      |
    - schema.rb           |                          |      - development.rb   |
    - structure.sql       |                          |      - production.rb    |
    - seeds.rb            |                          |  db/                    |
|  lib/                   |                          |    - schema.rb          |
|   - tasks/              |                          |                         |
|     - customer_orders_count_worker.rake |          |                         |
|  spec/                  |                          |  spec/                  |
|   - factories/          |                          |   - events/             |
|     - customers.rb      |                          |     - order_event_publisher_spec.rb |
|   - models/             |                          |   - factories/          |
|     - customer_spec.rb  |                          |     - orders.rb         |
|   - requests/           |                          |   - models/             |
|     - customer_spec.rb  |                          |     - order_spec.rb     |
|   - workers/            |                          |   - requests/           |
|     - customer_orders_count_worker_spec.rb |       |     - order_spec.rb     |
|  Dockerfile             |                          |   - services/           |
|  wait_for_rabbitmq.sh   |                          |     - customer_service_spec.rb |
+-------------------------+                          |     - order_creator_service_spec.rb |
                                                     |  Dockerfile             |
                                                     |  wait_for_rabbitmq.sh   |
                                                     +------------------------+

```

## Project Flow Diagram
```plaintext
+-----------------------+           +--------------------------+           +------------------------+
|   order_service       |           |       RabbitMQ           |           |    customer_service    |
+-----------------------+           +--------------------------+           +------------------------+
|                       |           |                          |           |                        |
|  1. Create Order      |           |                          |           |                        |
|   (Order Controller)  |           |                          |           |                        |
|       |               |           |                          |           |                        |
|       v               |           |                          |           |                        |
|  2. Call Customer     |           |                          |           |                        |
|     Service via Faraday  |         |                          |           |                        |
|     (Request to get customer details) |                 |                          |                        |
|       |               |           |                          |           |                        |
|       v               |           |                          |           |                        |
|  3. Receive Customer  |           |                          |           |                        |
|     Details           |           |                          |           |                        |
|     (customer_details) |           |                          |           |                        |
|       |               |           |                          |           |                        |
|       v               |           |                          |           |                        |
|  4. Save Customer Info|           |                          |           |                        |
|     (Save customer_details in Order) |                  |                          |                        |
|       |               |           |                          |           |                        |
|       v               |           |                          |           |                        |
|  5. AfterCreate Hook  |           |                          |           |                        |
|     (order.rb)        |           |                          |           |                        |
|       |               |           |                          |           |                        |
|       v               |           |                          |           |                        |
|  6. Publish Event     |           |        order_created      |           |                        |
|     (OrderEventPublisher.rb) |----> |      (message)           |           |                        |
|       |               |           |                          |           |                        |
|       v               |           |                          |           |                        |
|  7. Send to Queue     |           |                          |           |                        |
|     (RabbitMQ: order_created)     |                          |           |                        |
|                       |           |                          |           |                        |
+-----------------------+           +--------------------------+           +------------------------+
                                           |                             ^
                                           |                             |
                                           |                             |
                                           v                             |
+-----------------------+           +--------------------------+           |
|   customer_service    |           |   customer_orders_count_worker.rb |---+
+-----------------------+           +--------------------------+           |
|                       |           |                          |           |
|  8. Listen to Queue   | <-------- |   Listen to order_created queue |           |
|     (Worker listens   |           |   and process incoming     |           |
|     to RabbitMQ)      |           |   messages (event)         |           |
|       |               |           |                          |           |
|       v               |           |                          |           |
|  9. Process Event     |           |                          |           |
|   (Update orders_count)           |                          |           |
|       |               |           |                          |           |
|       v               |           |                          |           |
|  10. Update Customer |           |                          |           |
|     (Increment orders_count)     |                          |           |
|                       |           |                          |           |
+-----------------------+           +--------------------------+           |
                                          |                            |
                                          |                            |
                                          +----------------------------+

```
## To check the Diagram Workflow
- Execute a curl request to create a new order for a customer from a bash terminal to the order create endpoint
```bash
curl -X POST http://localhost:3001/orders -d '{ "customer_id": 1,"product_name": "Tamales", "quantity": 7, "price": 70000, "status": "completed" }' -H "Content-Type: application/json"
```
- Check the RabbitMQ queue
```bash
docker logs -f monokera_test-order_service-1
```
- Check orders for the customer doing a http request to the order index endpoint from your browser
```bash
  http://localhost:3001/orders?customer_id=1
```
- check the customer has been updated in your orders count field doing a http request to the customer show endpoint from your browser
```bash
  http://localhost:3000/customers/1
```

## Ruby version
3.3.6
## Rails version
7.2.2.1

## System dependencies
- Docker
- Docker-compose
- RabbitMQ
- PostgreSQL

## Configuration
This project is set up to run all services in development mode with docker if you want to run the app in development mode in local without docker you need to keep im maind the next aspects:
- change database.yml settings
- change the initializer settings for Bunny for both microservices to be able to find your rabbitmq
- change the initializer settings for Rabbitmq for both microservices to be able to find your rabbitmq server
- Edit CustomerService and its specs where I'm using the url for the microservices to change them to localhost.
- Edit the cors hosts and config/environments/development and production to be able to run the app in localhost without forbiden issues(error 403)

- All above is possible but is easier running docker and docker-compose

## To run the project using docker and docker-compose
```bash
docker-compose build
docker-compose up
```

## When you need to do some changes in your code
 You need to stop the containers and run the next command to be able to reflect the changes in your service: 
 ```bash
 docker-compose up --build
 ```

## Database creation
The database when you run the docker-compose up --build creates the database and ensure the migration using the command db:prepare so you don't need to run anything related to create and migrate the database and models

## Database initialization
To initialize the database with some data you can run the command the first time you run the next command in docker compose like this:
```bash
docker-compose exec customer_service bash -c "bundle exec rails db:setup"
```

## How to run the test suite
you can run the specs using the command:
```bash
docker-compose exec customer_service bash -c "RAILS_ENV=test bundle exec rspec"
docker-compose exec order_service bash -c "RAILS_ENV=test bundle exec rspec"
```

## To do some debugger 
You can check the microservices logs running the command: 
```bash
docker logs -f monokera_test-customer_service-1
docker logs -f monokera_test-order_service-1
```

## To check something related with databases
```bash
docker exec -it monokera_test-db-1 psql -U postgres
```

## To check the RabbitMq manager
http://localhost:15672

## Opportunities to improve
- Add swagger for api documentation in both microservices
- Use ActiveModel::Serializer instead of ActiveModel::Attributes in the endpoints as it's more secure

* ...
