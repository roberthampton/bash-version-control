#!/bin/bash
#This is a draft of the menu to be edited and updated later, once we know exactly what the options are
#Functions could possibly be split up into separate scripts, or just kept as one file. 

#Main menu, to act as the 'starting screen' after logging in. 
#Plan is to write a method to handle logging in that then calls this method once log in successful
mainMenu(){
	local finished=0
	echo 'Please enter your choice: '
	while (( finished != 1 )); do
		options=("Create a New Repository" "Access Existing Repository" "Delete a Repository" "Backup a Repository" "Roll back a Repository to last backup" "Quit")
	select opt in "${options[@]}"
	do
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

	cd $repoName && touch changelog.txt && echo "Changelog: (If there is noting after this no changes have yet been made)" >> changelog.txt && repositoryMenu
	
}

#creates and then checks the array of repositories to see if the first element is a directory, to see 
#if there are any directories that can be accessed. If there are it calls the function to select a repository
checkRepositories()
{
	createRepoArray
	if [ ${repoArray[0]} == '*' ]
	then
		echo "You have no saved repositories to access"
	else
		selectRepository
	fi	

}

selectRepository()
{
	goToRepositories
	local exit=0
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
		repositoryMenu
	fi
	done
}

#Menu displayed when accessing a repo - allows user to take actions within the repo. 
repositoryMenu()
{
	local finished=0
	echo 'Please enter your choice: '
	while (( finished != 1 )); do
	displayRepository
	options=( "Create a New File" "Edit a File" "Rename a File" "Delete a File" "Back to Main Menu")
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
	        "Delete a File")
	    	    deleteFile
	            ;;
	        "Back to Main Menu")
	            finished=1 && leaveRepositories && break
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
	echo "Please enter the name of the new file (please ensure to include the file extension eg .c or .txt): "
	local fileName
	read fileName

	if [ -e $fileName > /dev/null 2>&1  ]
	then
	    echo "This File Already Exists"
	else
		if [[ "$completeName" =~ \ |\' ]] 
		then
			echo "File could not be created. File names may not contain spaces or single quotes"
		else
	    	touch $fileName
	   		echo "File Created"
		fi
	fi
}


editFile()
{
	echo "Please enter the name of the file to be edited: "
	read  fileToEdit

	if [ -e $fileToEdit > /dev/null 2>&1 ];
	then
		echo "Please check the changelog below to see if this file is currently being worked on"
		tail changelog.txt

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


	else
		echo "This file does not exist"
	fi
}

checkFileOut()
{
	DATE=`date` 
	WHOAMI=`whoami`
	echo "User $WHOAMI checked out the file $fileToEdit at $DATE" >> changelog.txt
}

checkFileIn()
{
	DATE=`date` 
	WHOAMI=`whoami`
	echo "User $WHOAMI checked the file $fileToEdit back in at $DATE" >> changelog.txt
}

renameFile()
{
	echo "Please enter the name of the file you would like to rename "
	read fileToRename

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

deleteRepository()
{
	local exit=0
	goToRepositories
	echo "The repositories you have are as follows: "
	ls
	echo "Please enter the name of the repository you would like to delete (to cancel enter 'exit') "
	read repoToDelete
	if [ $repoToDelete == "exit" ]
	then
		echo "operation cancelled"
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
	else
		echo "This repository does not exist"
	fi
}

deleteFile()
{
	echo "Please enter the name of the file you would like to delete "
	read fileToDelete

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
	else
		echo "This file does not exist"
	fi

	

}

goToRepositories()
{
	if [[ ! "$PWD" =~ Repositories ]] 
	then
		cd Repositories > /dev/null 2>&1 
	fi
}

leaveRepositories()
{
	while [[ "$PWD" =~ Repositories ]] 
	do
		cd .. 
	done
}

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

compressRepositories()
{
	createRepoArray

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

backupRepository()
{
	leaveRepositories
	if [ ! -d "RepoBackups" ]; then
 	mkdir RepoBackups
    fi
    goToRepositories
    createRepoArray

    local exit=0
    echo "The repositories you have are as follows: "
	ls
    echo "Please enter the name of the repository you would like to backup (to cancel enter 'exit') "
	read repoToBackup
	local found=0

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
	elif [ found=1 ];
	then
		if [[ $repoToBackup != *.gz ]]
		then
   		tar -czf "$repoToBackup".tar.gz $i > /dev/null 2>&1
   		rm -r "$repoToBackup"
   		fi

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

rollbackRepository()
{
	decompressRepositories
	createRepoArray
	local exit=0
    echo "The repositories you have are as follows: "
	ls
    echo "Please enter the name of the repository you would like to rollback (to cancel enter 'exit') "
	read repoToRollback
	local found=0

	for i in "${repoArray[@]}"
	do
		if [ "$repoToRollback" == "$i" ]
		then
			found=1
   		fi
	done

	if [ $repoToRollback == "exit" ]
	then
		echo "operation cancelled"
	elif [ found=1 ];
	then
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
			else
				echo "There is no backup saved for this repository" && exit=1
			fi
		done    
	else
		echo "This repository does not exist"
	fi
}




mainMenu

