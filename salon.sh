#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to my salon, how can I help you?"
  fi
  # get list of services
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  # print available services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # get customer selection
  read SERVICE_ID_SELECTED
  # if service is not available
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_NAME ]]
  then
    SERVICE_MENU "I could not find that service. What would you like today?"
  else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get customer name and insert info into customers table
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    # ask for appointment time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    # book appointment
    INSERT_APPOINTMENT_RESULTS=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED);")
    # confirm appointment info
    echo -e "I have put you down for a $( echo $SERVICE_NAME | sed 's/ //g' ) at $( echo $SERVICE_TIME | sed 's/ //g' ), $( echo $CUSTOMER_NAME | sed 's/ //g' )."
  fi
}

SERVICE_MENU