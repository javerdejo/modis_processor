#!/usr/bin/env python
"""
Sends a email.

Author: Javier Arellano-Vertdejo (J@Vo)
Date: October 2018
Version: v1.311.18
"""
import argparse
import smtplib
import sys

from email.mime.multipart import MIMEMultipart
from email.MIMEText import MIMEText


# sender parameters
SMTP_SERVER = 'smtp-mail.outlook.com'
SMTP_PORT = 587
SMTP_SENDER = 'akbal.ecosur@outlook.com'
SMTP_PASSWORD = "a1k2b3a4l5"


def sendMail(mail_subject, mail_to, mail_message):
    """
    Send a email message.

    @params:
        mail_subject    - Required  : subject of mail
        mail_to         - Required  : dest of mail
        mail_message    - Required  : message of mail
    """
    msg = MIMEMultipart()
    msg['Subject'] = mail_subject
    msg['To'] = mail_to
    msg['From'] = SMTP_SENDER

    part = MIMEText('text', "plain")
    part.set_payload(mail_message)
    msg.attach(part)

    # sets parameters to send email
    session = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
    session.ehlo()
    session.starttls()
    session.ehlo

    # login using sender parameters
    session.login(SMTP_SENDER, SMTP_PASSWORD)
    qwertyuiop = msg.as_string()

    # sends email
    session.sendmail(SMTP_SENDER, mail_to, qwertyuiop)

    # close session
    session.quit()


def main(argv):
    """
    Call the process function with the parameter list.

    @params:
        argv    - Required  : command line argument list (List)
    """
    ap = argparse.ArgumentParser()

    ap.add_argument("-s", "--subject", required=True,
                    help="subject of mail")
    ap.add_argument("-t", "--to", required=True,
                    help="dest")
    ap.add_argument("-m", "--message", required=True,
                    help="message of mail")

    args = vars(ap.parse_args())

    mail_subject = args['subject']
    mail_to = args['to']
    mail_message = args['message']

    # send the email
    sendMail(mail_subject, mail_to, mail_message)


if __name__ == '__main__':
    """
    Use example.

    sendmail.py -s "subject" -t "javier.arellano@mail.ecosur.mx" -m "message"
    """
    main(sys.argv[1:])
