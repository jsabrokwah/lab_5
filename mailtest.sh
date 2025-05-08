#!/usr/bin/bash

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

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <recipient_email> <subject> <body>"
    exit 1
fi
    recipient="$1"
    subject="$2"
    body="$3"

    # Check if mail command is available
    if ! command -v mail &> /dev/null; then
        echo "Error: mail command not found. Please install mailutils."
        exit 1
    fi

    # Send email
    sendMyMail "$recipient" "$subject" "$body"
