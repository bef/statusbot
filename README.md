# statusbot.

## About

The status bot sends GPG encrypted emails to a group of recipients. Email contents may be downloaded via HTTP before.

Simply put, the statusbot is roughly equivalent to a command line such as

    $ wget -O - URL |gpg --encrypt ... |sendmail ...

In combination with a crontab entry and a web-based Todo-List, Wiki page or even a text file the statusbot can become a daily reminder of important information securely delivered right to your inbox.

## Installation

Required packages:

* Tcl 8.5 or above
* Tcllib >= 1.13
* GnuPG v1
* [http://tclgpg.googlecode.com/](tclgpg) (either install globally or in lib/)

The autoloader path of your Tcl installation - if needed - can be found like this:

    echo 'puts $auto_path' |tclsh

## License

Simplified BSD. See LICENSE file.
