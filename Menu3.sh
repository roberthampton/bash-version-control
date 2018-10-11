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
	if [ $success = 0 ]; then 
	echo "Welcome back $log"
	repMenu
	fi
	#Otherwise, this takes them back to the main menu
	if [ $success = 1 ]; then
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
repMenu(){
	local finished=1
	echo 'Please enter your choice: '
	while (( finished != 0 )); do
		options=("Create a New Repository" "Access Existing Repository" "Quit")
	select opt in "${options[@]}"
	do
	    case $opt in
	        "Create a New Repository")
	            createRepository
	            ;;
	        "Access Existing Repository")
	            findRepository
	            ;;
	        "Quit")
	            finished=0 && break
	            ;;
	        *) echo "invalid option"
				;;
	    esac
	    break
	done
done
	
}


#Creates a directory using the name input by the user. Could possibly be edited to be a TAR'ed archive.  
#Also, repo will always be created in the whatever is the current directory which is not ideal
#could update/create new function to give option of where the file should be created.
createRepository()
{
	local success=1
	if [ ! -d "Repositories" ]; then
 	mkdir Repositories
    fi
    cd Repositories
	while [ $success -ne 0 ]
	do
		echo "please enter the name of the new repository"
		local repoName
		read -r repoName
		mkdir $repoName > /dev/null 2>&1
		local retVal=$?
		if [ $retVal -ne 0 ]
		then
			echo "failed"
		else
			echo "succeeded" && success=0
		fi
	done

	cd $repoName && touch changelog.txt && repositoryMenu
	
}

#There should be a better way to navigate repositories, maybe saving repo names to a log everytime one is
#created then presenting this as options using a case statement again? not sure if this is possible.
findRepository()
{
	local success=1
	while [ $success -ne 0 ]
	do
		echo "please enter the name of the repository you would like to access"
		local repoName
		read -r repoName
		cd Repositories/$repoName/ > /dev/null 2>&1 
		local retVal=$?
			if [ $retVal -ne 0 ]
			then
				echo "failed"
			else
				echo "succeeded" && success=0
			fi
	done

	repositoryMenu
}

#Menu displayed when accessing a repo - allows user to take actions within the repo. 
repositoryMenu()
{
	unzipRepositories
	local finished=1
	echo 'Please enter your choice: '
	while (( finished != 0 )); do
	displayRepository
	options=( "Create a New File" "Edit a File" "Rename a File" "Back to Main Menu")
	select opt in "${options[@]}"
	do
	    case $opt in
	    	"Create a New File")
	            createFile
	            ;;
	        "Edit a File")
	            editFile
	            ;;
	        "Rename a File")
	            renameFile
	            ;;
	        "Back to Main Menu")
	            finished=0 && zipRepositories && break
	            ;;
	        *) echo "invalid option $REPLY";;
	    esac
	    break
	done
done
}

displayRepository()
{
	echo "This repository contains the following: "
	ls
}


#This method could be updated later to allow the user to select their own filetype
createFile()
{
	echo "Please enter the name of the new file: "
	local fileName
	read -r fileName
	local type=".txt"
	completeName=$fileName$type

	if [ -e $completeName > /dev/null 2>&1  ]
	then
	    echo "This File Already Exists"
	else
		if [[ "$completeName" =~ \ |\' ]] 
		then
			echo "File could not be created. File names may not contain spaces or single quotes"
		else
	    	touch $completeName
	   		echo "File Created"
		fi
	fi
}


editFile()
{
	echo "Please enter the name of the file to be edited: "
	read -r fileToEdit

	if [ -e $fileToEdit > /dev/null 2>&1 ];
	then
	     gedit $fileToEdit
	else
		echo "This file does not exist"
	fi
}

renameFile()
{
	echo "Please enter the name of the file you would like to rename "
	read -r fileToRename

	if [ -e $fileToRename > /dev/null 2>&1 ];
	then
	      echo "Please enter the new name for this file"
	      read newName
	      if [[ "$newName" =~ \ |\' ]] 
		then
			echo "File could not be renamed. File names may not contain spaces or single quotes"
		else
	    	mv $fileToRename $newName
	   		echo "File reanmed"
		fi
	else
		echo "This file does not exist"
	fi
}

zipRepositories()
{
	cd .. && cd ..
	if [ -d "Repositories" ]; then
		gzip -r Repositories
	fi
}

unzipRepositories()
{
	if [ -d "Repositories" ]; then
 	gzip -t Repositories 2>/dev/null
	[[ $? -eq 0 ]] && echo "Compessed file" || echo "Not compressed"
    fi
}

mainMenu
