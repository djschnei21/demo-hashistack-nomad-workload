#!/bin/bash

# Check if MongoDB is available and ready to accept connections
until mongosh "mongodb://localhost:27017" --nodb --shell --quiet --eval "print('waited for connection')"; do sleep 1; done


# If MongoDB is ready, create the user
mongosh "mongodb://localhost:27017" --nodb --shell --quiet --eval "db.getSiblingDB('admin').createUser({user: 'admin', pwd: 'password', roles: [{role:'root', db:'admin'}]})"