#!/usr/bin/env tclsh
##
## statusbot
## - send encrypted emails as 'status reminder'
##
## (c) Ben Fuhrmannek <bef@pentaphase.de>
##

package require Tcl 8.5
package require cmdline

if {[info commands try] eq ""} {
	package require try
}

## command line options

set options {
	{cmd.arg "send" "command"}
	{group.arg "test" "send to group"}
	{subject.arg "hello" "email subject"}
	{stdin "read email body from stdin"}
	{url.arg "" "download email body from URL"}
	{mustchange.arg "" "checksum file. email will only be sent if data changed"}
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


## prepare tclgpg
if {![info exists ::env(GPG_AGENT_INFO)]} {
	# puts [exec gpg-connect-agent "GETINFO socket_name" "GETINFO pid" /bye]
	set ::env(GPG_AGENT_INFO) "foo"
}

## load libs
lappend auto_path $params(libdir)
foreach i {config get_http gpg_encrypt email} { source "${params(libdir)}/$i.tcl" }

## read config
read_config $params(inidir)

## execute cmd
switch $params(cmd) {
	send {
		if {!$params(stdin) && $params(url) eq ""} { puts "no body?"; exit 1 }

		if {$params(url) ne ""} {
			set data [get_data $params(url)]
		} elseif {$params(stdin)} {
			set data [read stdin]
		}
		if {$data eq ""} { puts "empty data."; exit 2 }

		if {$params(mustchange) ne ""} {
			package require fileutil
			package require md5

			set md5_new [::md5::md5 -hex $data]
			if {[file exists $params(mustchange)]} {
				set md5_prev [::fileutil::cat $params(mustchange)]
				if {$md5_new eq $md5_prev} { exit 0 }
			}
			::fileutil::writeFile $params(mustchange) $md5_new
		}

		send_smtp_encrypted -group $params(group) -subject $params(subject) -body $data
	}
	default {
		puts "unknown cmd. try '$argv0 -cmd send ...'"
		exit 1
	}
}

