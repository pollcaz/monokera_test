# syntax = docker/dockerfile:1

# Establecemos la versión de Ruby
ARG RUBY_VERSION=3.3.6

# Usamos una imagen base de Ruby
FROM ruby:$RUBY_VERSION-slim

# Establecemos el directorio de trabajo
WORKDIR /rails

# Instalamos paquetes base necesarios para Rails
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libjemalloc2 libvips postgresql-client \
    build-essential libpq-dev pkg-config libssl-dev libreadline-dev zlib1g-dev \
    netcat-traditional && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Instalamos Bundler
RUN gem install bundler

# Copiamos los archivos de Gemfile y Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Instalamos las gemas necesarias para la aplicación
RUN bundle install && \
    rm -rf ~/.bundle/ /usr/local/bundle/ruby/*/cache /usr/local/bundle/ruby/*/bundler/gems/*/.git

# Copiar el script wait_for_rabbitmq.sh al contenedor
COPY wait_for_rabbitmq.sh ./


# Hacer que el script sea ejecutable
RUN chmod +x ./wait_for_rabbitmq.sh    

# Copiamos todo el código de la aplicación
COPY . .

# Precompilamos los archivos de bootsnap para mejorar el tiempo de arranque
RUN bundle exec bootsnap precompile --gemfile

# Crear los directorios de datos necesarios para Rails
RUN mkdir -p /rails/db /rails/log /rails/storage /rails/tmp && \
    chown -R root:root /rails

# Exponer el puerto en el que Rails escuchará
EXPOSE 3000

# Definir el entrypoint (puedes personalizarlo según tu caso)
# ENTRYPOINT ["bash", "./wait_for_rabbitmq.sh"]

# Definir el comando por defecto para iniciar el servidor Rails
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
