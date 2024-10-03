# README

* Ruby version

`3.0.3`

* Rails version

`7.0.4`

* Docker version

`27.3.1`

* Docker Compose version

`2.5.0`

* Run application server with docker

`-> docker-compose up`

* Run console with docker

`-> docker-compose run -it web rails console`

* Run tests with docker

`-> docker-compose run -e "RAILS_ENV=test" -it web rspec`

* Run database migrations

`-> docker-compose run web rails db:migrate`

