# GHG Facility Details

A sample rails app that scrapes facility and detailed information from [https://ghgdata.epa.gov/](https://ghgdata.epa.gov/).
The scraping of data is scheduled on every last day of August every year.

* System dependencies: (Must have installed the ff. locally)
  - Redis
  - Postgresql
  - RVM
 
* Ruby requirements:
  * Version used:
    ```
    ruby-3.0.2
    ```
    Install this version using RVM if not yet available on your local machine.
    
  * Gemset used:
    ```
    ghgdata
    ```
    Create thi gemset if not yet present using `rvm gemset create ghgdata`.

* How to run this app on your local environment
  1. Run `git clone git@github.com:dkdelosreyes/ghgdata.git`
  2. Run `bundle install`
  3. Go to the cloned app directory and copy the contents of `.env.example` to a new file `.env` then update the database credentials variables depending on your local configurations.
  4. Start postgresql `brew services start postgresql`.
  5. Initialize the database:
     ```
     rails db:create
     rails db:migrate
     rails db:seed
     ```
  6. Run `rails s` and access [http://localhost:3000/facilities_geo](http://localhost:3000/facilities_geo) on your browser.
     Here's a [sample returned value](https://gist.github.com/dkdelosreyes/e3d3134fffee6af625df84a46388c751) of this endpoint.

* Manually trigger the scheduled cron job
  1. Run redis locally `redis-server`
  2. Go to [http://localhost:3000/sidekiq/cron](http://localhost:3000/sidekiq/cron).
  3. Under `Cron Jobs`, click the `Enqueue Now` button of the cron job with a name of `ghg_facility_data_scraper_job`.

