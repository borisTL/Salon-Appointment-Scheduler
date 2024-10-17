#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

# Function to display services
display_services() {
  echo -e "\nWelcome to the Salon Appointment Scheduler\n"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Loop until valid service is selected
SERVICE_ID_SELECTED=""
while [[ -z $SERVICE_ID_SELECTED ]]
do
  # Display services
  display_services

  # Prompt for service ID
  echo -e "\nWhich service would you like?"
  read SERVICE_ID_SELECTED

  # Check if the entered service ID exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid service. Please select a valid service."
    SERVICE_ID_SELECTED="" # Reset if invalid
  fi
done

# Proceed with the rest of the script
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nWhat's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

echo -e "\nWhat time would you like your appointment?"
read SERVICE_TIME

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
