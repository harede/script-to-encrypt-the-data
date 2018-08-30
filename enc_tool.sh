#!/usr/bin/bash

if [[ "$2" == '/' || "$2" == './' || "$2" == "$(basename $0)" || "$2" == '*' || "$2" == '/' || "$2" == '@' || "$2" == '-' || "$2" == '\' || "$2" == '.' || "$2" == '#' || "$2" == '/root' ]]
        then
        echo -e "\nYou cannot specify \"/\" or \"./\" spacial characters and script itself because orginal file/dir will be deleted after it is encrypted!!!\n"
        echo -e "You want root \"/\" or \"./\", \"$(basename $0)\" to be deleted right?"
        exit
fi

SP=$(echo $2 |sed 's:/*$::')

[[ "$1" == ""  || "$1" == '-h' ]] &&
        echo -e "\nSpecify \"-e\" for encrypt or \"-d\" for Decrypt or \"-h\" for help\n" &&
        echo -e "To encrypt files:" &&
        echo -e "Usage: "enc_tool.sh" -e unencrypted_file destination_directory" &&
        echo -e "\nYou can specify several files to be encrypted divided by space, tool will automatically recognize it." &&
        echo -e "Usage: "enc_tool.sh" -e unencrypted_file1 file2 file3 file4 ...\n" &&
        echo -e "To decrypt files:" &&
        echo -e "enc_tool.sh -d encrypted_file.enc\n" &&
        exit

if [[ "$1" != '-e' && "$1" != '-d' && "$1" != '-h' ]]
        then
        echo -e "\nOnly \"-e\" \"-d\" \"-h\" argumets accepted\n"
        exit
fi


if [[ "$SP" == '/' || "$SP" == './' || "$SP" == "$(basename $0)" || "$SP" == '*' || "$SP" == '/' || "$SP" == '@' || "$SP" == '-' || "$SP" == '\' || "$SP" == '.' || "$SP" == '#' ]]
        then
        echo -e "\nYou cannot specify \"/\" or \"./\" spacial characters and script itself because orginal file/dir will be deleted after it is encrypted!!!\n"
        echo -e "You want root \"/\" or \"./\", \"$(basename $0)\" to be deleted right?"
        exit
fi

#if [[ "$SP" == '' ]]
#        then
#        echo -e "\nPlease specify what you want to encrypt"
#        exit
#fi

complx="ODM2NDI0MzExZjNhMDA3NzU0NmFmYjM5OGI5MjU3NTRlOThlZjIwMmY4NTMyMjM4ODcxMDk1NTc3_OWFiMmMzNyAgLQo="
Pwd () {
echo -en "\nPassword:"
read -s passwd
echo -e "\n"
}
pWD=$complx$(echo "$passwd$passwd" | sha512sum | cut -d'-' -f1 | tr -d " ")
Pwd=$(echo "$pWD" | rev)
if [[ "$1" == "-e" ]]
        then
                if [[ "$SP" == "" ]]
                then  echo "Please provide file to ENcrypt..."
                exit
                fi

                if [[ "$SP" =~ ".enc" ]]
                        then
                        echo -e "\nFile already contain .enc extension! Please check if is it already encrypted!\n"
                        exit
                fi


                if [[ ! -a "$SP" ]]
                        then
                        echo -e "\nFile doesn't exist, please check the path and existance of the file!\n"
                        exit
                fi

                if [[ -s "$SP".enc ]]
                        then
                        echo -e "\nFile with "$SP.enc" name exists and if it is already encrypted!\n"
                        exit
                fi

                if [[ "$#" -gt "2" ]]
                        then
                        echo -e "\nYou specified more that 1 file to be encrypted.\n"
                        echo -e "$(echo $@ | sed 's/-e//g')"
                        echo -e "\nPlease spefy their common name: "
                        read Cname
                        Pwd;pWD=$complx$(echo "$passwd$passwd" | sha512sum | cut -d'-' -f1 | tr -d " ")
                        tar -cvf - $(echo $@ | sed 's/-e//g') | gpg --batch --yes --passphrase $pWD --output "$Cname".gpg --cipher-algo AES256 --force-mdc -c
                        openssl enc -aes-256-cbc -salt -in "$Cname".gpg -out "$Cname.enc" -pass pass:^$Pwd && rm -fr $(echo $@ | sed 's/-e//g') "$Cname".gpg

                else
                Pwd;pWD=$complx$(echo "$passwd$passwd" | sha512sum | cut -d'-' -f1 | tr -d " ")
                tar -cvf - "$SP" | gpg --batch --yes --passphrase $pWD --output "$SP".gpg --cipher-algo AES256 --force-mdc -c
                #Here is copying for safety, after you encrypt and decrypt once  you check your data is OK then comment this thing here and remove copied version of the file.
                #cp "$SP" "$SP_orig"
                openssl enc -aes-256-cbc -salt -in "$SP".gpg -out "$SP.enc" -pass pass:^$Pwd && rm -fr "$SP" "$SP".gpg &&
                echo -e "\nData have been packed to a tar ball and encrypted sucessfully!\n"
                fi
fi

if [[ "$1" == '-d' ]]
        then
                if [[ "$SP" ==  "" ]]
                then  echo "Please provide file to DEcrypt..."
                exit
                fi

                if [[ ! -a "$SP" ]]
                        then
                        echo -e "\nFile doesn't exist, please check the path and existance of the file!\n"
                        exit
                fi


                if [[ -s $(echo "$SP"  | rev | cut -d'.' -f2- | rev) ]]
                        then
                        echo -e "\nFile with \"$(echo "$SP" | rev | cut -d'.' -f2- | rev)\" name already exists, please check if that file is original, Not going to overwrite!\n"
                        exit
                fi
                Pwd;pWD=$complx$(echo "$passwd$passwd" | sha512sum | cut -d'-' -f1 | tr -d " ")
                openssl enc -d -aes-256-cbc -in "$SP" -out $(echo "$SP" | rev | cut -d'.' -f2- | rev).gpg -pass pass:^$Pwd
                #gpg --batch --yes --passphrase $passwd --output "$(echo "$SP"  | rev | cut -d'.' -f2- | rev)" --decrypt "$(echo "$SP"  | rev | cut -d'.' -f2- | rev)".gpg | tar -xvf -
                gpg --batch --yes --passphrase $pWD --decrypt "$(echo "$SP" | rev | cut -d'.' -f2- | rev)".gpg | tar -xvf - && rm -fr "$SP" $(echo "$SP" | rev | cut -d'.' -f2- | rev).gpg &&
                echo -e "\nData have been decrypted sucessfully!\n"

fi
