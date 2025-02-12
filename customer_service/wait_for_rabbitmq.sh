#!/bin/bash
# wait_for_rabbitmq.sh

# Espera hasta que RabbitMQ esté disponible en el puerto 5672
# until nc -z -v -w30 rabbitmq 5672; do
while ! nc -z rabbitmq 5672; do
  echo "Esperando a que RabbitMQ esté listo..."
  sleep 2
done

echo "RabbitMQ está disponible. Iniciando el worker..."
exec "$@"
