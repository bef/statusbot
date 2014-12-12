package require mime
package require smtp
package require tls
package require cmdline


proc send_smtp_encrypted {args} {
	array set p $args
	
	set token [mime::initialize -canonical "text/plain; charset=utf-8" -string $p(-body)]
	set mimemsg [mime::buildmessage $token]
	mime::finalize $token
	
	set gpg_recipients [dict get $::cfg(groups) $p(-group) gpgkeys]
	set encrypted [gpg_encrypt $gpg_recipients $mimemsg]

	##
	
	set smtp_recipients [dict get $::cfg(groups) $p(-group) recipients]
	set smtp_recipients [join $smtp_recipients ", "]
	
	array set cfg $::cfg(email)

	set token1 [mime::initialize -canonical application/pgp-encrypted -string "Version: 1"]
	::mime::setheader $token1 "Content-Description" "PGP/MIME Versions Identification"

	set token2 [mime::initialize -canonical "application/octet-stream; name=encrypted.asc" -string $encrypted]
	::mime::setheader $token2 "Content-Description" "OpenPGP encrypted message"
	::mime::setheader $token2 "Content-Disposition" "inline; filename=encrypted.asc"


	set token [mime::initialize -canonical multipart/encrypted -parts [list $token1 $token2]]
	::mime::setheader $token "Subject" $p(-subject)
	# ::mime::setheader $token "From" $cfg(from)
	::mime::setheader $token "To" $smtp_recipients
	::mime::setheader $token "Date" "[clock format [clock seconds]]"
	# puts [::mime::buildmessage $token]; return
	::smtp::sendmessage $token \
		-recipients $smtp_recipients \
		-servers [list $cfg(server)] \
		-usetls 1 \
		-username $cfg(username) \
		-password $cfg(password) \
		-originator $cfg(from) \
		-debug 0
}