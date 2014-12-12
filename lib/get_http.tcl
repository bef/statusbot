package require Tcl 8.5
package require http
package require tls
::http::register https 443 ::tls::socket

proc get_data {url} {
	set h [::http::geturl $url]

	upvar #0 $h state

	if {$state(status) eq "ok"} {
		set result $state(body)
	} else {
		puts "problem."
		set result ""
	}

	::http::cleanup $h
	return $result
}
