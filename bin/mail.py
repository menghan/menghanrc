#!/usr/bin/env python
# coding=utf-8

''' `mail' like gmail smtp client, run it with '-h' for usage '''

import os
import sys
import smtplib
import optparse
import unittest
import mimetypes
from email import encoders
from email.message import Message
from email.mime.audio import MIMEAudio
from email.mime.base import MIMEBase
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from cStringIO import StringIO


def parse_option(args=None):
    parser = optparse.OptionParser()
    parser.add_option('-s', '--subject', dest='subject',
                      help='subject of the mail')
    parser.add_option('-u', '--username', dest='username',
                      help='send mail through gmail as')
    parser.add_option('-p', '--password', dest='password',
                      help='password to login info gmail account')
    parser.add_option('-x', '--xhtml_body', dest='xhtml_body',
                      help='the html body of the message')
    parser.add_option('-a', '--attach', dest='attaches', action='append',
                      help='attachment to send')
    parser.add_option('-b', '--bcc', dest='bcc', action='append',
                      help='send blind carbon copies to list of users')
    parser.add_option('-c', '--cc', dest='cc', action='append',
                      help='send carbon copies to list of users')
    (options, arguments) = parser.parse_args(args)
    return options, arguments


def gmail_sendmail(from_address, password,
                   to_addresses, cc_addresses, bcc_addresses,
                   subject, text_body='', xhtml_body=None, attachments=None):
    gmail_account = from_address
    if attachments == None:
        attachments = []
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.ehlo()
    server.starttls()
    server.ehlo()
    server.login(gmail_account, password)
    outer = MIMEMultipart('mixed')
    outer['Subject'] = subject
    outer['To'] = ', '.join(to_addresses)
    if cc_addresses is not None:
        outer['Cc'] = ', '.join(cc_addresses)
    else:
        cc_addresses = []
    if bcc_addresses is None:
        bcc_addresses = []
    outer['From'] = from_address

    for att in attachments:
        if sys.platform == 'win32':
            if att[1] != ':':
                # relative path
                path = os.path.join(os.getcwd(), att)
            else:
                path = att
        elif sys.platform.startswith('linux') or \
                sys.platform in ('darwin', 'cygwin'):
            if att[0] != '/':
                # relative path
                path = os.path.join(os.getcwd(), att)
            else:
                path = att
        else:
            raise ValueError('what os is it?!')
        # Guess the content type based on the file's extension.  Encoding
        # will be ignored, although we should check for simple things like
        # gzip'd or compressed files.
        ctype, encoding = mimetypes.guess_type(path)
        if ctype is None or encoding is not None:
            # No guess could be made, or the file is encoded (compressed), so
            # use a generic bag-of-bits type.
            ctype = 'application/octet-stream'
        maintype, subtype = ctype.split('/', 1)
        if maintype == 'text':
            fp = open(path, 'rb')
            # Note: we should handle calculating the charset
            msg = MIMEText(fp.read(), _subtype=subtype)
            fp.close()
        elif maintype == 'image':
            fp = open(path, 'rb')
            msg = MIMEImage(fp.read(), _subtype=subtype)
            fp.close()
        elif maintype == 'audio':
            fp = open(path, 'rb')
            msg = MIMEAudio(fp.read(), _subtype=subtype)
            fp.close()
        else:
            fp = open(path, 'rb')
            msg = MIMEBase(maintype, subtype)
            msg.set_payload(fp.read())
            fp.close()
            # Encode the payload using Base64
            encoders.encode_base64(msg)
        # Set the filename parameter
        msg.add_header('Content-Disposition', 'attachment',
                       filename=os.path.basename(path))
        outer.attach(msg)

    if xhtml_body is not None:
        html_content = MIMEText(xhtml_body, 'html')
        outer.attach(html_content)
    else:
        text_content = MIMEText(text_body, 'plain')
        outer.attach(text_content)

    server.sendmail(gmail_account,
                    to_addresses + cc_addresses + bcc_addresses,
                    outer.as_string())
    server.close()


def main():
    options, arguments = parse_option()
    text_body = StringIO()
    if options.xhtml_body:
        xhtml_body = StringIO()
        with open(options.xhtml_body) as f:
            xhtml_body.write(f.read())
    else:
        xhtml_body = None
        for line in sys.stdin:
            text_body.write(line)
    gmail_sendmail(from_address=options.username,
                   password=options.password,
                   to_addresses=arguments,
                   cc_addresses=options.cc,
                   bcc_addresses=options.bcc,
                   subject=options.subject,
                   text_body=text_body.getvalue(),
                   xhtml_body=(xhtml_body.getvalue() if xhtml_body else None),
                   attachments=options.attaches)


if __name__ == '__main__':
    main()
