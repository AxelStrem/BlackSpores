extends StaticBody3D

signal ext_lock

func lock_extended():
	ext_lock.emit()
	
