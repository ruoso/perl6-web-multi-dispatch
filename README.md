# Perl6 Web Dispatching with simple multi dispatch

This repository has a little experiment on building a web application
dispatching based only on multi pattern matching.

The basic principle is:

 * Break the path into tokens
 * Append the request object to the end (so you can match request method)
 * call the dispatch multi

## How do you implement an action?

 * Match only the immediate parameters you are grabbing, slurp the rest
 * Create a context object
 * recurse into the same multi sending the context object and the remaining arguments.

```
multi dispatch( 'foo', Int(StrToInt) $foo_id, *@remaining ) is export {
    dispatch(TestApp::Context::Foo.new(:foo_id($foo_id)), |@remaining);
}

multi dispatch( TestApp::Context::Foo $c, HTTP::Request $req ) is export {
    $*res.status = 200;
    $*res.close("Final request in the chain for foo " ~ $c.foo_id);
}
```

## How do I chain different things

 * Receive the context object from the different type
 * rinse and repeat

```
multi dispatch( TestApp::Context::Foo $c,
                'bar', Int(TestApp::Types::StrToInt) $bar_id,
                *@remaining ) is export {
  dispatch(TestApp::Context::Bar.new(:foocontext($c),
                                     :bar_id($bar_id)), |@remaining);
}
multi dispatch( TestApp::Context::Bar $c, HTTP::Request $req ) is export {
  $*res.status = 200;
  $*res.close("Final action in the chain for foo " ~ $c.foocontext.foo_id ~
    " bar " ~ $c.bar_id);
}
```

## How do I anchor the end of the request path?

 * Match the request and response objects

```
multi dispatch( HTTP::Request $req ) is export {
  $*res.status = 200;
  $*res.close("Final request in the chain on the root context");
}
```

## How do I handle different types of request methods?

 * Create a subset type to describe the match
 * remember that when more than one subset matches, the first one wins, so do the more specific cases first.
 * remember to add a generic version in the end that returns error 405 to handle an unsupported request method

```
subset GET of HTTP::Request where { .method eq 'GET' };
multi dispatch( TestApp::Context::Bar $c, GET $req ) is export {
  $*c.res.status = 200;
  $*c.res.close("Final action in the chain for foo " ~ $c.foocontext.foo_id ~
    " bar " ~ $c.bar_id);
}

multi dispatch( TestApp::Context::Bar $c, HTTP::Request $req ) is export {
  $*c.res.status = 405;
  $*c.res.close("method not allowed: foo " ~ $c.foocontext.foo_id ~
    " bar " ~ $c.bar_id);
}
```

## How do I get a link to an action?

 * Because the action dispatching is done by the language itself via
   recursion, there's not enough meta-data available on how the
   recursion may proceed.
 * You can, however, use the context objects to implement that, since you will end up building a tree of objects where the inner contexts hold references to the outer contexts.

## How do I make the code modular?

 * Create a bunch of `Controller` modules
 * implement `multi dispatch(...) is export {...}`
 * `use` the controllers that declare root actions in the main app
 * in those controllers `use` the ones that extend that part:
 * This is necessary because the candidates for a multi are lexically scoped
 * each controller needs to `import` the candidates that it may need to call

in `lib/TestApp.pm`:
```
use TestApp::Controller::Root;
use TestApp::Controller::Foo;
```

in `lib/TestApp/Controller/Foo.pm`:
```
use TestApp::Controller::Bar;
```

