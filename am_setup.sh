#!/usr/bin/env bash


# Check if input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_users.txt> or $0 <path_to_users.csv>"
    exit 1
fi

INPUT_FILE="$1"

# Validate file
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi

if [ ! -r "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' is not readable!"
    exit 1
fi

if [ ! -s "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' is empty!"
    exit 1
fi

# Setup log and credentials file
LOG_FILE="iam_setup.log"
CREDS_FILE="created_users_passwords.txt"
exec >> "$LOG_FILE" 2>&1

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*"
}

sendMyMail() {
    sender="cars.rentexapp@gmail.com"
    receiver="$1"
    subject="$2"
    body="$3"
    gapp="swiamrgdciebxkua"

    curl -s --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
    --mail-from $sender \
    --mail-rcpt $receiver\
    --user $sender:$gapp \
     -T <(echo -e "From: ${sender}
To: ${receiver}
Subject:${subject}

 ${body}")
}

log "===== IAM Setup Script Started ====="

# Skip header and process users
tail -n +2 "$INPUT_FILE" | while IFS=',' read -r username fullname groupname email; do
    TEMP_PASS="Temp$(date +%s | sha256sum | base64 | head -c 8)"

    # Check password complexity (at least 1 upper, 1 lower, 1 digit)
    if ! [[ "$TEMP_PASS" =~ [A-Z] && "$TEMP_PASS" =~ [a-z] && "$TEMP_PASS" =~ [0-9] ]]; then
        TEMP_PASS="Ch@ngeM3$(date +%s | cut -c9-10)"
        log "Generated fallback complex password for $username"
    fi

    log "----------------------------------------"
    log "Processing user: $username"

    # Create group if it doesn't exist
    if ! getent group "$groupname" > /dev/null; then
        log "Creating group: $groupname"
        sudo groupadd "$groupname"
    else
        log "Group $groupname already exists"
    fi

    # Create user if not exists
    if ! id "$username" > /dev/null 2>&1; then
        log "Creating user: $username ($fullname) in group $groupname"
        sudo useradd -m -g "$groupname" -c "$fullname" "$username"

        echo "$username:$TEMP_PASS" | sudo chpasswd
        log "Set temporary password for $username"

        sudo chage -d 0 "$username"
        log "Password will be changed at first login"

        sudo chmod 700 "/home/$username"
        log "Set /home/$username permissions to 700"

        WELCOME_MSG="/home/$username/WELCOME.txt"
        echo "Hello $fullname,

Your Linux account has been created.

Username: $username  
Temporary Password: $TEMP_PASS  

Please change your password upon login.

Thank you." | sudo tee "$WELCOME_MSG" > /dev/null

        sudo chown "$username:$groupname" "$WELCOME_MSG"
        sudo chmod 600 "$WELCOME_MSG"

        echo "$username,$fullname,$TEMP_PASS" >> "$CREDS_FILE"

        email_body="Hello $fullname,

Your account has been created.

Username: $username
Temporary Password: $TEMP_PASS

Please change your password upon login.

Regards,
SysAdmin Team"

        # Send email notification
        log "Sending email to $email"
        sendMyMail $email "User Account Created" "$email_body"
        
    else
        log "User $username already exists. Skipping."
    fi
done

chmod 600 "$CREDS_FILE"
log "IAM setup script completed successfully."
