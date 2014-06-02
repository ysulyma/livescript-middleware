/*
 * Livescript middleware
 * copied from Stylus middleware
 */

/**
 * Module dependencies.
 */
require! {
  livescript: \LiveScript
  
  fs
  url
  path.basename
  path.dirname
  mkdirp
  path.join
  path.sep

  UglifyJS: \uglify-js
}

const defaults =
  compress: false

module.exports = (options = {}) ->
  # Accept src/dest dir
  if typeof options == \string
    options = src: options
    
  # defaults
  options = defaults <<< options
    
  # extract options
  {dest, src} = options
  
  # Source dir required
  throw new Error 'livescript.middleware() requires "src" directory' unless src?

  # Default dest dir to source
  dest ||= src
  
  # Default compile callback
  options.compile ||= (str, path) ->
    livescript.compile str, options{bare}
  
  # Middleware
  return (req, res, next) ->
    return next! unless array-contains <[ GET HEAD ]> req.method
    
    path = url.parse req.url .pathname
    
    return next! unless /\.js$/.test path
    
    if array-contains <[ string function ]> typeof dest
      # check for dest-path overlap
      overlap = compare do
        if typeof dest == \function then dest path else dest
        path

      path = path.slice overlap.length
      
    js-path = if typeof dest == \function then dest path else join dest, path
    ls-path = if typeof src == \function then src path else join src, path.replace \.js \.ls
    
    # Ignore ENOENT to fall through as 404
    error = (err) ->
      next if err.code == \ENOENT then null else err

    # force
    return compile! if options.force
    
    # Compare mtimes
    fs.stat ls-path, (err, ls-stats) ->
      return error err if err
      
      fs.stat js-path, (err, js-stats) ->
        # JS has not been compiled, compile it!
        if err
          if err.code == \ENOENT then compile! else next err
        else
          # Source has changed, compile it
          if ls-stats.mtime > js-stats.mtime
            compile!
          else
            next!

    # compile to jsPath
    function compile
      fs.read-file ls-path, \utf8, (err, str) ->
        return error err if err
        
        try
          js = options.compile str, {}
          
          if options.compress
            js = UglifyJS.minify js, {+from-string} .code
          
          mkdirp dirname(js-path), 8~700, (err) ->
            return error err if err
            fs.write-file js-path, js, \utf8, next
        catch err
          error err

function array-contains (haystack, needle)
  -1 != haystack.index-of needle

/**
 * get the overlapping path from the end of path A, and the begining of path B.
 *
 * @param {String} pathA
 * @param {String} pathB
 * @return {String}
 * @api private
 */
function compare(pathA, pathB)
  pathA .= split sep
  pathB .= split sep
  overlap = []
  while pathA[* - 1] == pathB[0]
    overlap.push pathA.pop!
    pathB.shift!

  overlap.join sep
