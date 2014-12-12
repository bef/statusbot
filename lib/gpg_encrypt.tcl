package require gpg

proc gpg_encrypt {recipientlist data} {
	set gpg [::gpg::new]
	$gpg set -property armor -value 1
	$gpg set -property encoding -value utf-8
	set r [::gpg::recipient]

	set result ""
	foreach recipient $recipientlist {
		$r add -name $recipient -validity full
	}
	if {[catch {
		set result [$gpg encrypt -input $data -recipients $r]
	} err]} {
		puts "ERROR: $err"
	}

	$gpg free
	$r free
	
	return $result
}

