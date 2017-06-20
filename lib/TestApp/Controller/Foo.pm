unit module TestApp::Controller::Foo;
use HTTP::Request;
use HTTP::Response;
use TestApp::Context::Foo;
use TestApp::Controller::Bar;

subset StrToInt of Str where +*;

multi dispatch( 'foo', Int(StrToInt) $foo_id, *@remaining ) is export {
    dispatch(TestApp::Context::Foo.new(:foo_id($foo_id)), |@remaining);
}

multi dispatch( TestApp::Context::Foo $c,
                HTTP::Request $req, HTTP::Response $res ) is export {
    $res.status = 200;
    $res.message = "Final request in the chain for foo " ~ $c.foo_id;
}
