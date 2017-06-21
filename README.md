# Perl6 Web Dispatching with simple multi dispatch

This repository has a little experiment on building a web application
dispatching based only on multi pattern matching.

The basic principle is:

 * Break the path into tokens
 * Append the request and response objects to the end
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
  $*res.close("Final request in the chain on the root context")x;
}
```

## How do I get a link to an action?

 * Because the action dispatching is done by the language itself via
   recursion, there's not enough meta-data available on how 