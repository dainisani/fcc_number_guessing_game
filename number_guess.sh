#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:\n"

read USERNAME

USER=$($PSQL "SELECT * FROM players WHERE username = '$USERNAME'")

if [[ -z $USER ]]
then

  NEW_USER=$($PSQL "INSERT INTO players(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."

else
  echo "$USER" | while IFS=\| read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

RANDOM_NUMBER=$((1 + $RANDOM % 1000))

NUMBER_OF_GUESSES=1

echo -e "\nGuess the secret number between 1 and 1000:\n"

read GUESS

while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo -e "\nThat is not an integer, guess again:\n"

  read GUESS
done

while true
do
  if [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:\n"

    read GUESS

    while [[ ! $GUESS =~ ^[0-9]+$ ]]
    do
      echo -e "\nThat is not an integer, guess again:\n"

      read GUESS
    done

    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
  else
    if [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
    echo -e "\nIt's higher than that, guess again:\n"

    read GUESS

    while [[ ! $GUESS =~ ^[0-9]+$ ]]
    do
      echo -e "\nThat is not an integer, guess again:\n"

      read GUESS
    done

    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
    else

      GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username = '$USERNAME'")
      GAMES_PLAYED=$((GAMES_PLAYED+1))

      BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username = '$USERNAME'")

      UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")

      if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]] || [[ $BEST_GAME == 0 ]]
      then
        UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
      fi

      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!\n"

      break
    fi
  fi
done
