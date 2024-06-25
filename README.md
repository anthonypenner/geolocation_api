Geolocation API
===============

This is a Rails-based Geolocation API that uses Docker for containerization.

Prerequisites
-------------

*   Docker
*   Docker Compose

Getting Started
---------------

### Clone the Repository

    git clone https://github.com/anthonypenner/geolocation_api.git
    cd geolocation_api

### Build and Run the Application

1.  **Build and start the containers:**

    IPSTACK_API_KEY=redacted docker-compose up --build

This command will build the Docker images and start the containers. It will also run the database migrations.

2.  **Access the Application:**

The application will be accessible at `http://localhost:3000`.

Testing Endpoints with curl
---------------------------

### Create a new GeoLocation with a valid IP

    curl -X POST http://localhost:3000/api/v1/geolocations \
    -H "Content-Type: application/json" \
    -d '{"ip_or_url": "8.8.8.8"}'

### Create a new GeoLocation with a valid URL

    curl -X POST http://localhost:3000/api/v1/geolocations \
    -H "Content-Type: application/json" \
    -d '{"ip_or_url": "https://example.com"}'

### Create a new GeoLocation with an invalid IP

    curl -X POST http://localhost:3000/api/v1/geolocations \
    -H "Content-Type: application/json" \
    -d '{"ip_or_url": "999.999.999.999"}'

### Create a new GeoLocation with an invalid URL

    curl -X POST http://localhost:3000/api/v1/geolocations \
    -H "Content-Type: application/json" \
    -d '{"ip_or_url": "invalid-url"}'

### Get GeoLocation information for an existing IP

    curl -X GET http://localhost:3000/api/v1/geolocations/8.8.8.8

### Get GeoLocation information for an existing URL

    curl -X GET http://localhost:3000/api/v1/geolocations/example.com

### Get GeoLocation information for a non-existent IP

    curl -X GET http://localhost:3000/api/v1/geolocations/1.1.1.1

### Get GeoLocation information for a non-existent URL

    curl -X GET http://localhost:3000/api/v1/geolocations/nonexistent-url.com

### Delete an existing GeoLocation by IP

    curl -X DELETE http://localhost:3000/api/v1/geolocations/8.8.8.8

### Delete an existing GeoLocation by URL

    curl -X DELETE http://localhost:3000/api/v1/geolocations/example.com


### Environment Variables

The following environment variables are used in the application:

*   `DATABASE_URL`: Connection URL for the PostgreSQL database.
*   `IPSTACK_API_KEY`: API key for the IPStack service.
*   `SECRET_KEY_BASE`: Secret key base for the Rails application.

These are defined in the `docker-compose.yml` file.

Troubleshooting
---------------

If you encounter issues, you can view the logs for the `web` and `db` services using:

    docker-compose logs web
    docker-compose logs db

Stopping the Application
------------------------

To stop the application, use the following command:

    docker-compose down

This command will stop and remove the containers.

License
-------

This project is licensed under the MIT License.
