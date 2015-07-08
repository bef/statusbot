package require inifile

proc read_config {etc} {
	global cfg
	
	set ini [::ini::open "$etc/email.ini" r]
	set cfg(email) [::ini::get $ini email]
	::ini::close $ini
	
	set ini [::ini::open "$etc/groups.ini" r]
	set cfg(groups) {}
	foreach sec [::ini::sections $ini] {
		 lappend cfg(groups) $sec [::ini::get $ini $sec]
	}
	::ini::close $ini
}

