#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi

  SERVICE_MENU
}

SERVICE_MENU(){
  SERVICES_AVAILABLE=$($PSQL "select service_id, name from services order by service_id")
  
  if [[ -z $SERVICES_AVAILABLE ]]
  then
    MAIN_MENU "We don't offer any services yet."
  else
    echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED

    SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID")
      CUSTOMER_MENU
    fi
  fi
}

CUSTOMER_MENU(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  #find the customer
  CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
  
  #if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    #insert new customer
    CUSTOMER_INSERT_RESULT=$($PSQL "insert into customers (name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  #get customer ID
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

  echo -e "\nWhat time would you like your $(FORMATTED_NAME $SERVICE_NAME), $(FORMATTED_NAME $CUSTOMER_NAME)?"
  read SERVICE_TIME

  #insert appointment
  APPOINTMENT_INSERT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $(FORMATTED_NAME $SERVICE_NAME) at $(FORMATTED_NAME $SERVICE_TIME), $(FORMATTED_NAME $CUSTOMER_NAME)."
}

FORMATTED_NAME(){
  echo $1 | sed -r 's/^ *| *$//g'
}

MAIN_MENU
