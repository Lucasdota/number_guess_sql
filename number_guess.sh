#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# get user
FETCH_USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
# if found
if [[ $FETCH_USER ]]
then
  #get games played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  #get best game
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  # if user not found
else
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  # inserts user
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
fi

GUESS_MAIN_PROMPT() {
  read NUMBER_GUESSED
  # if input was not an integer
  if [[ ! $NUMBER_GUESSED =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    GUESS_MAIN_PROMPT
  else  
    while [[ $HAS_GUESSED = false ]]
    do
      # if guess was correct
      if [[ $NUMBER_GUESSED = $RANDOM_NUMBER ]]
      then
      GUESSED_CORRECT_PROMPT
      HAS_GUESSED=true
      # if guess was not correct
      else
      # increment tries
      TRIES=$((TRIES+1))
      GUESSED_INCORRECT_PROMPT
      fi
    done 
  fi
}

GUESSED_CORRECT_PROMPT() {
  #get games played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  # get best game
  BEST_CURRENT_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  # if not first game
  if [[ $GAMES_PLAYED ]]
  then
    # add games played + 1
    UPDATED_GAMES_PLAYED=$((GAMES_PLAYED+1))
    # update games played
    UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$UPDATED_GAMES_PLAYED WHERE username='$USERNAME'")
    # check if this is his best game
    if [[ $BEST_CURRENT_GAME -lt $TRIES ]]
    then
      # update best game
      UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$TRIES WHERE username='$USERNAME'")
    fi
  else
  # update best game
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$TRIES WHERE username='$USERNAME'")
  # update games played
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=1 WHERE username='$USERNAME'")
  fi 
  echo -e "\nYou guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
}

GUESSED_INCORRECT_PROMPT() {
  # if input was lower than the secret number
  if [[ $NUMBER_GUESSED > $RANDOM_NUMBER ]]
  then
   echo -e "\nIt's lower than that, guess again:\n"
  else
   echo -e "\nIt's higher than that, guess again:\n" 
  fi
  GUESS_MAIN_PROMPT
}

# generates a random number between 1 and 1000
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))
TRIES=1
HAS_GUESSED=false
echo -e "\nGuess the secret number between 1 and 1000:"
GUESS_MAIN_PROMPT  
