class_name MHEPJS


static func fix( info: MHEPExportInfo ):
	_fix_main_js( info )
	_fix_worker_js( info )


static func _debug( text: String ):
	MHEPUtils.debug( "JS", text )


static func _fix_worker_js( info: MHEPExportInfo ):
	var path = info.in_target_dir( info.name + ".service.worker.js" )
	
	if ( FileAccess.file_exists( path )):
		_debug( "Found service worker" )
		
		var content = _get_content( path )
		var fixed = content
		
		var regex = RegEx.create_from_string( "const CACHED_FILES *= *\\[.+\\]" )
		var found = regex.search( fixed )
		
		if found:
			var orig_str = found.strings[0]
			var fixed_str = found.strings[0].replacen( "]", ",\"pako_inflate.min.js\"]" )
			
			fixed = fixed.replacen( orig_str, fixed_str )
			
			if fixed != content:
				_save_content( path, fixed )
				_debug( "Successfully fixed Service Worker" )
				return
				
		_debug( "Service Worker is NOT fixed. PWA may not work as expected" )


static func _fix_main_js( info: MHEPExportInfo ):
	var path = info.in_target_dir( info.name + ".js" )
	var content = _get_content( path )
	
	_save_content( path, _replace_by_version( content ))


static func _get_content( path: String ) -> String:
	var file = FileAccess.open( path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	return content


static func _save_content( path: String, content: String ):
	var modified = FileAccess.open( path, FileAccess.WRITE)
	
	modified.store_string(content)
	modified.close()


static func _replace_by_version ( content: String ) -> String:
	var version = Engine.get_version_info()

	#TODO: Different versions replacements
	if version.major == 4:
		return _replace_v4_x( content )
		
	# No replacements
	return content


# Tested versions: 4.1 - 4.4
static func _replace_v4_x( content: String ) -> String:
	var fixed = content
	
	# Fix minifying bug
	fixed = fixed.replacen(
			":+num",
			":Number(num)"
	)
	
	# Fix minifying bug for threads
	fixed = fixed.replacen(
			"MAX_SAFE_INTEGER?+heap_value",
			"MAX_SAFE_INTEGER?Number(heap_value)"
	)
	
	# Fix loadFetch
	# 1.0.1 - fix gzip server response
	fixed = fixed.replacen(
			"const tr=getTrackedResponse(response,tracker[file]);return raw?Promise.resolve(tr):tr.arrayBuffer()}", 
			"const tr=getTrackedResponse(response,tracker[file]);return Promise.resolve(tr.arrayBuffer().then(buffer=>{try{return new Response(pako.inflate(buffer))}catch(e){return new Response(buffer)}}))}"
	)
		
	# Fix preload
	fixed = fixed.replacen(
			"me.preloadedFiles.push({path:destPath||pathOrBuffer,buffer:buf}),",
			"buf.arrayBuffer().then(buffer=>me.preloadedFiles.push({path:destPath||pathOrBuffer,buffer})),"
	)
	
	if fixed != content:
		_debug( "Successfully fixed JS" )
	else:
		_debug( "JS is NOT fixed. Build may not work as expected" )
		
	return fixed
