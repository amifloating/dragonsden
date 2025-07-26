<#
Class 22008 PowerShell Block: Game Project
Instructor: Capt Jared Schlak
Team: 2d Lt Erica Sandberg
      2d Lt Tetiana Panina
      2d Lt Destiny Cepero
      Chris
Date: 07 Apr 22
#>


#Main() function executes program and calls all other functions in script
function Main(){
    $scores=@{}                              
    $choice                                                #Initialize variables to be used in Main()     
    $doorsarray = @()

    MakeDoors([Ref] $doorsarray)                           #Pass $doorsarray by reference to allow MakeDoors() to write to array
    
    gc .\assets\title.txt                                  #Write game title from .txt file
    do{                                                    # Do-while loop will run until player enters "5" (exit)
        $choice = Menu                                     #Call Menu() to enter menu and read user input into $choice
    switch($choice)                                        #Switch statement using player $choice
    {
        1 {Play}                                           # 1 = Play game
        2 {cat .\leaderboard.txt                           # 2 = Print leaderboard from leaderboard.txt
           write ""
           write ""}
        3 {$scores = @{}                                   # 3 = Clear leaderboard.txt
           WriteLeaderboard($scores)
           write "Leaderboard Cleared.`n"}
        4 {cat .\about.txt}                                # 4 = Print info about game from about.txt
    }
    }
    while($choice -ne 5)                                   # 5 = Exit game
}                                              

#Display Menu and read user input
function Menu(){                               
  do{
    $choice = Read-Host "Please enter a number between 1 and 5
    1 to play
    2 to view leaderboard
    3 to clear leaderboard
    4 to view about info
    5 to exit game
    "
  }
  while ($choice -gt 5 -or $choice -le 0)                  # Input validation, keep asking until user enters number 1-5
  return $choice                                           # Return value entered by user to Main()
}

#Update leaderboard.txt with values from $scores hash table
function WriteLeaderboard($scores){
    $count = 1                                                                  # $count keeps track of entry #

    write " RANK    NAME                SCORE " > leaderboard.txt               # Write leaderboard header into leaderboard.txt
    write " ====	 ======              =======" >> leaderboard.txt
    
    foreach($score in $scores.GetEnumerator() | Sort-Object value -descending){ # Sort $scores entries by value in descending order
        $name = "$($score.key)"                                                 # Convert key and value to strings
        $total = "$($score.value)" 
        $entry = ""                                                             # Initialize $entry string to store entry line                                                      

        if($name.Length -gt 20){$name = $name.substring(0,20)}                  # If name exceeds 20 characters trim to fit          

        $entry += " $count"                                                     # Add entry #

        if($count -ge 100){$entry += "      "}                                  # Add spacing depending on ^ number length
        elseif($count -ge 10){$entry += "       "}
        else{$entry += "       "}

        $entry += $name                                                         # Add name to entry

        for($i=0; $i -lt (20-$name.Length); $i++){                              # Add spacing relative to name length
            $entry += " "
        }

        $entry += $total                                                        # Add score

        write $entry >> leaderboard.txt                                         # Write entry line to leaderboard.txt

        $count++                                                                # Increase entry # by 1
    }
    
}

#Initialize door array with RNG winning door, losing door, and empty doors
function MakeDoors([Ref] $doorsarray){ 
    $doorsarray.Value = @(1,1,1,1,1)                                            # Set $doorsarray to 'blank' state
    $rand = Get-Random -Maximum 5                                               # Generate random index
    $doorsarray.Value[$rand-1] = 2                                              # Set ^ to 2 (WIN)

    do{
        $rand2 = Get-Random -Maximum 5                                          # Generate another random index
    }
    until($rand -ne $rand2)                                                     # Continue to generate until it is different from previous index

    $doorsarray.Value[$rand2-1] = 3                                             # Set to 3 (LOSE)
}

#Sets door value to 0 (OPEN)
function OpenDoor([Ref]$doorsarray, $index){                                    # Pass $doorsarray by reference so OpenDoor can write to array                                
    $doorsarray.Value[$index] = 0                                               # Set door value to 0 (OPEN)                        
}

#Generate appropriate filename and print contents of .txt file to display ASCII graphic
function PrintDoors{ 
$graphic = ""                                                                   # Initialize blank $graphic string to hold filename

    foreach($door in $doorsarray){                                              # For each closed door(1-3 value in $doorsarray) add '1' to $graphic
        if($door){
            $graphic+='1'
        }
        else{                                                                   # For each opened door(0 value in $doorsarray) add '0' to $graphic
            $graphic+='0'
        }
    }
    $graphic+=".txt"                                                            # Add file extension to $graphic

    gc ./assets/$graphic                                                        # Access and print out relevant graphic
}

#Function to play the game
function Play ()
{
   $score = 0                                                                    # Reset score to 0

   do                                                                            # Game loops until player enters 'Q' to quit
   {
       $attempts=3                                                               # Reset attempts each round
       MakeDoors ([Ref]$doorsarray)                                              # Generate doors for this round

       while($attempts -and $guess -ne 'Q'){                                     # Prompt user for input as long as attempts != 0 and user doesn't enter 'Q'                               

        write "ATTEMPTS REMAINING: $attempts                                                                        SCORE: $score"
        PrintDoors
        do{                                                                      # Prompt user for input until input is valid
            # ask user to input a door selection
            $guess = Read-Host "Please select a door by entering a number between 1-5 or type q to quit" 
        }
        until(($guess -in 1..5) -or ($guess -eq 'Q'))
        if($guess -ne 'Q'){
            [int]$index = $guess;                                                # Convert user input to corresponding $doorsarray index
            $index -= 1

            if($doorsarray[$index]){                                             # If door isn't already open, proceed
                write "
                            Door is closed, let's look at what is inside..."
                if($doorsarray[$index] -eq 1){                                   # Empty door
                    write "
                            Sad Face! Looks like this one is not a winner.
                    "
                    OpenDoor ([Ref]$doorsarray) $index
                    $attempts -= 1                                               # Reduce $attempts by 1
                    if(!($attempts)){                                            # If all 3 attempts are used, give user option to continue into HIGH STAKES or forfeit
                        PrintDoors
                        do{$guess = Read-Host "Only two doors remain...would you like to take a chance to win/lose it all[Y], or walk away?[N]"}
                        while(($guess -ne "Y") -and ($guess -ne "N"))

                        if($guess -eq "Y"){                                      # If continue [Y], request user input 1-5
                            do{                                                  # Validate input until user selects valid door
                                do{
                                    # ask user to input a door selection
                                    $guess = Read-Host "Please select a door by entering a number between 1-5"  # Validate input until user chooses number 1-5
                                }
                                until(($guess -in 1..5))

                                [int]$index = $guess;
                                $index -= 1
                            }
                            until($doorsarray[$index])
                            
                            if($doorsarray[$index] -eq 2){                       # If HIGH STAKES win, double points OR award 200 points (if player has no points)
                                gc ./assets/win.txt
                                write "
                                          Congrats! You won! ッ
 [-----------------------------------------------------------------------------------------------------]
                                "
                                if($score){$score = $score*2}
                                else{$score = 200}
                            }
                            elseif($doorsarray[$index] -eq 3){                  # If HIGH STAKES loss, set points to 0
                                gc ./assets/dragon.txt
                                write "
                                   Sorry! You lost! Better luck next time
 [---------------------------------------------------------------------------------------------------]
                                "
                                $score = 0
                                $attempts=0
                            }
                        }

                    }
                }
                elseif($doorsarray[$index] -eq 2){                            # If win, add points 100 * doors opened
                    gc ./assets/win.txt
                    write "
                                          Congrats! You won! ッ
  [----------------------------------------------------------------------------------------------------]
                    "
                    $score+=(100*(4-$attempts))
                    $attempts=0
                }
                elseif($doorsarray[$index] -eq 3){                           # If lose, subtract 100 points
                    gc ./assets/dragon.txt
                    write "
                                   Sorry! You lost! Better luck next time
  [---------------------------------------------------------------------------------------------------]
                    "
                    if($score -ge 100){
                        $score-=100
                    }
                    $attempts=0
                }
                else{                                                       # Exception in case $doorsarray returns unexpected value
                    write "EXCEPTION: unhandled door input"
                }
            }
            else{                                                                                      # If door is already open, request new input
                write "Door is already open, please choose another door
                "
            }
            
        } 
       }
   }
   while ($guess -ne 'Q')                                                 # Exit loop on user input 'Q'

   write "                                                FINAL SCORE     
                                                ----------- 
                                                    $score"               # Print player's final score
   $name = Read-Host "Please enter a name to be added to the leaderboard" # Request player name input for leaderboard

   $scores.add($name, $score)                                             # Add entry to $scores hash table with player name (KEY) and final score (VALUE)

   WriteLeaderboard($scores)                                              # Pass updated $scores to WriteLeaderboard()
  }
