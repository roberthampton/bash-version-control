#!/bin/bash
# This is the top level of the menu, this is where the users log into the system with their login
mainMenu(){
	local logfin=1
	#This is where they enter the loop, this is kept running in the background while the user works through other menus and it returns to it at the end
	while (( logfin != 0 )); do
echo 'Please enter your choice:'
		#This is the array of options
		options1=("Login" "Get help" "Quit")
	#This creates three cases, case 1 is the user logs in, case 2 the user seeks help with the options and case 3 the project completes and closes
	select opt1 in "${options1[@]}"
	do
	    case $opt1 in
	        "Login")
	            loginOptions
	            ;;
	        "Get help")
	            helpMe
	            ;;
	        "Quit")
	            logfin=0 && break
	            ;;
	        *) echo "invalid option"
				;;
	    esac
	    break
	done
done

}
#This is where the system calculates the need info for a login, this takes the info the user enters and checks it against login credentials
loginOptions()
{
	#The two options that the user fills in, it reads these options filling in the info the user inputs
	echo "please enter a username:"
	read -r log
	echo "please enter a password"
	read -r pass
	#This then checks the information that the user has input against the info it has stored 
       	if [ $pass = "Password" ] && [ $log = "Tim" ]; then
		success=0
	elif [ $pass = "Password2" ] && [ $log = "Frank" ]; then
		success=0
	elif [ $pass = "Password3" ] && [ $log = "Sarah" ]; then
		success=0
	elif [ $pass = "Password4" ] && [ $log = "Greg" ]; then
		success=0
	fi
	#This checks if the user info has been input correct, then logs in
	if [ $success = 0 > /dev/null 2>&1]; then 
	echo "Welcome back $log"
	repMenu
	fi
	#Otherwise, this takes them back to the main menu
	if [ $success = 1 > /dev/null 2>&1 ]; then
	echo "Some of the information you entered is incorrect"
	fi
}
#This prints the basic menu to the user, this explains all possible outcomes at this current time, this will explain the current options
helpMe()
{
	echo "Menu Options"
	echo "Login: Login allows you to log into the repository, this will ask for your details"
	echo "Exit: This will exit the programme"
}
#Main menu, to act as the 'starting screen' after logging in. 
repMenu(){
	local finished=0
	echo 'Please enter your choice: '
	#This is where the menu options display, similarly to 
	while (( finished != 1 )); do
		options=("Create a New Repository" "Access Existing Repository" "Delete a Repository" "Backup a Repository" "Roll back a Repository to last backup" "Quit")
	select opt in "${options[@]}"
	do
		#These provide all the cases that the system can make at this point, this includes creating and entering a repository, and also providing a backup
	    case $opt in
	        "Create a New Repository")
	            createRepository
	            ;;
	        "Access Existing Repository")
	            decompressRepositories && checkRepositories
	            ;;
	        "Delete a Repository")
	            deleteRepository
	            ;;
	        "Backup a Repository")
	            backupRepository
	            ;;
	        "Roll back a Repository to last backup")
	            rollbackRepository
	            ;;
	        "Quit")
	            finished=1 && compressRepositories && break
	            ;;
	        *) echo "invalid option"
				;;
	    esac
	    break
	done
done

}


#First checks is the repositories folder exists, and if not it is created.
#It then creates a directory using the name input by the user in the repository folder.
createRepository()
{
	local exit=1
	leaveRepositories
	if [ ! -d "Repositories" ]; then
 	mkdir Repositories
    fi
    #This method allows the user to choose a name for their upcoming repository, and then provides the user with it
    goToRepositories
	while [ $exit -ne 0 ]
	do
		echo "please enter the name of the new repository"
		local repoName
		read repoName
		mkdir $repoName > /dev/null 2>&1
		local retVal=$?
		if [ $retVal -ne 0 ]
		then
			echo "failed"
		else
			echo "succeeded" && exit=0
		fi
	done
	#Once it has succeeded, it will automatically add the changelog to the repository, this is located in all of them to make sure that changes are seen
	cd $repoName && touch changelog.txt && echo "Changelog: (If there is noting after this no changes have yet been made)" >> changelog.txt && repositoryMenu
	
}

#creates and then checks the array of repositories to see if the first element is a directory, to see 
#if there are any directories that can be accessed. If there are it calls the function to select a repository
checkRepositories()
{
	createRepoArray
	#This makes the check, if it finds none, it tells the user non are found, then exits, otherwise it finds it
	if [ ${repoArray[0]} == '*' ]
	then
		echo "You have no saved repositories to access"
	else
		selectRepository
	fi	

}
#This method is where the user selects the specific amount they would like to enter into, this will vary based on size, and if they say to many, it will tell the user
selectRepository()
{
	goToRepositories
	local exit=0
	#This determines while the user isnt exiting, do not have the user leave, this gives the user control, on typing "exit" the user will escape
	while [ $exit -ne 1 ]
	do
	counter=1
	for i in "${repoArray[@]}"
	do
   		echo "$counter) $i"
   		((counter++))
	done
		echo "please enter the number of the repository you would like to access. Enter exit to cancel"
		read repoNumber
	if [ $repoNumber == "exit" ]
	then
		exit=1
	elif [ $repoNumber -lt 1 ] || [ $repoNumber -gt $counter ]
	then
		echo "This is not an option, please try again" 
	else
		echo "${repoArray[(($repoNumber-1))]}"
		cd "${repoArray[(($repoNumber-1))]}"
		exit=1
		#This takes the user back to the repository menu, where they can select another option
		repositoryMenu
	fi
	done
}

#Menu displayed when accessing a repo - allows user to take actions within the repo. 
repositoryMenu()
{
	local finished=0
	echo 'Please enter your choice: '
	#Similar to the other menus, this menu will keep running till the user needs to leave it, this option is always availible
	while (( finished != 1 )); do
	displayRepository
	options=( "Create a New File" "Edit a File" "Rename a File" "Delete a File" "Back to Main Menu")
	select opt in "${options[@]}"
	do
	    case $opt in
		#This creates a new file for the user, by opening the method
	    	"Create a New File")
	            createFile
	            ;;
				#This runs the edit file method
	        "Edit a File")
	            editFile
	            ;;
				#This runs the rename a file method
	        "Rename a File")
	            renameFile
	            ;;
				#This runs the delete file method
	        "Delete a File")
	    	    deleteFile
	            ;;
				#With this they will return up the menu to the repMenu, this will give them the options present at that stage
	        "Back to Main Menu")
	            finished=1 && leaveRepositories && break
	            ;;
	        *) echo "invalid option $REPLY";;
	    esac
	    break
	done
done
}
#This method displays all repositories located in that area
displayRepository()
{
	echo "This repository contains the following: "
	ls
}


#This method allows the user to create a file 
createFile()
{
	echo "Please enter the name of the new file (please ensure to include the file extension eg .c or .txt): "
	local fileName
	read -r fileName
	#After getting a name from the user, this creates the file, if it exists, it lets the user know, then doesn't
	if [ -e $fileName > /dev/null 2>&1  ]
	then
	    echo "This File Already Exists"
	else
		if [[ "$completeName" =~ \ |\' ]] 
		then
			#They can also enter special characters, this also stops the user entering information
			echo "File could not be created. File names may not contain spaces or single quotes"
		else
			#if none of the fail criteria are met, then create the file
	    	touch $fileName
	   		echo "File Created"
		fi
	fi
}

#This method allows the user to open a text editor and edit content in the file
editFile()
{
	echo "Please enter the name of the file to be edited: "
	read -r  fileToEdit
	#This is where the user selects a file, this will determine if the user has a file open, this wont allow edits
	if [ -e $fileToEdit > /dev/null 2>&1 ];
	then
		echo "Please check the changelog below to see if this file is currently being worked on"
		tail changelog.txt
		#This allows the user to confim they want to edit, then it opens the file for them
		local exit=0
		local ignore=0
		while [ $exit -ne 1 ]
		do
		read -p "Are you sure you want to edit this file (y/n)?" choice
		case "$choice" in 
		  y|Y ) gedit $fileToEdit && checkFileOut && exit=1;;
		  n|N ) exit=1 && ignore=1;;
		  * ) echo "invalid input";;
		esac
	done

		
		#This is done after they open the terminal again, this allows the user to confim their edits, a no will open the editor again
	    local exit=0
		while [ $exit -ne 1 ] &&  [ $ignore -ne 1 ]
		do
		read -p "Are you done editing this file (y/n)?" choice
		case "$choice" in 
		  y|Y ) checkFileIn && exit=1;;
		  n|N ) gedit $fileToEdit;;
		  * ) echo "invalid input";;
		esac
	done

	#This is created for the event a file isnt in existence, deleted or otherwise
	else
		echo "This file does not exist"
	fi
}
#This method adds edits to the changelog, so the system knows who has logged it out
checkFileOut()
{
	DATE=`date` 
	WHOAMI=`whoami`
	echo "User $WHOAMI checked out the file $fileToEdit at $DATE" >> changelog.txt
}
#This method adds edits to the changelog, so the system knows who has logged it back in
checkFileIn()
{
	DATE=`date` 
	WHOAMI=`whoami`
	echo "User $WHOAMI checked the file $fileToEdit back in at $DATE" >> changelog.txt
}
#This method allows the user to rename an existing file to a new name
renameFile()
{
	echo "Please enter the name of the file you would like to rename "
	read -r fileToRename
	#After reading in the name, the system checks that the system has that file. if it does confirm that new name
	if [ -e $fileToRename > /dev/null 2>&1 ];
	then
	      echo "Please enter the new name for this file"
	      read newName
	      if [[ "$newName" =~ \ |\' ]] 
		then
			#This is validation against special characters, they cannot be contained in a file name
			echo "File could not be renamed. File names may not contain spaces or single quotes"
		else
	    	mv $fileToRename $newName
	   		echo "File reanmed"
		fi
	#This is in the case a file isnt found under that name	
	else
		echo "This file does not exist"
	fi
}
#This is if you want to delete an entire repository
deleteRepository()
{
	local exit=0
	goToRepositories
	#This displays to the user the availible repositories, then offers them the choice of what to delete
	echo "The repositories you have are as follows: "
	ls
	echo "Please enter the name of the repository you would like to delete (to cancel enter 'exit') "
	read repoToDelete
	#This is if the user wants to cancel, it will cancel the method, the return them to the menu
	if [ $repoToDelete == "exit" ]
	then
		echo "operation cancelled"
	#Otherwise, it will continue the method, confirming the user wants to delete that repository, in the event of no, it exits	
	elif [ -d $repoToDelete > /dev/null 2>&1 ];
	then
		while [ $exit -ne 1 ]
		do
			read -p "Are you sure you want to delete this repository (y/n)?" choice
			case "$choice" in 
			  y|Y ) rm -r $repoToDelete && echo "Repository deleted" && exit=1;;
			  n|N ) exit=1;;
			  * ) echo "invalid input";;
			esac
		done    
	#If the repository doesnt exist, it will take them to here	
	else
		echo "This repository does not exist"
	fi
}
#This method deletes a singular file
deleteFile()
{
	echo "Please enter the name of the file you would like to delete "
	read -r fileToDelete
	#Once the user enters the file name, this checks for it, once found it will offer them the choice of deleting, no will exit and not delete, yes will delete it
	if [ -e $fileToDelete > /dev/null 2>&1 ];
	then
		local exit=0
		while [ $exit -ne 1 ]
		do
			read -p "Are you sure you want to delete this file (y/n)?" choice
			case "$choice" in 
			  y|Y ) rm $fileToDelete && echo "File deleted" && exit=1;;
			  n|N ) exit=1;;
			  * ) echo "invalid input";;
			esac
		done
	#In the event the file doesnt exist, they are taken here
	else
		echo "This file does not exist"
	fi

	

}
#This method allows the users to jump between repositories
goToRepositories()
{
	if [[ ! "$PWD" =~ Repositories ]] 
	then
		cd Repositories > /dev/null 2>&1 
	fi
}
#This will back them out of a repository, similar to a cd -
leaveRepositories()
{
	while [[ "$PWD" =~ Repositories ]] 
	do
		cd .. 
	done
}
#This creates the array of repositories, ready for the user to select them
createRepoArray()
{
	leaveRepositories
	repoArray=()
	if [ -d "Repositories" ]; 
	then
		a=0
		goToRepositories
		for i in *;
		do
			repoArray[$a]=$i
			((a++))
		done
	fi
}
#This is the method that creates a zip/tar of the repository, in this case TAR is used, as zip only works on files
compressRepositories()
{
	createRepoArray
	#After confirming the selected repository exists, it creates the TAR of it
	if [ ${repoArray[0]} != '*' ]
	then	
	for i in "${repoArray[@]}"
	do
		if [[ $i != *.gz ]]
		then
   		tar -czf "$i".tar.gz $i > /dev/null 2>&1
   		rm -r "$i"
   		fi
	done
fi
}
#This is the exact opposite of the creation of the TAR zipped file, this opens back up the repositories
decompressRepositories()
{
	createRepoArray
	for i in "${repoArray[@]}"
	do
		if [[ $i == *.gz ]]
		then
			tar -xzf "$i"
			rm "$i"
		fi
	done
}
#This is where the backup repositories are created, this is in-case the user wishes to go back to an old version
backupRepository()
{
	leaveRepositories
	if [ ! -d "RepoBackups" ]; then
 	mkdir RepoBackups
    fi
    goToRepositories
    createRepoArray
	#This shows the user what repositories they have availible, then asks which they want to backup
    local exit=0
    echo "The repositories you have are as follows: "
	ls
    echo "Please enter the name of the repository you would like to backup (to cancel enter 'exit') "
	read repoToBackup
	local found=0
	#This confims the user selection, if exit is entered, then nothing is done, and they go back to menu
	for i in "${repoArray[@]}"
	do
		if [ "$repoToBackup" == "$i" ]
		then
			found=1
   		fi
	done
	
	if [ $repoToBackup == "exit" ]
	then
		echo "operation cancelled"
		#If the repository is found and they havent said exit, they can backup the repository here
	elif [ found=1 ];
	then
		if [[ $repoToBackup != *.gz ]]
		then
   		tar -czf "$repoToBackup".tar.gz $i > /dev/null 2>&1
   		rm -r "$repoToBackup"
   		fi
		#This is the final conformation that the user wishes to backup the repositiory, a no exits the method, a yes backs it up
		while [ $exit -ne 1 ]
		do
			read -p "Are you sure you want to backup this repository? This will overwrite your last backup (y/n)" choice
			case "$choice" in 
			  y|Y )cp $i.tar.gz "backup$i.tar.gz" && leaveRepositories && cd RepoBackups && mv ../Repositories/"backup$i.tar.gz" .  && cd .. && exit=1;;
			  n|N ) exit=1;;
			  * ) echo "invalid input";;
			esac
		done    
	else
		echo "This repository does not exist"
	fi
	
}
#This method is if they user has decided to go to a backup of a repository to restore a previous version
rollbackRepository()
{
	decompressRepositories
	createRepoArray
	#This checks the users availible backups
	local exit=0
    echo "The repositories you have are as follows: "
	ls
    echo "Please enter the name of the repository you would like to rollback (to cancel enter 'exit') "
	read -r repoToRollback
	local found=0
	#After entering the backup and selecting it, the system double checks the info, then grabs the backup for them
	for i in "${repoArray[@]}"
	do
		if [ "$repoToRollback" == "$i" ]
		then
			found=1
   		fi
	done
	#If they enter exit, nothing will happen and they will return to the menu
	if [ $repoToRollback == "exit" ]
	then
		echo "operation cancelled"
	elif [ found=1 ];
	then
		#This gives final conformation with the user they want to revert, no exits and doesnt do it, yes reverts it
		while [ $exit -ne 1 ]
		do
			leaveRepositories && cd RepoBackups > /dev/null 2>&1
			if [[ -f "backup$repoToRollback.tar.gz" ]]; then
				cd .. && goToRepositories
				read -p "Are you sure you want to rollback this repository? This cannot be undone (y/n)" choice
				case "$choice" in 
				  y|Y ) mv ../RepoBackups/"backup$repoToRollback.tar.gz" . && mv "backup$repoToRollback.tar.gz" "$repoToRollback.tar.gz" && rm -r $repoToRollback > /dev/null 2>&1 && exit=1;;
				  n|N ) exit=1;;
				  * ) echo "invalid input";;
				esac
			#If no backup was found of this name, they go here
			else
				echo "There is no backup saved for this repository" && exit=1
			fi
		done  
	#If it couldnt find the name at all, this will take the user here
	else
		echo "This repository does not exist"
	fi
}




mainMenu