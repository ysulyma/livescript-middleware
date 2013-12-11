# LiveScript
is a language which compiles to JavaScript. It has a straightforward mapping to JavaScript and allows you to write expressive code devoid of repetitive boilerplate. While LiveScript adds many features to assist in functional style programming, it also has many improvements for object oriented and imperative programming.

Check out **[livescript.net](http://livescript.net)** for more information, examples, usage, and a language reference.

### Middleware Usage
    require! {
      express
      livescript-middleware: \livescript-middleware
    }
    /* ... */
    app = express!
    app.use "/js", livescript-middleware do
      src: "#{__dirname}/public/ls"
      dest: "#{__dirname}/public/js"

### Source
[git://github.com/yuri0/livescript-middleware.git](git://github.com/yuri0/livescript-middleware.git)
