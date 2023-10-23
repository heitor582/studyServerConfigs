#!/bin/bash

cd ˜/scripts/studyServerConfigs

docker-compose up --build -d

echo "Waiting for services to become healthy..."

check_health() {
    local service_name=$1
    local health_check_url=$2
    local max_retries=30
    local retry_interval=5

    echo "Checking health of $service_name..."

    for ((i=1; i<=$max_retries; i++)); do
        response=$(curl -s -o /dev/null -w "%{http_code}" $health_check_url)

        if [ "$response" == "200" ]; then
            echo "$service_name is healthy!"
            return 0
        else
            echo "Retrying in $retry_interval seconds..."
            sleep $retry_interval
        fi
    done

    echo "Failed to verify the health of $service_name within the allowed retries."
    return 1
}

# Check the health of services
check_health "Grafana" "http://localhost:3000/health"
check_health "Traefik" "http://localhost:80/health"

# You can add more services and their health check endpoints as needed

if [ $? -eq 0 ]; then
    echo "All services are up and healthy!"
else
    echo "One or more services are not healthy."
fi