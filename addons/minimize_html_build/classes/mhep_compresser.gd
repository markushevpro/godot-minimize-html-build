class_name MHEPCompresser

var _compressers: Array
var _copier: MHEPCopier
var _info: MHEPExportInfo
var _utils: MHEPUtils


static func compress( copier: MHEPCopier ):
	MHEPCompresser.new( copier )


func _init( copier: MHEPCopier ):
	_copier = copier
	_info = copier.info
	_utils = MHEPUtils.new( _info )
	_compressers = _get_OS_files()
	
	_debug( "- host system: " + _utils.os + "(" + _utils.arch + " arch)" )
	_debug( "- compresser file: " + _compressers[0] )
	
	if not _info.patch:
		_debug( "- minifier file: " + _compressers[1] )
	
	_compress()


static func _debug( text: String ):
	MHEPUtils.debug( "COMPRESS", text )


func _compress():
	if _compressers != null:
		_copy_compressers()
		_compress_big_files()
			
		if not _info.patch:
			_process_file( _minify, _info.name + ".html" )
			_process_file( _minify, _info.name + ".js" )
		
		_remove_compressers()
	else:
		MHEPUtils.warn( "Compresser executable is not defined. Skipping" )


func _compress_big_files():
	if _info.patch:
		_process_file( _convert_to_gzip, _info.name + "." + _info.patch_ext )
	else:
		var gzip_files = _utils.get_files( 'pck' )
		gzip_files.append_array( _utils.get_files( 'wasm' ))
		
		for file in gzip_files:
			_process_file( _convert_to_gzip, file )


func _copy_compressers():
	for filename in _compressers:
		_copier.copy_from_bin( filename )
		
		if _utils.os == _utils.OS_LINUX or _utils.os == _utils.OS_MACOS:
			_process_cmd_linux([ "chmod +x " + filename ])
			_debug("Permissions for " + filename + " is " + str(FileAccess.get_unix_permissions( _info.in_target_dir( filename ) )))


func _remove_compressers():
	for filename in _compressers:
		_info.target_dir.remove( filename )
		
	_debug( "Build directory cleaned" )


func _get_OS_files() -> Array:
	match _utils.os:
		_utils.OS_WINDOWS:
			return [ "compress.exe", "minify.exe" ]
		_utils.OS_LINUX:
			return [ "compress_linux", "minify_linux" ]
		_utils.OS_MACOS:
			if _utils.arch == "arm":
				return [ "compress_mac_arm", "minify_mac_arm" ]
			else:
				return [ "compress_mac_x64", "minify_mac_x64" ]
		_:
			# TODO: Different OS compression script
			MHEPUtils.warn( "Compression is not implemented yet for host OS " + _utils.os )
			return []


func _process_file( compresser: Callable, filename: String ):
	if _compressers != null:
		var original_size = _utils.get_file_size( filename )
		
		compresser.call( filename )
		
		var new_size = _utils.get_file_size( filename + "_" )

		if new_size <= original_size:
			_info.target_dir.remove( filename )
			_info.target_dir.rename( filename + "_", filename )
			
			var diff = original_size - new_size
			
			_debug( 
					filename + 
					" converted:" + 
					" from " + MHEPUtils.string_size( original_size ) + 
					" to " + MHEPUtils.string_size( new_size ) +
					" (saved " + MHEPUtils.string_size( diff ) + ")"
			)
		else:
			_info.target_dir.remove( filename + "_" )
			
			_debug(
				"The compressed version of the file \"" +
				filename +
				"\" is larger then the original. Rolling back."
			)


func _convert_to_gzip( filename: String ):
	var base = "%s \"" + filename + "\""
	
	match _utils.os:
		_utils.OS_WINDOWS:
			_process_cmd_win([ base % "compress.exe" ])
		_utils.OS_LINUX:
			_process_cmd_linux([ base % "./compress_linux" ])
		_utils.OS_MACOS:
			if _utils.arch == "arm":
				_process_cmd_mac([ base % "./compress_mac_arm" ])
			else:
				_process_cmd_mac([ base % "./compress_mac_x64"])
		_:
			# TODO: Different OS compression script
			MHEPUtils.warn( "Compression is not implemented yet for host OS " + _utils.os )


func _minify( filename ):
	var type = filename.split(".")[-1]
	
	match type:
		"html":
			_minify_html( filename )
			
		"js":
			_minify_js( filename )
			
		_:
			MHEPUtils.warn( "Unknown file type: " + type )


func _minify_html( filename ):
	var base = "%s -o \"" + filename + "_\" \"" + filename + "\""
	
	match _utils.os:
		_utils.OS_WINDOWS:
			_process_cmd_win([ base % "minify.exe" ])
		_utils.OS_LINUX:
			_process_cmd_linux([ base % "./minify_linux" ])
		_utils.OS_MACOS:
			if _utils.arch == "arm":
				_process_cmd_mac([ base % "./minify_mac_arm" ])
			else:
				_process_cmd_mac([ base % "./minify_mac_x64"])
		_:
			# TODO: Different OS minifying scripts
			MHEPUtils.warn( "Minifying is not implemented yet for host OS " + _utils.os )


func _minify_js( filename ):
	var base = "%s -o \"" + filename + "_\" \"" + filename + "\" --js-keep-var-names --js-precision 0"
	
	match _utils.os:
		_utils.OS_WINDOWS:
			_process_cmd_win([ base % "minify.exe" ])
		_utils.OS_LINUX:
			_process_cmd_linux([ base % "./minify_linux" ])
		_utils.OS_MACOS:
			if _utils.arch == "arm":
				_process_cmd_mac([ base % "./minify_mac_arm" ])
			else:
				_process_cmd_mac([ base % "./minify_mac_x64"])
		_:
			# TODO: Different OS minifying scripts
			MHEPUtils.warn( "Minifying is not implemented yet for host OS " + _utils.os )


func _process_cmd_win( commands ):
	var path = _info.target_dir.get_current_dir()
	var actions = commands
	var out = []
	
	actions.push_front( "cd \"" + path + "\"" )
	
	# Target is on another drive
	if ":" in path:
		actions.push_front( path.split(":")[0] + ":" )
	
	var res = OS.execute( 
			"CMD.exe", 
			[ "/C", " && ".join( actions ) ],
			out,
			true
	)
	
	if res != 0:
		_utils.debug( "^", "(last process finished with code " + str(res) + ")")
		_utils.debug( "", "Process output: \n\n" + "\n".join( out ))


func _process_cmd_mac( commands ):
	var path = _info.target_dir.get_current_dir()
	var actions = commands
	var out = []
	
	actions.push_front( "cd '" + path + "'" )
	
	var res = OS.execute( 
			"/bin/zsh", 
			[ "-c", " && ".join( actions ) ],
			out,
			true
	)
	
	if res != 0:
		_utils.debug( "^", "(last process finished with code " + str(res) + ")")
		_utils.debug( "", "Process output: \n\n" + "\n".join( out ))
	

func _process_cmd_linux( commands ):
	var path = _info.target_dir.get_current_dir()
	var actions = commands
	var out = []
	
	actions.push_front( "cd '" + path + "'" )
	
	var res = OS.execute( 
			"/bin/bash", 
			[ "-c", " && ".join( actions ) ],
			out,
			true
	)
	
	if res != 0:
		_utils.debug( "^", "(last process finished with code " + str(res) + ")")
		_utils.debug( "", "Process output: \n\n" + "\n".join( out ))
