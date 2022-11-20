#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nWelcome to salon appointment reservation service\n"

SELECT_SERVICE() {
  if [[ $1 ]] 
  then
    echo $1
  else
    echo -e "\nWhat should we do to your hair?"
  fi
  echo "$($PSQL "SELECT * FROM services")" | while read ID BAR SERVICE
  do
    echo "$ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    SELECT_SERVICE "Select a service we are offering"
  else
    echo -e "\nYour phone numnber?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nEnter your name:"
      read CUSTOMER_NAME
      CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      if [[ $CUSTOMER_INSERT_RESULT == "INSERT 0 1" ]]
      then
        echo -e "\nSaved your information for future appointments $CUSTOMER_NAME!"
      fi
    fi
    echo -e "\nAt what time you want to have your appointment $CUSTOMER_NAME?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ //') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ //')."
    fi
  fi
}

SELECT_SERVICE
