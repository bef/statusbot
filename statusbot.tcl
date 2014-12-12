#!/usr/bin/env tclsh
##
## statusbot
## - send encrypted emails as 'status reminder'
##
## (c) Ben Fuhrmannek <bef@pentaphase.de>
##

package require Tcl 8.5
package require cmdline

## command line options

set options {
	{group.arg "test" "send to group"}
	{subject.arg "hello" "email subject"}
	{stdin "read email body from stdin"}
	{url.arg "" "download email body from URL"}
}

set here [file dirname [info script]]
lappend options [list inidir.arg "$here/etc" "config directory"]
lappend options [list libdir.arg "$here/lib" "library directory"]
set usage "$argv0 <send> ..."
try {
	array set params [::cmdline::getoptions argv $options $usage]
} on error {result} {
	puts $result
	exit 1
}


##

lappend auto_path $params(libdir)
foreach i {config get_http gpg_encrypt email} { source "${params(libdir)}/$i.tcl" }

read_config $params(inidir)

switch $argv {
	send {
		if {!$params(stdin) && $params(url) eq ""} { puts "no body?"; exit 1 }

		if {$params(url) ne ""} {
			set data [get_data $params(url)]
		} elseif {$params(stdin)} {
			set data [read stdin]
		}
		if {$data eq ""} { puts "empty data."; exit 2 }

		send_smtp_encrypted -group $params(group) -subject $params(subject) -body $data
	}
	default {
		puts "unknown cmd. try '$argv0 send ...'"
		exit 1
	}
}

