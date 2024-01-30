#!/bin/sh

SERVICES="postgresdb app"
TRIES=0
DELAY_TIME=5
MAX_TRIES=36
ALL_RUNNING=1

# Stops any container created by docker compose up
stop_containers () {
    echo Stopping containers...
    docker compose down
}

# Exits the program with a failure if the sanity check tries reached their
# maximum limit
exit_if_failed () {
    if [ $TRIES -eq $MAX_TRIES ]
    then
        echo "Docker compose time ran out"
        stop_containers
        exit 1
    fi
}

# Checks if all the services have their containers created and running
all_services_up () {
    for s in $SERVICES
    do
        CONTAINER="$(docker compose ps -q -a $s)"
        echo Checking out if service $s is already created by docker compose
        echo Service $s container id: $CONTAINER

        if [ "$CONTAINER" = "" ]
        then
            echo Non existent container for $s
            return 1
        fi

        if [ "$(docker inspect -f {{.State.Running}} $CONTAINER)" != "true" ]
        then
            echo Container for $s service is not running
            return 1 
        fi
    done

    echo All services running
    return 0
}

if [ ! -e ./.env ] 
then
    echo No .env file provided for docker compose sanity hook
    exit 1
fi

# Start the containers in detached mode to allow other commands execution
docker compose up -d

until [ $TRIES -eq $MAX_TRIES ] || [ $ALL_RUNNING -eq 0 ]
do
    all_services_up
    ALL_RUNNING=$?
    TRIES=$(($TRIES + 1))
    sleep $DELAY_TIME
done

exit_if_failed

stop_containers
exit 0