#!/bin/bash
#This is a draft of the menu to be edited and updated later, once we know exactly what the options are
#Functions could possibly be split up into separate scripts, or just kept as one file. 

#Main menu, to act as the 'starting screen' after logging in. 
#Plan is to write a method to handle logging in that then calls this method once log in successful
mainMenu(){
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
	while [ $success -ne 0 ]
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
		read repoName
		cd $repoName > /dev/null 2>&1 
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
	            echo "you chose choice 2"
	            ;;
	        "Back to Main Menu")
	            finished=0 && break
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
	read fileName
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

#Still needsa lot of work, do during lab
editFile()
{
	echo "Please enter the name of the file to be edited: "
	local fileName
	read $fileName

	if [ -e $fileName > /dev/null 2>&1  ]
	then
	   nano $fileName
	else
		echo "This file does not exist"
	fi

}


mainMenu
