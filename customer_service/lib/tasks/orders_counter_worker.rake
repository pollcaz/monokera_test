namespace :orders_counter_worker do
    desc "Execute the worker to increment the customer orders_count field"
    task :start => :environment do
      # Inicia el worker (asegúrate de que este archivo esté bien cargado)
      worker = CustomerOrdersCountWorker.new
      worker.start
    end
end
